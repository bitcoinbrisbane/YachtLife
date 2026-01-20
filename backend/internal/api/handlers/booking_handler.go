package handlers

import (
	"net/http"
	"time"

	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BookingHandler struct {
	db *gorm.DB
}

// BookingDetailViewModel represents detailed booking information with logbook data
type BookingDetailViewModel struct {
	Booking             models.Booking  `json:"booking"`
	DepartureLog        *LogbookSummary `json:"departure_log"`
	ReturnLog           *LogbookSummary `json:"return_log"`
	FuelConsumed        *float64        `json:"fuel_consumed"`        // liters
	PortHoursDelta      *float64        `json:"port_hours_delta"`     // hours
	StarboardHoursDelta *float64        `json:"starboard_hours_delta"` // hours
	HasLogbookData      bool            `json:"has_logbook_data"`
}

// LogbookSummary represents a summary of a logbook entry
type LogbookSummary struct {
	ID                   uuid.UUID `json:"id"`
	EntryType            string    `json:"entry_type"`
	PortEngineHours      *float64  `json:"port_engine_hours"`
	StarboardEngineHours *float64  `json:"starboard_engine_hours"`
	FuelLiters           *float64  `json:"fuel_liters"`
	CreatedAt            time.Time `json:"created_at"`
	Notes                string    `json:"notes,omitempty"`
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

// GetBookingDetail returns detailed booking information with logbook data and calculations
// GET /api/v1/bookings/:id/detail
func (h *BookingHandler) GetBookingDetail(c *gin.Context) {
	bookingID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid booking ID"})
		return
	}

	// Get booking with related data
	var booking models.Booking
	if err := h.db.Preload("Yacht").Preload("User").First(&booking, bookingID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Booking not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch booking"})
		return
	}

	// Get logbook entries for this booking
	var logEntries []models.LogbookEntry
	h.db.Where("booking_id = ?", bookingID).
		Order("created_at ASC").
		Find(&logEntries)

	// Initialize view model
	viewModel := BookingDetailViewModel{
		Booking:        booking,
		HasLogbookData: len(logEntries) > 0,
	}

	// Find departure and return logs
	var departLog, returnLog *models.LogbookEntry
	for i := range logEntries {
		entryTypeStr := string(logEntries[i].EntryType)
		if entryTypeStr == "depart" {
			departLog = &logEntries[i]
		} else if entryTypeStr == "return" {
			returnLog = &logEntries[i]
		}
	}

	// Build departure log summary
	if departLog != nil {
		viewModel.DepartureLog = &LogbookSummary{
			ID:                   departLog.ID,
			EntryType:            string(departLog.EntryType),
			PortEngineHours:      departLog.PortEngineHours,
			StarboardEngineHours: departLog.StarboardEngineHours,
			FuelLiters:           departLog.FuelLiters,
			CreatedAt:            departLog.CreatedAt,
			Notes:                departLog.Notes,
		}
	}

	// Build return log summary
	if returnLog != nil {
		viewModel.ReturnLog = &LogbookSummary{
			ID:                   returnLog.ID,
			EntryType:            string(returnLog.EntryType),
			PortEngineHours:      returnLog.PortEngineHours,
			StarboardEngineHours: returnLog.StarboardEngineHours,
			FuelLiters:           returnLog.FuelLiters,
			CreatedAt:            returnLog.CreatedAt,
			Notes:                returnLog.Notes,
		}
	}

	// Calculate deltas if we have both departure and return
	if departLog != nil && returnLog != nil {
		// Calculate fuel consumed (departure fuel - return fuel)
		if departLog.FuelLiters != nil && returnLog.FuelLiters != nil {
			consumed := *departLog.FuelLiters - *returnLog.FuelLiters
			viewModel.FuelConsumed = &consumed
		}

		// Calculate port engine hours delta (return hours - departure hours)
		if departLog.PortEngineHours != nil && returnLog.PortEngineHours != nil {
			portDelta := *returnLog.PortEngineHours - *departLog.PortEngineHours
			viewModel.PortHoursDelta = &portDelta
		}

		// Calculate starboard engine hours delta (return hours - departure hours)
		if departLog.StarboardEngineHours != nil && returnLog.StarboardEngineHours != nil {
			stbdDelta := *returnLog.StarboardEngineHours - *departLog.StarboardEngineHours
			viewModel.StarboardHoursDelta = &stbdDelta
		}
	}

	c.JSON(http.StatusOK, viewModel)
}
