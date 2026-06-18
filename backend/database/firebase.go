package database

import (
	"context"
	"log"

	"emoney-2fa/config"

	firebase "firebase.google.com/go/v4"
	"google.golang.org/api/option"
)

func InitFirebase(cfg *config.Config) *firebase.App {
	opt := option.WithCredentialsFile(cfg.FirebaseCredPath)

	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatal("Failed to initialize Firebase:", err)
	}

	log.Println("Firebase initialized")
	return app
}
