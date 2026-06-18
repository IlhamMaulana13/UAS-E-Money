package handlers

import (
	"net/http"

	"emoney-2fa/models"
	"emoney-2fa/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type OTPHandler struct {
	db     *gorm.DB
	otpSvc *services.OTPService
}

func NewOTPHandler(db *gorm.DB, otpSvc *services.OTPService) *OTPHandler {
	return &OTPHandler{db: db, otpSvc: otpSvc}
}

type ConfirmOTPRequest struct {
	Code    string `json:"code" binding:"required"`
	OTPType string `json:"otp_type" binding:"required"` // "firebase" | "email"
}

type VerifyTOTPRequest struct {
	Code string `json:"code" binding:"required"`
}

func (h *OTPHandler) getUser(c *gin.Context) (*models.User, bool) {
	userID := c.GetUint("user_id")
	var user models.User
	if err := h.db.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "User tidak ditemukan",
		})
		return nil, false
	}
	return &user, true
}

// POST /v1/otp/send-firebase
func (h *OTPHandler) SendFirebaseOTP(c *gin.Context) {
	user, ok := h.getUser(c)
	if !ok {
		return
	}

	if err := h.otpSvc.SendFirebaseOTP(c.Request.Context(), user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal mengirim OTP via Firebase: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "OTP berhasil dikirim via notifikasi Firebase",
		"data": gin.H{
			"otp_type":   "firebase",
			"expires_in": 300,
		},
	})
}

// POST /v1/otp/send-email
func (h *OTPHandler) SendEmailOTP(c *gin.Context) {
	user, ok := h.getUser(c)
	if !ok {
		return
	}

	if err := h.otpSvc.SendEmailOTP(c.Request.Context(), user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal mengirim OTP via email: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "OTP berhasil dikirim ke email " + user.Email,
		"data": gin.H{
			"otp_type":   "email",
			"expires_in": 300,
		},
	})
}

// POST /v1/otp/confirm
func (h *OTPHandler) ConfirmOTP(c *gin.Context) {
	user, ok := h.getUser(c)
	if !ok {
		return
	}

	var req ConfirmOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "code dan otp_type diperlukan",
		})
		return
	}

	if req.OTPType != models.OTPTypeFirebase && req.OTPType != models.OTPTypeEmail {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "otp_type harus 'firebase' atau 'email'",
		})
		return
	}

	valid := h.otpSvc.VerifyOTPRedis(c.Request.Context(), user.ID, req.Code, req.OTPType)
	if !valid {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success":    false,
			"message":    "Kode OTP tidak valid atau sudah kadaluarsa",
			"error_code": "INVALID_OTP",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "OTP berhasil diverifikasi",
	})
}

// POST /v1/otp/totp/register
func (h *OTPHandler) RegisterTOTP(c *gin.Context) {
	user, ok := h.getUser(c)
	if !ok {
		return
	}

	secret, qrCode, err := h.otpSvc.RegisterTOTP(c.Request.Context(), user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal mendaftarkan TOTP: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "TOTP berhasil didaftarkan. Scan QR code dengan Google Authenticator.",
		"data": gin.H{
			"secret":    secret,
			"qr_code":   qrCode,
			"issuer":    "E-Money App",
			"account":   user.Email,
			"algorithm": "SHA1",
			"digits":    6,
			"period":    30,
		},
	})
}

// POST /v1/otp/totp/verify
func (h *OTPHandler) VerifyTOTP(c *gin.Context) {
	user, ok := h.getUser(c)
	if !ok {
		return
	}

	var req VerifyTOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "code diperlukan",
		})
		return
	}

	valid, err := h.otpSvc.VerifyTOTP(c.Request.Context(), user, req.Code)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": err.Error(),
		})
		return
	}

	if !valid {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success":    false,
			"message":    "Kode TOTP tidak valid",
			"error_code": "INVALID_TOTP",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "TOTP berhasil diverifikasi",
		"data": gin.H{
			"totp_enabled": true,
		},
	})
}
