package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"emoney-2fa/models"
	"emoney-2fa/services"

	firebase "firebase.google.com/go/v4"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type AuthHandler struct {
	db          *gorm.DB
	firebaseApp *firebase.App
	jwtSvc      *services.JWTService
	otpSvc      *services.OTPService
}

func NewAuthHandler(db *gorm.DB, firebaseApp *firebase.App, jwtSvc *services.JWTService, otpSvc *services.OTPService) *AuthHandler {
	return &AuthHandler{db: db, firebaseApp: firebaseApp, jwtSvc: jwtSvc, otpSvc: otpSvc}
}

type VerifyTokenRequest struct {
	FirebaseToken string `json:"firebase_token" binding:"required"`
}

type UpdateFCMTokenRequest struct {
	FCMToken string `json:"fcm_token" binding:"required"`
}

func (h *AuthHandler) VerifyToken(c *gin.Context) {
	var req VerifyTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "firebase_token diperlukan",
		})
		return
	}

	ctx := context.Background()
	authClient, err := h.firebaseApp.Auth(ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Firebase auth error",
		})
		return
	}

	token, err := authClient.VerifyIDToken(ctx, req.FirebaseToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success":    false,
			"message":    "Token tidak valid atau kadaluarsa",
			"error_code": "INVALID_FIREBASE_TOKEN",
		})
		return
	}

	emailVerified, _ := token.Claims["email_verified"].(bool)
	if !emailVerified {
		c.JSON(http.StatusForbidden, gin.H{
			"success":    false,
			"message":    "Email belum diverifikasi. Cek inbox email Anda.",
			"error_code": "EMAIL_NOT_VERIFIED",
		})
		return
	}

	email, _ := token.Claims["email"].(string)
	name, _ := token.Claims["name"].(string)

	var user models.User
	result := h.db.WithContext(ctx).Where("firebase_uid = ?", token.UID).First(&user)

	if result.Error == gorm.ErrRecordNotFound {
		user = models.User{
			FirebaseUID:   token.UID,
			Email:         email,
			Name:          name,
			Role:          "user",
			EmailVerified: emailVerified,
		}
		if err := h.db.WithContext(ctx).Create(&user).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Gagal membuat user",
			})
			return
		}

		account := models.Account{UserID: user.ID, Balance: 0}
		h.db.WithContext(ctx).Create(&account)
	} else if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Database error",
		})
		return
	} else {
		h.db.WithContext(ctx).Model(&user).Updates(map[string]interface{}{
			"email":          email,
			"name":           name,
			"email_verified": emailVerified,
		})
	}

	jwtToken, err := h.jwtSvc.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal membuat token",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Login berhasil",
		"data": gin.H{
			"access_token": jwtToken,
			"token_type":   "Bearer",
			"expires_in":   86400,
			"user": models.UserResponse{
				ID:            user.ID,
				FirebaseUID:   user.FirebaseUID,
				Email:         user.Email,
				Name:          user.Name,
				Role:          user.Role,
				EmailVerified: user.EmailVerified,
				TOTPEnabled:   user.TOTPEnabled,
				CreatedAt:     user.CreatedAt.Format(time.RFC3339),
			},
		},
	})
}

func (h *AuthHandler) UpdateFCMToken(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req UpdateFCMTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "fcm_token diperlukan",
		})
		return
	}

	if err := h.db.Model(&models.User{}).Where("id = ?", userID).
		Update("fcm_token", req.FCMToken).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal update FCM token",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "FCM token berhasil diupdate",
	})
}

type RegisterRequest struct {
	FirebaseToken string `json:"firebase_token" binding:"required"`
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "firebase_token diperlukan",
		})
		return
	}

	ctx := context.Background()
	authClient, err := h.firebaseApp.Auth(ctx)
	if err != nil {
		log.Printf("[Register] Firebase auth init error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Firebase auth error: " + err.Error(),
		})
		return
	}

	token, err := authClient.VerifyIDToken(ctx, req.FirebaseToken)
	if err != nil {
		log.Printf("[Register] VerifyIDToken error: %v", err)
		c.JSON(http.StatusUnauthorized, gin.H{
			"success":    false,
			"message":    "Token tidak valid atau kadaluarsa",
			"error_code": "INVALID_FIREBASE_TOKEN",
		})
		return
	}

	email, _ := token.Claims["email"].(string)
	name, _ := token.Claims["name"].(string)
	log.Printf("[Register] Firebase UID=%s email=%s name=%s", token.UID, email, name)

	var user models.User
	result := h.db.WithContext(ctx).Where("firebase_uid = ?", token.UID).First(&user)

	if result.Error == gorm.ErrRecordNotFound {
		user = models.User{
			FirebaseUID:   token.UID,
			Email:         email,
			Name:          name,
			Role:          "user",
			EmailVerified: false,
		}
		if err := h.db.WithContext(ctx).Create(&user).Error; err != nil {
			log.Printf("[Register] DB create user error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{
				"success": false,
				"message": "Gagal membuat user: " + err.Error(),
			})
			return
		}
		account := models.Account{UserID: user.ID, Balance: 0}
		h.db.WithContext(ctx).Create(&account)
	} else if result.Error != nil {
		log.Printf("[Register] DB lookup error: %v", result.Error)
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Database error: " + result.Error.Error(),
		})
		return
	}

	if err := h.otpSvc.SendEmailOTP(ctx, &user); err != nil {
		log.Printf("[Register] SendEmailOTP error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal mengirim OTP: " + err.Error(),
		})
		return
	}

	jwtToken, err := h.jwtSvc.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal membuat token",
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Registrasi berhasil. Kode OTP telah dikirim ke email Anda.",
		"data": gin.H{
			"access_token": jwtToken,
			"token_type":   "Bearer",
			"expires_in":   86400,
			"user": models.UserResponse{
				ID:            user.ID,
				FirebaseUID:   user.FirebaseUID,
				Email:         user.Email,
				Name:          user.Name,
				Role:          user.Role,
				EmailVerified: user.EmailVerified,
				TOTPEnabled:   user.TOTPEnabled,
				CreatedAt:     user.CreatedAt.Format(time.RFC3339),
			},
		},
	})
}

type VerifyEmailOTPRequest struct {
	Code string `json:"code" binding:"required"`
}

func (h *AuthHandler) VerifyEmailOTP(c *gin.Context) {
	userID := c.GetUint("user_id")

	var req VerifyEmailOTPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "code diperlukan",
		})
		return
	}

	valid := h.otpSvc.VerifyOTPRedis(c.Request.Context(), userID, req.Code, models.OTPTypeEmail)
	if !valid {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success":    false,
			"message":    "Kode OTP tidak valid atau sudah kadaluarsa",
			"error_code": "INVALID_OTP",
		})
		return
	}

	if err := h.db.WithContext(c.Request.Context()).Model(&models.User{}).
		Where("id = ?", userID).
		Update("email_verified", true).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Gagal update status email",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Email berhasil diverifikasi",
	})
}

func (h *AuthHandler) Me(c *gin.Context) {
	userID := c.GetUint("user_id")

	var user models.User
	if err := h.db.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "User tidak ditemukan",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": models.UserResponse{
			ID:            user.ID,
			FirebaseUID:   user.FirebaseUID,
			Email:         user.Email,
			Name:          user.Name,
			Role:          user.Role,
			EmailVerified: user.EmailVerified,
			TOTPEnabled:   user.TOTPEnabled,
			CreatedAt:     user.CreatedAt.Format(time.RFC3339),
		},
	})
}
