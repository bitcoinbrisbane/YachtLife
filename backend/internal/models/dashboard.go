package models

import (
	"time"

	"github.com/google/uuid"
)

type DashboardViewModel struct {
	// Welcome section
	UserName string `json:"user_name"`

	// Vessel details
	Vessel VesselInfo `json:"vessel"`

	// Latest user-specific logbook data
	PortEngineHours      float64 `json:"port_engine_hours"`
	StarboardEngineHours float64 `json:"starboard_engine_hours"`
	FuelLiters           float64 `json:"fuel_liters"`

	// Booking status
	ActiveBooking   *BookingInfo `json:"active_booking,omitempty"`
	HasDepartureLog bool         `json:"has_departure_log"`
	HasReturnLog    bool         `json:"has_return_log"`

	// Upcoming bookings (next 3)
	UpcomingBookings []BookingInfo `json:"upcoming_bookings"`

	// Recent activity (last 5)
	RecentActivities []ActivityInfo `json:"recent_activities"`
}

type VesselInfo struct {
	ID           uuid.UUID `json:"id"`
	Name         string    `json:"name"`
	Manufacturer string    `json:"manufacturer"`
	Model        string    `json:"model"`
	Length       float64   `json:"length"`
	HomePort     string    `json:"home_port"`
}

type BookingInfo struct {
	ID        uuid.UUID `json:"id"`
	StartDate time.Time `json:"start_date"`
	EndDate   time.Time `json:"end_date"`
	Status    string    `json:"status"`
	Notes     string    `json:"notes"`
}

type ActivityInfo struct {
	Icon     string    `json:"icon"`
	Title    string    `json:"title"`
	Subtitle string    `json:"subtitle"`
	Time     time.Time `json:"time"`
	Color    string    `json:"color"`
}
