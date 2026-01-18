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
		}

		// Yacht routes (public - no authentication required for browsing)
		yachts := v1.Group("/yachts")
		{
			yachts.GET("", yachtHandler.ListYachts)
			yachts.GET("/:id", yachtHandler.GetYacht)
		}

		// Booking routes (to be implemented)
		bookings := v1.Group("/bookings")
		{
			bookings.GET("", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "List Bookings - Not Implemented"})
			})
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
	}
}
