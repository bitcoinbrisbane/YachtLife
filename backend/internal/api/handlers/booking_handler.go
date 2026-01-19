package handlers

import (
	"net/http"

	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type BookingHandler struct {
	db *gorm.DB
}

func NewBookingHandler(db *gorm.DB) *BookingHandler {
	return &BookingHandler{db: db}
}

// ListBookings returns all bookings with optional filtering by yacht_id
func (h *BookingHandler) ListBookings(c *gin.Context) {
	var bookings []models.Booking

	query := h.db.Preload("Yacht").Preload("User").Order("start_date ASC")

	// Filter by yacht_id if provided
	if yachtID := c.Query("yacht_id"); yachtID != "" {
		query = query.Where("yacht_id = ?", yachtID)
	}

	// Filter by user_id if provided
	if userID := c.Query("user_id"); userID != "" {
		query = query.Where("user_id = ?", userID)
	}

	// Filter by status if provided
	if status := c.Query("status"); status != "" {
		query = query.Where("status = ?", status)
	}

	if err := query.Find(&bookings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch bookings"})
		return
	}

	c.JSON(http.StatusOK, bookings)
}

// GetBooking returns a single booking by ID
func (h *BookingHandler) GetBooking(c *gin.Context) {
	id := c.Param("id")

	var booking models.Booking
	if err := h.db.Preload("Yacht").Preload("User").Where("id = ?", id).First(&booking).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch booking"})
		return
	}

	c.JSON(http.StatusOK, booking)
}
