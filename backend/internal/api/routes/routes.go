package routes

import (
	"github.com/bitcoinbrisbane/yachtlife/internal/config"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// SetupRoutes configures all API routes
func SetupRoutes(router *gin.Engine, db *gorm.DB, cfg *config.Config) {
	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Auth routes (to be implemented)
		auth := v1.Group("/auth")
		{
			auth.POST("/apple", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "Apple Sign In - Not Implemented"})
			})
			auth.POST("/login", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "Login - Not Implemented"})
			})
			auth.POST("/register", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "Register - Not Implemented"})
			})
		}

		// Yacht routes (to be implemented)
		yachts := v1.Group("/yachts")
		{
			yachts.GET("", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "List Yachts - Not Implemented"})
			})
			yachts.GET("/:id", func(c *gin.Context) {
				c.JSON(501, gin.H{"message": "Get Yacht - Not Implemented"})
			})
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
