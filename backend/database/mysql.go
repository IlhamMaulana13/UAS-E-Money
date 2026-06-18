package database

import (
	"fmt"
	"log"

	"emoney-2fa/config"
	"emoney-2fa/models"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func InitMySQL(cfg *config.Config) *gorm.DB {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		cfg.DBUser,
		cfg.DBPassword,
		cfg.DBHost,
		cfg.DBPort,
		cfg.DBName,
	)

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatal("Failed to connect to MySQL:", err)
	}

	if err := db.AutoMigrate(
		&models.User{},
		&models.OTP{},
		&models.Account{},
		&models.Transaction{},
	); err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	log.Println("MySQL connected and migrated")
	return db
}
