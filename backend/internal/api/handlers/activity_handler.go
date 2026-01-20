package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ActivityHandler handles activity requests
type ActivityHandler struct {
	db *gorm.DB
}

// NewActivityHandler creates a new activity handler
func NewActivityHandler(db *gorm.DB) *ActivityHandler {
	return &ActivityHandler{db: db}
}

// ActivityType represents the type of activity
type ActivityType string

const (
	ActivityTypeChecklist    ActivityType = "checklist"
	ActivityTypeFuel         ActivityType = "fuel"
	ActivityTypePayment      ActivityType = "payment"
	ActivityTypeMaintenance  ActivityType = "maintenance"
	ActivityTypeBooking      ActivityType = "booking"
)

// RecentActivityItem represents a single activity item
type RecentActivityItem struct {
	ID          string       `json:"id"`
	Type        ActivityType `json:"type"`
	Title       string       `json:"title"`
	Subtitle    string       `json:"subtitle"`
	Icon        string       `json:"icon"`  // SF Symbol name
	Color       string       `json:"color"` // hex color
	Timestamp   time.Time    `json:"timestamp"`
	RelatedID   *uuid.UUID   `json:"related_id,omitempty"`   // booking_id, invoice_id, etc.
	RelatedType *string      `json:"related_type,omitempty"` // "booking", "invoice", etc.
}

// RecentActivityResponse represents the response for recent activity
type RecentActivityResponse struct {
	Activities []RecentActivityItem `json:"activities"`
}

// GetRecentActivity returns recent activity for a yacht
// GET /api/v1/activity/recent?yacht_id={id}
func (h *ActivityHandler) GetRecentActivity(c *gin.Context) {
	// yachtID := c.Query("yacht_id") // Optional yacht filter - will use in Phase 2

	// Mock data for now (Phase 1)
	// In Phase 2, we'll aggregate from logbook_entries, payments, maintenance_requests, checklists, bookings
	activities := []RecentActivityItem{
		{
			ID:        uuid.New().String(),
			Type:      ActivityTypeChecklist,
			Title:     "Checklist Completed",
			Subtitle:  "Pre-departure checklist",
			Icon:      "checkmark.circle.fill",
			Color:     "#10B981", // green
			Timestamp: time.Now().Add(-2 * time.Hour),
		},
		{
			ID:        uuid.New().String(),
			Type:      ActivityTypeFuel,
			Title:     "Fuel Added",
			Subtitle:  "450L at Gold Coast Marina",
			Icon:      "fuelpump.fill",
			Color:     "#3B82F6", // blue
			Timestamp: time.Now().Add(-24 * time.Hour),
		},
		{
			ID:        uuid.New().String(),
			Type:      ActivityTypePayment,
			Title:     "Payment Received",
			Subtitle:  "Invoice #1023 - $2,450",
			Icon:      "dollarsign.circle.fill",
			Color:     "#F59E0B", // orange
			Timestamp: time.Now().Add(-72 * time.Hour),
		},
	}

	c.JSON(http.StatusOK, RecentActivityResponse{Activities: activities})
}
