package database

import (
	"fmt"
	"log"
	"time"

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

	// Create admin user for web dashboard
	var existingAdmin models.User
	adminResult := db.Where("email = ?", "admin@yachtlife.com").First(&existingAdmin)

	if adminResult.Error != nil {
		adminUser := models.User{
			AppleUserID:  "admin-web-dashboard", // Placeholder for web-only admin
			Email:        "admin@yachtlife.com",
			PasswordHash: "$2a$10$VhZRWNPg2GRSYDi7iGyJ1.adAtPGsYxUBslgApq4cc6mCIFFeDx8C", // bcrypt hash of "admin123"
			FirstName:    "Admin",
			LastName:     "User",
			Phone:        "+61 400 000 000",
			Country:      "Australia",
			Role:         models.RoleAdmin,
		}

		if err := db.Create(&adminUser).Error; err != nil {
			return fmt.Errorf("failed to create admin user: %w", err)
		}

		log.Printf("✅ Created admin user: %s %s (%s)\n", adminUser.FirstName, adminUser.LastName, adminUser.Email)
		log.Println("📧 Admin credentials: admin@yachtlife.com / admin123")
	} else {
		log.Println("✅ Admin user already exists")
	}

	// Create test manager for web dashboard
	var existingManager models.User
	managerResult := db.Where("email = ?", "manager@yachtlife.com").First(&existingManager)

	if managerResult.Error != nil {
		managerUser := models.User{
			AppleUserID:  "manager-web-dashboard", // Placeholder for web-only manager
			Email:        "manager@yachtlife.com",
			PasswordHash: "$2a$10$VhZRWNPg2GRSYDi7iGyJ1.adAtPGsYxUBslgApq4cc6mCIFFeDx8C", // bcrypt hash of "admin123"
			FirstName:    "Fleet",
			LastName:     "Manager",
			Phone:        "+61 400 000 001",
			Country:      "Australia",
			Role:         models.RoleManager,
		}

		if err := db.Create(&managerUser).Error; err != nil {
			return fmt.Errorf("failed to create manager user: %w", err)
		}

		log.Printf("✅ Created manager user: %s %s (%s)\n", managerUser.FirstName, managerUser.LastName, managerUser.Email)
		log.Println("📧 Manager credentials: manager@yachtlife.com / admin123")
	} else {
		log.Println("✅ Manager user already exists")
	}

	// Create test yacht owner with password "password123" for testing
	// In production, password would only be set for managers/admins
	var existingOwner models.User
	ownerResult := db.Where("email = ?", "skipper@neptunefleet.com").First(&existingOwner)

	if ownerResult.Error != nil {
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
	} else {
		log.Println("✅ Test owner already exists")
	}

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

	// Get Neptune's Pride yacht ID and test owner ID for bookings
	var neptunesPride models.Yacht
	if err := db.Where("hull_id = ?", "RIV72-2022-NPF001").First(&neptunesPride).Error; err != nil {
		return fmt.Errorf("failed to find Neptune's Pride yacht: %w", err)
	}

	var testOwnerUser models.User
	if err := db.Where("email = ?", "skipper@neptunefleet.com").First(&testOwnerUser).Error; err != nil {
		return fmt.Errorf("failed to find test owner: %w", err)
	}

	// Create seed bookings for Neptune's Pride
	now := time.Now()
	bookings := []models.Booking{
		{
			YachtID:     neptunesPride.ID,
			UserID:      testOwnerUser.ID,
			StartDate:   now.AddDate(0, 0, 5),  // 5 days from now
			EndDate:     now.AddDate(0, 0, 8),  // 8 days from now
			StandbyDays: 2,
			Status:      models.BookingStatusConfirmed,
			Notes:       "Weekend cruise to Whitsundays",
		},
		{
			YachtID:     neptunesPride.ID,
			UserID:      testOwnerUser.ID,
			StartDate:   now.AddDate(0, 0, 18), // 18 days from now
			EndDate:     now.AddDate(0, 0, 21), // 21 days from now
			StandbyDays: 1,
			Status:      models.BookingStatusPending,
			Notes:       "Family fishing trip",
		},
		{
			YachtID:     neptunesPride.ID,
			UserID:      testOwnerUser.ID,
			StartDate:   now.AddDate(0, 1, 2),  // 1 month + 2 days from now
			EndDate:     now.AddDate(0, 1, 5),  // 1 month + 5 days from now
			StandbyDays: 0,
			Status:      models.BookingStatusConfirmed,
			Notes:       "Summer vacation at Hamilton Island",
		},
	}

	for i, booking := range bookings {
		// Check if similar booking already exists (same yacht, user, and start date)
		var existingBooking models.Booking
		result := db.Where("yacht_id = ? AND user_id = ? AND start_date = ?",
			booking.YachtID, booking.UserID, booking.StartDate).First(&existingBooking)
		if result.Error == nil {
			continue // Skip if already exists
		}

		if err := db.Create(&booking).Error; err != nil {
			return fmt.Errorf("failed to create booking %d: %w", i+1, err)
		}
		log.Printf("✅ Created booking: %s to %s (%s)\n",
			booking.StartDate.Format("Jan 2"),
			booking.EndDate.Format("Jan 2"),
			booking.Status)
	}

	return nil
}
