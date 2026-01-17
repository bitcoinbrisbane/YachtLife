package config

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	// Server
	Port        string
	Environment string
	GinMode     string

	// Database
	DatabaseURL      string
	DatabaseHost     string
	DatabasePort     string
	DatabaseUser     string
	DatabasePassword string
	DatabaseName     string

	// JWT
	JWTSecret            string
	JWTExpiration        time.Duration
	JWTRefreshExpiration time.Duration

	// Apple Sign In
	AppleTeamID     string
	AppleClientID   string
	AppleKeyID      string
	ApplePrivateKey string

	// Stripe
	StripeSecretKey      string
	StripePublishableKey string
	StripeWebhookSecret  string

	// Xero
	XeroClientID     string
	XeroClientSecret string
	XeroRedirectURI  string
	XeroWebhookKey   string

	// S3/MinIO
	S3Endpoint  string
	S3AccessKey string
	S3SecretKey string
	S3Bucket    string
	S3Region    string
	S3UseSSL    bool

	// Firebase
	FCMServerKey string
	FCMProjectID string

	// Email (SendGrid)
	SendGridAPIKey string
	EmailFrom      string
	EmailFromName  string

	// SMS (MessageBird or Twilio)
	MessageBirdAPIKey string
	TwilioAccountSID  string
	TwilioAuthToken   string
	TwilioPhoneNumber string
	SMSFrom           string

	// CORS
	CORSAllowedOrigins []string

	// Logging
	LogLevel  string
	LogFormat string

	// Rate Limiting
	RateLimitRequests int
	RateLimitWindow   time.Duration

	// Session
	SessionTimeout time.Duration
}

func Load() (*Config, error) {
	// Load .env file if it exists (for local development)
	_ = godotenv.Load()

	cfg := &Config{
		Port:        getEnv("PORT", "8080"),
		Environment: getEnv("ENVIRONMENT", "development"),
		GinMode:     getEnv("GIN_MODE", "debug"),

		DatabaseURL:      getEnv("DATABASE_URL", ""),
		DatabaseHost:     getEnv("DATABASE_HOST", "localhost"),
		DatabasePort:     getEnv("DATABASE_PORT", "5432"),
		DatabaseUser:     getEnv("DATABASE_USER", "yachtlife"),
		DatabasePassword: getEnv("DATABASE_PASSWORD", "yachtlife_dev_password"),
		DatabaseName:     getEnv("DATABASE_NAME", "yachtlife"),

		JWTSecret:            getEnv("JWT_SECRET", "dev-secret-change-in-production"),
		JWTExpiration:        parseDuration(getEnv("JWT_EXPIRATION", "24h")),
		JWTRefreshExpiration: parseDuration(getEnv("JWT_REFRESH_EXPIRATION", "168h")),

		AppleTeamID:     getEnv("APPLE_TEAM_ID", ""),
		AppleClientID:   getEnv("APPLE_CLIENT_ID", ""),
		AppleKeyID:      getEnv("APPLE_KEY_ID", ""),
		ApplePrivateKey: getEnv("APPLE_PRIVATE_KEY", ""),

		StripeSecretKey:      getEnv("STRIPE_SECRET_KEY", ""),
		StripePublishableKey: getEnv("STRIPE_PUBLISHABLE_KEY", ""),
		StripeWebhookSecret:  getEnv("STRIPE_WEBHOOK_SECRET", ""),

		XeroClientID:     getEnv("XERO_CLIENT_ID", ""),
		XeroClientSecret: getEnv("XERO_CLIENT_SECRET", ""),
		XeroRedirectURI:  getEnv("XERO_REDIRECT_URI", ""),
		XeroWebhookKey:   getEnv("XERO_WEBHOOK_KEY", ""),

		S3Endpoint:  getEnv("S3_ENDPOINT", "http://localhost:9000"),
		S3AccessKey: getEnv("S3_ACCESS_KEY", "yachtlife"),
		S3SecretKey: getEnv("S3_SECRET_KEY", "yachtlife_minio_password"),
		S3Bucket:    getEnv("S3_BUCKET", "yachtlife-storage"),
		S3Region:    getEnv("S3_REGION", "us-east-1"),
		S3UseSSL:    getEnv("S3_USE_SSL", "false") == "true",

		FCMServerKey: getEnv("FCM_SERVER_KEY", ""),
		FCMProjectID: getEnv("FCM_PROJECT_ID", ""),

		SendGridAPIKey: getEnv("SENDGRID_API_KEY", ""),
		EmailFrom:      getEnv("EMAIL_FROM", "noreply@yachtlife.app"),
		EmailFromName:  getEnv("EMAIL_FROM_NAME", "YachtLife"),

		MessageBirdAPIKey: getEnv("MESSAGEBIRD_API_KEY", ""),
		TwilioAccountSID:  getEnv("TWILIO_ACCOUNT_SID", ""),
		TwilioAuthToken:   getEnv("TWILIO_AUTH_TOKEN", ""),
		TwilioPhoneNumber: getEnv("TWILIO_PHONE_NUMBER", ""),
		SMSFrom:           getEnv("SMS_FROM", "YachtLife"),

		CORSAllowedOrigins: strings.Split(getEnv("CORS_ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:5173"), ","),

		LogLevel:  getEnv("LOG_LEVEL", "debug"),
		LogFormat: getEnv("LOG_FORMAT", "json"),

		RateLimitRequests: 100,
		RateLimitWindow:   parseDuration(getEnv("RATE_LIMIT_WINDOW", "60s")),

		SessionTimeout: parseDuration(getEnv("SESSION_TIMEOUT", "30m")),
	}

	// Build DATABASE_URL if not provided
	if cfg.DatabaseURL == "" {
		cfg.DatabaseURL = fmt.Sprintf(
			"postgresql://%s:%s@%s:%s/%s?sslmode=disable",
			cfg.DatabaseUser,
			cfg.DatabasePassword,
			cfg.DatabaseHost,
			cfg.DatabasePort,
			cfg.DatabaseName,
		)
	}

	return cfg, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func parseDuration(s string) time.Duration {
	d, err := time.ParseDuration(s)
	if err != nil {
		return 0
	}
	return d
}
