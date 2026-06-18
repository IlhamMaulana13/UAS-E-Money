package services

import (
	"crypto/tls"
	"fmt"

	"emoney-2fa/config"

	"gopkg.in/gomail.v2"
)

type EmailService struct {
	cfg *config.Config
}

func NewEmailService(cfg *config.Config) *EmailService {
	return &EmailService{cfg: cfg}
}

func (s *EmailService) SendHTML(to, subject, htmlBody string) error {
	if s.cfg.SMTPUser == "" {
		return fmt.Errorf("SMTP not configured")
	}

	m := gomail.NewMessage()
	m.SetAddressHeader("From", s.cfg.SMTPFrom, s.cfg.SMTPFromName)
	m.SetHeader("To", to)
	m.SetHeader("Subject", subject)
	m.SetBody("text/html", htmlBody)

	d := gomail.NewDialer(s.cfg.SMTPHost, s.cfg.SMTPPort, s.cfg.SMTPUser, s.cfg.SMTPPassword)
	d.TLSConfig = &tls.Config{ServerName: s.cfg.SMTPHost}

	return d.DialAndSend(m)
}
