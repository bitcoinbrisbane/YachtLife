package handlers

import (
	"net/http"
	"time"

	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type DashboardHandler struct {
	db *gorm.DB
}

func NewDashboardHandler(db *gorm.DB) *DashboardHandler {
	return &DashboardHandler{db: db}
}

func (h *DashboardHandler) GetDashboard(c *gin.Context) {
	// Get authenticated user
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "user not authenticated"})
		return
	}
	uid := userID.(uuid.UUID)

	// Get yacht_id from query
	yachtIDStr := c.Query("yacht_id")
	if yachtIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "yacht_id required"})
		return
	}

	yachtID, err := uuid.Parse(yachtIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid yacht_id"})
		return
	}

	viewModel := models.DashboardViewModel{
		UpcomingBookings: []models.BookingInfo{},
		RecentActivities: []models.ActivityInfo{},
	}

	// 1. Get user info
	var user models.User
	if err := h.db.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}
	viewModel.UserName = user.FirstName + " " + user.LastName

	// 2. Get vessel info
	var yacht models.Yacht
	if err := h.db.First(&yacht, yachtID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "yacht not found"})
		return
	}
	viewModel.Vessel = models.VesselInfo{
		ID:           yacht.ID,
		Name:         yacht.Name,
		Manufacturer: yacht.Manufacturer,
		Model:        yacht.Model,
		Length:       yacht.LengthFeet,
		HomePort:     yacht.HomePort,
	}

	// 3. Get latest USER-SPECIFIC logbook entry
	var latestLog models.LogbookEntry
	err = h.db.Where("yacht_id = ? AND user_id = ?", yachtID, uid).
		Order("created_at DESC").
		First(&latestLog).Error

	if err == nil {
		// Found user's logs - use actual values
		if latestLog.PortEngineHours != nil {
			viewModel.PortEngineHours = *latestLog.PortEngineHours
		}
		if latestLog.StarboardEngineHours != nil {
			viewModel.StarboardEngineHours = *latestLog.StarboardEngineHours
		}
		if latestLog.FuelLiters != nil {
			viewModel.FuelLiters = *latestLog.FuelLiters
		}
	} else {
		// No logs found - use 0 as per requirements
		viewModel.PortEngineHours = 0
		viewModel.StarboardEngineHours = 0
		viewModel.FuelLiters = 0
	}

	// 4. Check for active booking
	now := time.Now()
	var activeBooking models.Booking
	err = h.db.Where("yacht_id = ? AND user_id = ? AND start_date <= ? AND end_date >= ? AND status IN (?, ?)",
		yachtID, uid, now, now, "confirmed", "in_progress").
		First(&activeBooking).Error

	if err == nil {
		viewModel.ActiveBooking = &models.BookingInfo{
			ID:          activeBooking.ID,
			StartDate:   activeBooking.StartDate,
			EndDate:     activeBooking.EndDate,
			Status:      string(activeBooking.Status),
			StandbyDays: activeBooking.StandbyDays,
			Notes:       activeBooking.Notes,
		}

		// Check for departure log
		var departureLog models.LogbookEntry
		err = h.db.Where("booking_id = ? AND entry_type = ?", activeBooking.ID, "depart").
			First(&departureLog).Error
		viewModel.HasDepartureLog = (err == nil)
	}

	// 5. Get upcoming bookings (next 3 for this user)
	var bookings []models.Booking
	h.db.Where("yacht_id = ? AND user_id = ? AND start_date >= ?", yachtID, uid, now).
		Order("start_date ASC").
		Limit(3).
		Find(&bookings)

	for _, b := range bookings {
		viewModel.UpcomingBookings = append(viewModel.UpcomingBookings, models.BookingInfo{
			ID:          b.ID,
			StartDate:   b.StartDate,
			EndDate:     b.EndDate,
			Status:      string(b.Status),
			StandbyDays: b.StandbyDays,
			Notes:       b.Notes,
		})
	}

	// 6. Get recent activities (last 5)
	// Build activities from recent bookings and logbook entries
	type activitySource struct {
		Type      string
		Time      time.Time
		EntryType string
		Notes     string
	}

	var activities []activitySource

	// Get recent bookings
	var recentBookings []models.Booking
	h.db.Where("yacht_id = ? AND user_id = ?", yachtID, uid).
		Order("created_at DESC").
		Limit(3).
		Find(&recentBookings)

	for _, b := range recentBookings {
		activities = append(activities, activitySource{
			Type:  "booking",
			Time:  b.CreatedAt,
			Notes: b.Notes,
		})
	}

	// Get recent logbook entries
	var recentLogs []models.LogbookEntry
	h.db.Where("yacht_id = ? AND user_id = ?", yachtID, uid).
		Order("created_at DESC").
		Limit(3).
		Find(&recentLogs)

	for _, l := range recentLogs {
		activities = append(activities, activitySource{
			Type:      "logbook",
			Time:      l.CreatedAt,
			EntryType: string(l.EntryType),
			Notes:     l.Notes,
		})
	}

	// Sort by time and take top 5
	// Simple bubble sort for small dataset
	for i := 0; i < len(activities); i++ {
		for j := i + 1; j < len(activities); j++ {
			if activities[j].Time.After(activities[i].Time) {
				activities[i], activities[j] = activities[j], activities[i]
			}
		}
	}

	// Convert to ActivityInfo
	limit := 5
	if len(activities) < limit {
		limit = len(activities)
	}

	for i := 0; i < limit; i++ {
		a := activities[i]
		var icon, title, subtitle, color string

		if a.Type == "booking" {
			icon = "calendar"
			title = "Booking Created"
			subtitle = a.Notes
			color = "blue"
		} else {
			// logbook entry
			switch a.EntryType {
			case "depart":
				icon = "arrow.up.right"
				title = "Departure"
				subtitle = a.Notes
				color = "green"
			case "return":
				icon = "arrow.down.left"
				title = "Return"
				subtitle = a.Notes
				color = "orange"
			default:
				icon = "doc.text"
				title = "Log Entry"
				subtitle = a.Notes
				color = "gray"
			}
		}

		viewModel.RecentActivities = append(viewModel.RecentActivities, models.ActivityInfo{
			Icon:     icon,
			Title:    title,
			Subtitle: subtitle,
			Time:     a.Time,
			Color:    color,
		})
	}

	c.JSON(http.StatusOK, viewModel)
}
