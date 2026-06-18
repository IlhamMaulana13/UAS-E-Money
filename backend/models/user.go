package models

import "gorm.io/gorm"

type User struct {
	gorm.Model
	FirebaseUID   string `gorm:"uniqueIndex;not null;type:varchar(191)" json:"firebase_uid"`
	Email         string `gorm:"uniqueIndex;not null;type:varchar(191)" json:"email"`
	Name          string `gorm:"type:varchar(255)" json:"name"`
	Role          string `gorm:"type:varchar(50);default:user" json:"role"`
	EmailVerified bool   `json:"email_verified"`
	FCMToken      string `gorm:"type:text" json:"-"`
	TOTPSecret    string `gorm:"type:text" json:"-"`
	TOTPEnabled   bool   `gorm:"default:false" json:"totp_enabled"`
}

type UserResponse struct {
	ID            uint   `json:"id"`
	FirebaseUID   string `json:"firebase_uid"`
	Email         string `json:"email"`
	Name          string `json:"name"`
	Role          string `json:"role"`
	EmailVerified bool   `json:"email_verified"`
	TOTPEnabled   bool   `json:"totp_enabled"`
	CreatedAt     string `json:"created_at"`
}
