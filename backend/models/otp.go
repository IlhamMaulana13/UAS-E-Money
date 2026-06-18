package models

import (
	"time"

	"gorm.io/gorm"
)

const (
	OTPTypeFirebase = "firebase"
	OTPTypeEmail    = "email"
)

type OTP struct {
	gorm.Model
	UserID    uint      `gorm:"not null;index" json:"user_id"`
	Code      string    `gorm:"not null;type:varchar(10)" json:"-"`
	Type      string    `gorm:"not null;type:varchar(20)" json:"type"` // "firebase" | "email"
	ExpiresAt time.Time `json:"expires_at"`
	Used      bool      `gorm:"default:false" json:"used"`
	User      User      `gorm:"foreignKey:UserID" json:"-"`
}
