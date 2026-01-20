package routes

import (
	"time"

	"github.com/bitcoinbrisbane/yachtlife/internal/api/handlers"
	"github.com/bitcoinbrisbane/yachtlife/internal/api/middleware"
	"github.com/bitcoinbrisbane/yachtlife/internal/config"
	"github.com/bitcoinbrisbane/yachtlife/internal/services"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// SetupRoutes configures all API routes
func SetupRoutes(router *gin.Engine, db *gorm.DB, cfg *config.Config) {
	// Initialize services
	jwtService := services.NewJWTService(cfg.JWTSecret, 24*time.Hour)
	appleSignInService := services.NewAppleSignInService(cfg.AppleClientID, cfg.AppleTeamID)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(db, jwtService, appleSignInService)
	yachtHandler := handlers.NewYachtHandler(db)
	userHandler := handlers.NewUserHandler(db)
	logbookHandler := handlers.NewLogbookHandler(db)
	bookingHandler := handlers.NewBookingHandler(db)
	activityHandler := handlers.NewActivityHandler(db)
	dashboardHandler := handlers.NewDashboardHandler(db)
	invoiceHandler := handlers.NewInvoiceHandler(db)

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Auth routes (public - no authentication required)
		auth := v1.Group("/auth")
		{
			auth.POST("/apple", authHandler.AppleSignIn)
			auth.POST("/login", authHandler.Login)
			auth.POST("/refresh", authHandler.RefreshToken)
		}

		// Protected routes (require authentication)
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware(jwtService))
		{
			// User routes
			protected.GET("/auth/me", authHandler.GetCurrentUser)

			// Dashboard route
			protected.GET("/dashboard", dashboardHandler.GetDashboard)

			// Invoice dashboard route
			protected.GET("/invoices/dashboard", invoiceHandler.GetInvoicesDashboard)
		}

		// Yacht routes (public - no authentication required for browsing)
		yachts := v1.Group("/yachts")
		{
			yachts.GET("", yachtHandler.ListYachts)
			yachts.GET("/:id", yachtHandler.GetYacht)
		}

		// Owner routes (public - no authentication required for browsing)
		owners := v1.Group("/owners")
		{
			owners.GET("", userHandler.ListOwners)
			owners.GET("/:id", userHandler.GetOwner)
		}

		// Logbook routes
		logbook := v1.Group("/logbook")
		{
			// Public routes - anyone can view logs
			logbook.GET("", logbookHandler.ListLogbookEntries)
			logbook.GET("/:id", logbookHandler.GetLogbookEntry)
		}

		// Protected logbook routes - require authentication
		protectedLogbook := v1.Group("/logbook")
		protectedLogbook.Use(middleware.AuthMiddleware(jwtService))
		{
			protectedLogbook.POST("", logbookHandler.CreateLogbookEntry)
		}

		// Booking routes
		bookings := v1.Group("/bookings")
		{
			bookings.GET("", bookingHandler.ListBookings)
			bookings.GET("/:id", bookingHandler.GetBooking)
			bookings.GET("/:id/detail", bookingHandler.GetBookingDetail)
		}

		// Invoice routes (to be implemented)
		invoices := v1.Group("/invoices")
		{
			invoices.GET("", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "List Invoices - Not Implemented"})
			})
		}

		// Maintenance routes (to be implemented)
		maintenance := v1.Group("/maintenance-requests")
		{
			maintenance.GET("", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "List Maintenance Requests - Not Implemented"})
			})
		}

		// Activity routes (public - no authentication required for now)
		activity := v1.Group("/activity")
		{
			activity.GET("/recent", activityHandler.GetRecentActivity)
		}
	}
}
