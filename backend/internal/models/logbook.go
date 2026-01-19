package models

import (
	"time"

	"github.com/google/uuid"
)

type LogbookEntryType string

const (
	EntryTypeDeparture   LogbookEntryType = "departure"
	EntryTypeReturn      LogbookEntryType = "return"
	EntryTypeFuel        LogbookEntryType = "fuel"
	EntryTypeMaintenance LogbookEntryType = "maintenance"
	EntryTypeGeneral     LogbookEntryType = "general"
	EntryTypeIncident    LogbookEntryType = "incident"
)

type LogbookEntry struct {
	ID            uuid.UUID        `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	YachtID       uuid.UUID        `gorm:"type:uuid;not null;index" json:"yacht_id"`
	BookingID     *uuid.UUID       `gorm:"type:uuid;index" json:"booking_id,omitempty"`
	UserID        uuid.UUID        `gorm:"type:uuid;not null;index" json:"user_id"`
	EntryType     LogbookEntryType `gorm:"type:varchar(20);not null;index" json:"entry_type"`
	FuelLiters    *float64         `gorm:"type:decimal(10,2)" json:"fuel_liters,omitempty"`
	FuelCost      *float64         `gorm:"type:decimal(10,2)" json:"fuel_cost,omitempty"`
	HoursOperated *float64         `gorm:"type:decimal(10,2)" json:"hours_operated,omitempty"`
	Notes         string           `gorm:"type:text" json:"notes,omitempty"`
	CreatedAt     time.Time        `gorm:"index" json:"created_at"`

	// Relationships
	Yacht   Yacht    `gorm:"foreignKey:YachtID;constraint:OnDelete:CASCADE" json:"yacht,omitempty"`
	Booking *Booking `gorm:"foreignKey:BookingID" json:"booking,omitempty"`
	User    User     `gorm:"foreignKey:UserID" json:"user,omitempty"`
}

func (LogbookEntry) TableName() string {
	return "logbook_entries"
}
