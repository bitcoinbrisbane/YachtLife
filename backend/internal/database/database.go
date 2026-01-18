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

	// Create Neptune Oceanic Fleet yachts
	yachts := []models.Yacht{
		{
			Name:               "Neptune's Pride",
			Manufacturer:       "Riviera",
			Model:              "Riviera 72 Sports Motor Yacht",
			Year:               2022,
			LengthFeet:         72.0,
			BeamFeet:           19.5,
			DraftFeet:          5.2,
			HullID:             "RIV72-2022-NPF001",
			HomePort:           "Gold Coast Marina",
			MaxPassengers:      12,
			FuelCapacityLiters: 3000,
			WaterCapacityLiters: 500,
			EngineMake:         "Volvo Penta",
			EngineModel:        "IPS 1200",
			EngineCount:        2,
			EngineHorsepower:   900,
		},
		{
			Name:               "Ocean Majesty",
			Manufacturer:       "Maritimo",
			Model:              "Maritimo X60",
			Year:               2023,
			LengthFeet:         60.0,
			BeamFeet:           17.2,
			DraftFeet:          4.8,
			HullID:             "MAR60-2023-NPF002",
			HomePort:           "Sanctuary Cove",
			MaxPassengers:      10,
			FuelCapacityLiters: 2500,
			WaterCapacityLiters: 400,
			EngineMake:         "Volvo Penta",
			EngineModel:        "IPS 1050",
			EngineCount:        2,
			EngineHorsepower:   800,
		},
		{
			Name:               "Blue Trident",
			Manufacturer:       "Sunseeker",
			Model:              "Sunseeker 88 Yacht",
			Year:               2021,
			LengthFeet:         88.0,
			BeamFeet:           21.8,
			DraftFeet:          6.5,
			HullID:             "SUN88-2021-NPF003",
			HomePort:           "Sydney Harbour",
			MaxPassengers:      16,
			FuelCapacityLiters: 4500,
			WaterCapacityLiters: 800,
			EngineMake:         "MTU",
			EngineModel:        "12V 2000 M96L",
			EngineCount:        2,
			EngineHorsepower:   1900,
		},
		{
			Name:               "Pacific Sovereign",
			Manufacturer:       "Princess",
			Model:              "Princess 85 Motor Yacht",
			Year:               2022,
			LengthFeet:         85.0,
			BeamFeet:           20.5,
			DraftFeet:          5.9,
			HullID:             "PRI85-2022-NPF004",
			HomePort:           "Hamilton Island Marina",
			MaxPassengers:      14,
			FuelCapacityLiters: 4000,
			WaterCapacityLiters: 700,
			EngineMake:         "MAN",
			EngineModel:        "V12-1800",
			EngineCount:        2,
			EngineHorsepower:   1800,
		},
	}

	for _, yacht := range yachts {
		// Check if yacht already exists
		var existingYacht models.Yacht
		result := db.Where("hull_id = ?", yacht.HullID).First(&existingYacht)
		if result.Error == nil {
			continue // Skip if already exists
		}

		if err := db.Create(&yacht).Error; err != nil {
			return fmt.Errorf("failed to create yacht %s: %w", yacht.Name, err)
		}
		log.Printf("✅ Created yacht: %s - %s %s\n", yacht.Name, yacht.Manufacturer, yacht.Model)
	}

	return nil
}
