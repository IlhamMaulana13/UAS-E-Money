package routes

import (
	"emoney-2fa/config"
	"emoney-2fa/handlers"
	"emoney-2fa/middleware"
	"emoney-2fa/services"

	firebase "firebase.google.com/go/v4"
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

func Setup(db *gorm.DB, rdb *redis.Client, firebaseApp *firebase.App, cfg *config.Config) *gin.Engine {
	r := gin.Default()

	jwtSvc := services.NewJWTService(cfg)
	emailSvc := services.NewEmailService(cfg)
	otpSvc := services.NewOTPService(db, rdb, firebaseApp, cfg, emailSvc)

	authHandler := handlers.NewAuthHandler(db, firebaseApp, jwtSvc, otpSvc)
	otpHandler := handlers.NewOTPHandler(db, otpSvc)
	paymentHandler := handlers.NewPaymentHandler(db, otpSvc)

	v1 := r.Group("/v1")
	{
		v1.GET("/health", handlers.HealthCheck)

		auth := v1.Group("/auth")
		{
			auth.POST("/verify-token", authHandler.VerifyToken)
			auth.POST("/register", authHandler.Register)

			authRequired := auth.Group("")
			authRequired.Use(middleware.AuthMiddleware(jwtSvc))
			{
				authRequired.GET("/me", authHandler.Me)
				authRequired.PUT("/fcm-token", authHandler.UpdateFCMToken)
				authRequired.POST("/verify-email-otp", authHandler.VerifyEmailOTP)
			}
		}

		otp := v1.Group("/otp")
		otp.Use(middleware.AuthMiddleware(jwtSvc))
		{
			otp.POST("/send-firebase", otpHandler.SendFirebaseOTP)
			otp.POST("/send-email", otpHandler.SendEmailOTP)
			otp.POST("/confirm", otpHandler.ConfirmOTP)

			totpGroup := otp.Group("/totp")
			{
				totpGroup.POST("/register", otpHandler.RegisterTOTP)
				totpGroup.POST("/verify", otpHandler.VerifyTOTP)
			}
		}

		account := v1.Group("/account")
		account.Use(middleware.AuthMiddleware(jwtSvc))
		{
			account.GET("", paymentHandler.GetAccount)
			account.GET("/transactions", paymentHandler.GetTransactions)
		}

		payment := v1.Group("/payment")
		payment.Use(middleware.AuthMiddleware(jwtSvc))
		{
			payment.POST("/topup", paymentHandler.TopUp)
			payment.POST("/transfer", paymentHandler.Transfer)
		}
	}

	return r
}
