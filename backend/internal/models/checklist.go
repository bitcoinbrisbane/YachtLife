package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

type ChecklistType string

const (
	ChecklistTypePreDeparture ChecklistType = "pre_departure"
	ChecklistTypeReturn       ChecklistType = "return"
)

type Checklist struct {
	ID          uuid.UUID     `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	BookingID   uuid.UUID     `gorm:"type:uuid;not null;index" json:"booking_id"`
	Type        ChecklistType `gorm:"type:varchar(20);not null" json:"checklist_type"`
	Completed   bool          `gorm:"default:false" json:"completed"`
	CompletedAt *time.Time    `json:"completed_at,omitempty"`
	CompletedBy *uuid.UUID    `gorm:"type:uuid" json:"completed_by,omitempty"`
	Items       datatypes.JSON `gorm:"type:jsonb;not null" json:"items"` // Flexible checklist items
	CreatedAt   time.Time     `json:"created_at"`
	UpdatedAt   time.Time     `json:"updated_at"`

	// Relationships
	Booking         Booking `gorm:"foreignKey:BookingID;constraint:OnDelete:CASCADE" json:"booking,omitempty"`
	CompletedByUser *User   `gorm:"foreignKey:CompletedBy" json:"completed_by_user,omitempty"`
}

func (Checklist) TableName() string {
	return "checklists"
}
