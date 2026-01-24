package models

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestDashboardViewModelJSONEncoding tests dashboard encoding
func TestDashboardViewModelJSONEncoding(t *testing.T) {
	now := time.Now()
	viewModel := DashboardViewModel{
		UserName:             "John Doe",
		PortEngineHours:      150.5,
		StarboardEngineHours: 152.0,
		FuelLiters:           500.0,
		HasDepartureLog:      false,
		HasReturnLog:         false,
		Vessel: VesselInfo{
			ID:           uuid.New(),
			Name:         "Test Yacht",
			Manufacturer: "Riviera",
			Model:        "72 SMY",
			Length:       72.0,
			HomePort:     "Gold Coast",
		},
		ActiveBooking: &BookingInfo{
			ID:        uuid.New(),
			StartDate: now,
			EndDate:   now.AddDate(0, 0, 3),
			Status:    "confirmed",
			Notes:     "Weekend trip",
		},
		UpcomingBookings: []BookingInfo{
			{
				ID:        uuid.New(),
				StartDate: now.AddDate(0, 0, 7),
				EndDate:   now.AddDate(0, 0, 10),
				Status:    "confirmed",
				Notes:     "Family trip",
			},
		},
		RecentActivities: []ActivityInfo{
			{
				Icon:     "calendar",
				Title:    "Booking Created",
				Subtitle: "Weekend trip",
				Time:     now,
				Color:    "blue",
			},
		},
	}

	// Encode to JSON
	data, err := json.Marshal(viewModel)
	require.NoError(t, err, "Failed to marshal DashboardViewModel to JSON")

	// Print JSON for debugging
	t.Logf("DashboardViewModel JSON: %s", string(data))

	// Verify JSON contains required fields with snake_case
	var jsonMap map[string]interface{}
	err = json.Unmarshal(data, &jsonMap)
	require.NoError(t, err)

	// Check critical fields exist
	assert.Contains(t, jsonMap, "user_name")
	assert.Contains(t, jsonMap, "port_engine_hours")
	assert.Contains(t, jsonMap, "starboard_engine_hours")
	assert.Contains(t, jsonMap, "fuel_liters")
	assert.Contains(t, jsonMap, "has_departure_log")
	assert.Contains(t, jsonMap, "has_return_log")
	assert.Contains(t, jsonMap, "upcoming_bookings")
	assert.Contains(t, jsonMap, "recent_activities")

	// Decode back
	var decoded DashboardViewModel
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err, "Failed to unmarshal DashboardViewModel from JSON")

	// Verify all fields
	assert.Equal(t, viewModel.UserName, decoded.UserName)
	assert.Equal(t, viewModel.PortEngineHours, decoded.PortEngineHours)
	assert.Equal(t, viewModel.StarboardEngineHours, decoded.StarboardEngineHours)
	assert.Equal(t, viewModel.FuelLiters, decoded.FuelLiters)
	assert.Equal(t, viewModel.HasDepartureLog, decoded.HasDepartureLog)
	assert.Equal(t, viewModel.HasReturnLog, decoded.HasReturnLog)
	assert.NotNil(t, decoded.ActiveBooking)
	assert.Equal(t, len(viewModel.UpcomingBookings), len(decoded.UpcomingBookings))
}

// TestDashboardViewModelWithNilActiveBooking tests encoding when no active booking
func TestDashboardViewModelWithNilActiveBooking(t *testing.T) {
	viewModel := DashboardViewModel{
		UserName:             "John Doe",
		PortEngineHours:      150.5,
		StarboardEngineHours: 152.0,
		FuelLiters:           500.0,
		HasDepartureLog:      false,
		HasReturnLog:         false,
		Vessel: VesselInfo{
			ID:           uuid.New(),
			Name:         "Test Yacht",
			Manufacturer: "Riviera",
			Model:        "72 SMY",
			Length:       72.0,
			HomePort:     "Gold Coast",
		},
		ActiveBooking:    nil, // No active booking
		UpcomingBookings: []BookingInfo{},
		RecentActivities: []ActivityInfo{},
	}

	// Encode to JSON
	data, err := json.Marshal(viewModel)
	require.NoError(t, err, "Failed to marshal DashboardViewModel to JSON")

	// Verify has_departure_log and has_return_log are present even when false
	var jsonMap map[string]interface{}
	err = json.Unmarshal(data, &jsonMap)
	require.NoError(t, err)

	// These fields MUST be present, not omitted
	hasDeparture, ok := jsonMap["has_departure_log"]
	assert.True(t, ok, "has_departure_log must be present in JSON")
	assert.Equal(t, false, hasDeparture)

	hasReturn, ok := jsonMap["has_return_log"]
	assert.True(t, ok, "has_return_log must be present in JSON")
	assert.Equal(t, false, hasReturn)

	// Decode back
	var decoded DashboardViewModel
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err, "Failed to unmarshal DashboardViewModel from JSON")

	// Verify fields are correct
	assert.Nil(t, decoded.ActiveBooking)
	assert.False(t, decoded.HasDepartureLog)
	assert.False(t, decoded.HasReturnLog)
	assert.Empty(t, decoded.UpcomingBookings)
	assert.Empty(t, decoded.RecentActivities)
}

// TestBookingInfoJSONEncoding tests BookingInfo encoding
func TestBookingInfoJSONEncoding(t *testing.T) {
	now := time.Now()
	booking := BookingInfo{
		ID:        uuid.New(),
		StartDate: now,
		EndDate:   now.AddDate(0, 0, 3),
		Status:    "confirmed",
		Notes:     "Weekend trip",
	}

	// Encode to JSON
	data, err := json.Marshal(booking)
	require.NoError(t, err, "Failed to marshal BookingInfo to JSON")

	// Verify snake_case
	var jsonMap map[string]interface{}
	err = json.Unmarshal(data, &jsonMap)
	require.NoError(t, err)

	assert.Contains(t, jsonMap, "start_date")
	assert.Contains(t, jsonMap, "end_date")

	// Decode back
	var decoded BookingInfo
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err, "Failed to unmarshal BookingInfo from JSON")

	assert.Equal(t, booking.ID, decoded.ID)
	assert.Equal(t, booking.Status, decoded.Status)
	assert.Equal(t, booking.Notes, decoded.Notes)
}

// TestActivityInfoJSONEncoding tests ActivityInfo encoding
func TestActivityInfoJSONEncoding(t *testing.T) {
	now := time.Now()
	activity := ActivityInfo{
		Icon:     "calendar",
		Title:    "Booking Created",
		Subtitle: "Weekend trip",
		Time:     now,
		Color:    "blue",
	}

	// Encode to JSON
	data, err := json.Marshal(activity)
	require.NoError(t, err, "Failed to marshal ActivityInfo to JSON")

	// Decode back
	var decoded ActivityInfo
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err, "Failed to unmarshal ActivityInfo from JSON")

	assert.Equal(t, activity.Icon, decoded.Icon)
	assert.Equal(t, activity.Title, decoded.Title)
	assert.Equal(t, activity.Subtitle, decoded.Subtitle)
	assert.Equal(t, activity.Color, decoded.Color)
}
