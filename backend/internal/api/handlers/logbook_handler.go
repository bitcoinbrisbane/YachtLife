package handlers

import (
	"net/http"
	"time"

	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type LogbookHandler struct {
	db *gorm.DB
}

func NewLogbookHandler(db *gorm.DB) *LogbookHandler {
	return &LogbookHandler{db: db}
}

type CreateLogbookEntryRequest struct {
	YachtID       string   `json:"yacht_id" binding:"required"`
	EntryType     *string  `json:"entry_type"` // Optional - will be auto-detected if not provided
	FuelLiters    *float64 `json:"fuel_liters"`
	FuelCost      *float64 `json:"fuel_cost"`
	HoursOperated *float64 `json:"hours_operated"`
	Notes         string   `json:"notes"`
}

// DetectLogType determines if the log is a departure or return based on bookings
func (h *LogbookHandler) DetectLogType(yachtID, userID uuid.UUID, now time.Time) (models.LogbookEntryType, *uuid.UUID, error) {
	// Find an active booking for this yacht and user around the current time
	var booking models.Booking
	err := h.db.Where("yacht_id = ? AND user_id = ? AND start_date <= ? AND end_date >= ? AND status IN (?)",
		yachtID, userID, now, now, []string{string(models.BookingStatusConfirmed), string(models.BookingStatusPending)}).
		Order("start_date ASC").
		First(&booking).Error

	if err != nil {
		// No active booking found - return general log
		if err == gorm.ErrRecordNotFound {
			return models.EntryTypeGeneral, nil, nil
		}
		return models.EntryTypeGeneral, nil, err
	}

	// Check if there's already a departure log for this booking
	var departureLog models.LogbookEntry
	err = h.db.Where("booking_id = ? AND entry_type = ?", booking.ID, models.EntryTypeDeparture).
		First(&departureLog).Error

	if err == gorm.ErrRecordNotFound {
		// No departure log yet - this is a departure
		return models.EntryTypeDeparture, &booking.ID, nil
	} else if err != nil {
		return models.EntryTypeGeneral, &booking.ID, err
	}

	// Departure log exists - check if there's a return log
	var returnLog models.LogbookEntry
	err = h.db.Where("booking_id = ? AND entry_type = ?", booking.ID, models.EntryTypeReturn).
		First(&returnLog).Error

	if err == gorm.ErrRecordNotFound {
		// No return log yet - this is a return
		return models.EntryTypeReturn, &booking.ID, nil
	} else if err != nil {
		return models.EntryTypeGeneral, &booking.ID, err
	}

	// Both departure and return logs exist - general log
	return models.EntryTypeGeneral, &booking.ID, nil
}

// CreateLogbookEntry creates a new logbook entry with smart type detection
func (h *LogbookHandler) CreateLogbookEntry(c *gin.Context) {
	var req CreateLogbookEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get authenticated user ID from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	yachtID, err := uuid.Parse(req.YachtID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid yacht ID"})
		return
	}

	// userID is already a uuid.UUID from the auth middleware
	userUUID, ok := userID.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID type"})
		return
	}

	// Determine entry type
	var entryType models.LogbookEntryType
	var bookingID *uuid.UUID

	if req.EntryType != nil && *req.EntryType != "" {
		// Use provided entry type
		entryType = models.LogbookEntryType(*req.EntryType)
	} else {
		// Auto-detect entry type based on bookings
		detectedType, detectedBookingID, err := h.DetectLogType(yachtID, userUUID, time.Now())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to detect log type"})
			return
		}
		entryType = detectedType
		bookingID = detectedBookingID
	}

	// Create logbook entry
	entry := models.LogbookEntry{
		YachtID:       yachtID,
		UserID:        userUUID,
		BookingID:     bookingID,
		EntryType:     entryType,
		FuelLiters:    req.FuelLiters,
		FuelCost:      req.FuelCost,
		HoursOperated: req.HoursOperated,
		Notes:         req.Notes,
	}

	if err := h.db.Create(&entry).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create logbook entry"})
		return
	}

	// Load relationships
	h.db.Preload("Yacht").Preload("Booking").Preload("User").First(&entry, entry.ID)

	c.JSON(http.StatusCreated, entry)
}

// ListLogbookEntries returns all logbook entries with optional filtering
func (h *LogbookHandler) ListLogbookEntries(c *gin.Context) {
	var entries []models.LogbookEntry

	query := h.db.Preload("Yacht").Preload("Booking").Preload("User").Order("created_at DESC")

	// Filter by yacht_id if provided
	if yachtID := c.Query("yacht_id"); yachtID != "" {
		query = query.Where("yacht_id = ?", yachtID)
	}

	// Filter by user_id if provided
	if userID := c.Query("user_id"); userID != "" {
		query = query.Where("user_id = ?", userID)
	}

	// Filter by entry_type if provided
	if entryType := c.Query("entry_type"); entryType != "" {
		query = query.Where("entry_type = ?", entryType)
	}

	if err := query.Find(&entries).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch logbook entries"})
		return
	}

	c.JSON(http.StatusOK, entries)
}

// GetLogbookEntry returns a single logbook entry by ID
func (h *LogbookHandler) GetLogbookEntry(c *gin.Context) {
	id := c.Param("id")

	var entry models.LogbookEntry
	if err := h.db.Preload("Yacht").Preload("Booking").Preload("User").Where("id = ?", id).First(&entry).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Logbook entry not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch logbook entry"})
		return
	}

	c.JSON(http.StatusOK, entry)
}
