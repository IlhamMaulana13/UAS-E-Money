package handlers

import (
	"net/http"
	"time"

	"emoney-2fa/models"
	"emoney-2fa/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type PaymentHandler struct {
	db     *gorm.DB
	otpSvc *services.OTPService
}

func NewPaymentHandler(db *gorm.DB, otpSvc *services.OTPService) *PaymentHandler {
	return &PaymentHandler{db: db, otpSvc: otpSvc}
}

type TransferRequest struct {
	Amount      float64 `json:"amount" binding:"required,gt=0"`
	Description string  `json:"description"`
	OTPCode     string  `json:"otp_code" binding:"required"`
	OTPType     string  `json:"otp_type" binding:"required"` // "firebase" | "email" | "totp"
}

type TopUpRequest struct {
	Amount float64 `json:"amount" binding:"required,gt=0"`
}

// GET /v1/account
func (h *PaymentHandler) GetAccount(c *gin.Context) {
	userID := c.GetUint("user_id")

	var account models.Account
	if err := h.db.Where("user_id = ?", userID).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Akun tidak ditemukan",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"id":         account.ID,
			"user_id":    account.UserID,
			"balance":    account.Balance,
			"created_at": account.CreatedAt.Format(time.RFC3339),
		},
	})
}

// GET /v1/account/transactions
func (h *PaymentHandler) GetTransactions(c *gin.Context) {
	userID := c.GetUint("user_id")

	var account models.Account
	if err := h.db.Where("user_id = ?", userID).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Akun tidak ditemukan",
		})
		return
	}

	var transactions []models.Transaction
	h.db.Where("account_id = ?", account.ID).Order("created_at desc").Limit(20).Find(&transactions)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    transactions,
	})
}

// POST /v1/payment/topup (tanpa OTP - untuk testing)
func (h *PaymentHandler) TopUp(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req TopUpRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "amount diperlukan dan harus lebih dari 0",
		})
		return
	}

	var account models.Account
	if err := h.db.Where("user_id = ?", userID).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Akun tidak ditemukan",
		})
		return
	}

	err := h.db.Transaction(func(tx *gorm.DB) error {
		balanceBefore := account.Balance
		account.Balance += req.Amount

		if err := tx.Save(&account).Error; err != nil {
			return err
		}

		trx := models.Transaction{
			AccountID:     account.ID,
			Amount:        req.Amount,
			Type:          "credit",
			Description:   "Top Up Saldo",
			BalanceBefore: balanceBefore,
			BalanceAfter:  account.Balance,
		}
		return tx.Create(&trx).Error
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal melakukan top up",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Top up berhasil",
		"data": gin.H{
			"balance": account.Balance,
			"amount":  req.Amount,
		},
	})
}

// POST /v1/payment/transfer
func (h *PaymentHandler) Transfer(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req TransferRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Semua field diperlukan: amount, otp_code, otp_type",
		})
		return
	}

	// Verify OTP
	otpValid := false
	ctx := c.Request.Context()

	switch req.OTPType {
	case models.OTPTypeFirebase, models.OTPTypeEmail:
		otpValid = h.otpSvc.VerifyOTPRedis(ctx, userID, req.OTPCode, req.OTPType)
	case "totp":
		var user models.User
		if err := h.db.First(&user, userID).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{
				"success": false,
				"message": "User tidak ditemukan",
			})
			return
		}
		valid, err := h.otpSvc.VerifyTOTP(ctx, &user, req.OTPCode)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"message": err.Error(),
			})
			return
		}
		otpValid = valid
	default:
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "otp_type harus 'firebase', 'email', atau 'totp'",
		})
		return
	}

	if !otpValid {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success":    false,
			"message":    "OTP tidak valid atau sudah kadaluarsa",
			"error_code": "INVALID_OTP",
		})
		return
	}

	var account models.Account
	if err := h.db.Where("user_id = ?", userID).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Akun tidak ditemukan",
		})
		return
	}

	if account.Balance < req.Amount {
		c.JSON(http.StatusBadRequest, gin.H{
			"success":    false,
			"message":    "Saldo tidak cukup",
			"error_code": "INSUFFICIENT_BALANCE",
			"data": gin.H{
				"balance": account.Balance,
				"amount":  req.Amount,
			},
		})
		return
	}

	var trx models.Transaction
	err := h.db.Transaction(func(tx *gorm.DB) error {
		balanceBefore := account.Balance
		account.Balance -= req.Amount

		if err := tx.Save(&account).Error; err != nil {
			return err
		}

		desc := req.Description
		if desc == "" {
			desc = "Transfer / Pembayaran"
		}

		trx = models.Transaction{
			AccountID:     account.ID,
			Amount:        req.Amount,
			Type:          "debit",
			Description:   desc,
			BalanceBefore: balanceBefore,
			BalanceAfter:  account.Balance,
		}
		return tx.Create(&trx).Error
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal melakukan transfer",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Transfer berhasil",
		"data": gin.H{
			"transaction_id": trx.ID,
			"amount":         req.Amount,
			"description":    trx.Description,
			"balance_before": trx.BalanceBefore,
			"balance_after":  trx.BalanceAfter,
			"created_at":     trx.CreatedAt.Format(time.RFC3339),
		},
	})
}
