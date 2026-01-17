package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

type MaintenanceUrgency string
type MaintenanceStatus string

const (
	UrgencyLow      MaintenanceUrgency = "low"
	UrgencyMedium   MaintenanceUrgency = "medium"
	UrgencyHigh     MaintenanceUrgency = "high"
	UrgencyCritical MaintenanceUrgency = "critical"

	MaintenanceStatusSubmitted     MaintenanceStatus = "submitted"
	MaintenanceStatusAcknowledged  MaintenanceStatus = "acknowledged"
	MaintenanceStatusInProgress    MaintenanceStatus = "in_progress"
	MaintenanceStatusCompleted     MaintenanceStatus = "completed"
	MaintenanceStatusCancelled     MaintenanceStatus = "cancelled"
)

type MaintenanceRequest struct {
	ID            uuid.UUID          `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	YachtID       uuid.UUID          `gorm:"type:uuid;not null;index" json:"yacht_id"`
	UserID        uuid.UUID          `gorm:"type:uuid;not null;index" json:"user_id"`
	BookingID     *uuid.UUID         `gorm:"type:uuid" json:"booking_id,omitempty"`
	Title         string             `gorm:"size:255;not null" json:"title"`
	Description   string             `gorm:"type:text;not null" json:"description"`
	Urgency       MaintenanceUrgency `gorm:"type:varchar(20);not null;index" json:"urgency"`
	Status        MaintenanceStatus  `gorm:"type:varchar(20);not null;index;default:'submitted'" json:"status"`
	Photos        datatypes.JSON     `gorm:"type:jsonb" json:"photos,omitempty"` // Array of S3 URLs
	Location      string             `gorm:"size:255" json:"location,omitempty"` // e.g., "Port Engine", "Galley"
	EstimatedCost *float64           `gorm:"type:decimal(10,2)" json:"estimated_cost,omitempty"`
	ActualCost    *float64           `gorm:"type:decimal(10,2)" json:"actual_cost,omitempty"`
	AssignedTo    string             `gorm:"size:255" json:"assigned_to,omitempty"` // Service provider name
	ScheduledDate *time.Time         `gorm:"type:date" json:"scheduled_date,omitempty"`
	CompletedDate *time.Time         `gorm:"type:date" json:"completed_date,omitempty"`
	CompletedBy   *uuid.UUID         `gorm:"type:uuid" json:"completed_by,omitempty"`
	Notes         string             `gorm:"type:text" json:"notes,omitempty"` // Manager notes
	CreatedAt     time.Time          `gorm:"index" json:"created_at"`
	UpdatedAt     time.Time          `json:"updated_at"`

	// Relationships
	Yacht           Yacht    `gorm:"foreignKey:YachtID;constraint:OnDelete:CASCADE" json:"yacht,omitempty"`
	User            User     `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Booking         *Booking `gorm:"foreignKey:BookingID" json:"booking,omitempty"`
	CompletedByUser *User    `gorm:"foreignKey:CompletedBy" json:"completed_by_user,omitempty"`
}

func (MaintenanceRequest) TableName() string {
	return "maintenance_requests"
}
