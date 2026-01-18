package database

import (
	"fmt"
	"log"

	"github.com/bitcoinbrisbane/yachtlife/internal/config"
	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// NewConnection creates a new database connection
func NewConnection(cfg *config.Config) (*gorm.DB, error) {
	var logLevel logger.LogLevel
	if cfg.Environment == "production" {
		logLevel = logger.Error
	} else {
		logLevel = logger.Info
	}

	db, err := gorm.Open(postgres.Open(cfg.DatabaseURL), &gorm.Config{
		Logger: logger.Default.LogMode(logLevel),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Get underlying SQL database
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("failed to get database instance: %w", err)
	}

	// Set connection pool settings
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)

	log.Println("✅ Database connection established")

	return db, nil
}

// RunMigrations runs all database migrations
func RunMigrations(db *gorm.DB) error {
	log.Println("🔄 Running database migrations...")

	// Import models package
	models := []interface{}{
		&models.User{},
		&models.Yacht{},
		&models.SyndicateShare{},
		&models.Booking{},
		&models.BookingChangeRequest{},
		&models.Invoice{},
		&models.Payment{},
		&models.LogbookEntry{},
		&models.Checklist{},
		&models.Vote{},
		&models.VoteResponse{},
		&models.MaintenanceRequest{},
		&models.Notification{},
	}

	// Auto-migrate all models
	if err := db.AutoMigrate(models...); err != nil {
		return fmt.Errorf("failed to run migrations: %w", err)
	}

	log.Println("✅ Database migrations completed")
	return nil
}

// SeedData seeds the database with test data
func SeedData(db *gorm.DB) error {
	log.Println("🌱 Seeding database with test data...")

	// Check if test user already exists
	var existingUser models.User
	result := db.Where("email = ?", "skipper@neptunefleet.com").First(&existingUser)

	if result.Error == nil {
		log.Println("✅ Test data already exists, skipping seed")
		return nil
	}

	// Create test yacht owner with password "password123" for testing
	// In production, password would only be set for managers/admins
	testOwner := models.User{
		Email:        "skipper@neptunefleet.com",
		PasswordHash: "$2a$10$mH11p2dydxUv7v8gSnq/CObztVd.VhVYV3fNF1azFJ5QW.DaqIPC6", // bcrypt hash of "password123"
		FirstName:    "Captain",
		LastName:     "Jack Sparrow",
		Phone:        "+61 412 345 678",
		Country:      "Australia",
		Role:         models.RoleOwner,
	}

	if err := db.Create(&testOwner).Error; err != nil {
		return fmt.Errorf("failed to create test owner: %w", err)
	}

	log.Printf("✅ Created test owner: %s %s (%s)\n", testOwner.FirstName, testOwner.LastName, testOwner.Email)
	log.Println("📧 Test credentials: skipper@neptunefleet.com / password123")
	return nil
}
