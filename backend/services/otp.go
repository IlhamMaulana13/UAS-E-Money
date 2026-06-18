package services

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"image/png"
	"math/big"
	"time"

	"emoney-2fa/config"
	"emoney-2fa/models"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/pquerna/otp/totp"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

type OTPService struct {
	db          *gorm.DB
	rdb         *redis.Client
	firebaseApp *firebase.App
	cfg         *config.Config
	emailSvc    *EmailService
}

func NewOTPService(db *gorm.DB, rdb *redis.Client, firebaseApp *firebase.App, cfg *config.Config, emailSvc *EmailService) *OTPService {
	return &OTPService{
		db:          db,
		rdb:         rdb,
		firebaseApp: firebaseApp,
		cfg:         cfg,
		emailSvc:    emailSvc,
	}
}

func (s *OTPService) GenerateCode() (string, error) {
	max := big.NewInt(1000000)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

func (s *OTPService) storeOTPRedis(ctx context.Context, userID uint, code, otpType string) error {
	key := fmt.Sprintf("otp:%d:%s", userID, otpType)
	expiry := time.Duration(s.cfg.OTPExpiryMinutes) * time.Minute
	return s.rdb.Set(ctx, key, code, expiry).Err()
}

func (s *OTPService) VerifyOTPRedis(ctx context.Context, userID uint, code, otpType string) bool {
	key := fmt.Sprintf("otp:%d:%s", userID, otpType)
	stored, err := s.rdb.Get(ctx, key).Result()
	if err != nil {
		return false
	}
	if stored == code {
		s.rdb.Del(ctx, key)
		return true
	}
	return false
}

// SendFirebaseOTP sends OTP via Firebase Cloud Messaging push notification
func (s *OTPService) SendFirebaseOTP(ctx context.Context, user *models.User) error {
	code, err := s.GenerateCode()
	if err != nil {
		return fmt.Errorf("generate otp: %w", err)
	}

	if err := s.storeOTPRedis(ctx, user.ID, code, models.OTPTypeFirebase); err != nil {
		return fmt.Errorf("store otp: %w", err)
	}

	if user.FCMToken == "" {
		return fmt.Errorf("user does not have FCM token registered")
	}

	client, err := s.firebaseApp.Messaging(ctx)
	if err != nil {
		return fmt.Errorf("firebase messaging client: %w", err)
	}

	message := &messaging.Message{
		Token: user.FCMToken,
		Notification: &messaging.Notification{
			Title: "Kode OTP E-Money",
			Body:  fmt.Sprintf("Kode OTP Anda: %s. Berlaku %d menit.", code, s.cfg.OTPExpiryMinutes),
		},
		Data: map[string]string{
			"otp_code": code,
			"type":     "otp",
		},
		Android: &messaging.AndroidConfig{
			Priority: "high",
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound: "default",
				},
			},
		},
	}

	_, err = client.Send(ctx, message)
	return err
}

// SendEmailOTP sends OTP via email
func (s *OTPService) SendEmailOTP(ctx context.Context, user *models.User) error {
	code, err := s.GenerateCode()
	if err != nil {
		return fmt.Errorf("generate otp: %w", err)
	}

	if err := s.storeOTPRedis(ctx, user.ID, code, models.OTPTypeEmail); err != nil {
		return fmt.Errorf("store otp: %w", err)
	}

	subject := "Kode OTP E-Money"
	body := fmt.Sprintf(`
<html>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: #f0f4ff; padding: 30px; border-radius: 10px;">
    <h2 style="color: #333;">Kode OTP E-Money</h2>
    <p>Halo <strong>%s</strong>,</p>
    <p>Gunakan kode OTP berikut untuk melanjutkan transaksi Anda:</p>
    <div style="background: #fff; border: 2px solid #667eea; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0;">
      <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #667eea;">%s</span>
    </div>
    <p style="color: #666; font-size: 14px;">Kode ini berlaku selama <strong>%d menit</strong>.</p>
    <p style="color: #999; font-size: 12px;">Jangan bagikan kode ini kepada siapapun.</p>
  </div>
</body>
</html>`, user.Name, code, s.cfg.OTPExpiryMinutes)

	return s.emailSvc.SendHTML(user.Email, subject, body)
}

// RegisterTOTP generates a new TOTP secret for the user
func (s *OTPService) RegisterTOTP(ctx context.Context, user *models.User) (secret, qrCodeBase64 string, err error) {
	key, err := totp.Generate(totp.GenerateOpts{
		Issuer:      "E-Money App",
		AccountName: user.Email,
	})
	if err != nil {
		return "", "", fmt.Errorf("generate totp: %w", err)
	}

	img, err := key.Image(200, 200)
	if err != nil {
		return "", "", fmt.Errorf("generate qr image: %w", err)
	}

	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		return "", "", fmt.Errorf("encode qr image: %w", err)
	}

	qrCodeBase64 = "data:image/png;base64," + base64.StdEncoding.EncodeToString(buf.Bytes())

	if err := s.db.WithContext(ctx).Model(user).Updates(map[string]interface{}{
		"totp_secret":  key.Secret(),
		"totp_enabled": false,
	}).Error; err != nil {
		return "", "", fmt.Errorf("save totp secret: %w", err)
	}

	return key.Secret(), qrCodeBase64, nil
}

// VerifyTOTP verifies a TOTP code and enables TOTP if not yet enabled
func (s *OTPService) VerifyTOTP(ctx context.Context, user *models.User, code string) (bool, error) {
	if user.TOTPSecret == "" {
		return false, fmt.Errorf("TOTP belum didaftarkan")
	}

	valid := totp.Validate(code, user.TOTPSecret)
	if valid && !user.TOTPEnabled {
		if err := s.db.WithContext(ctx).Model(user).Update("totp_enabled", true).Error; err != nil {
			return false, err
		}
	}

	return valid, nil
}
