package models

import (
	"time"

	"github.com/google/uuid"
)

type SyndicateShare struct {
	ID              uuid.UUID `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	YachtID         uuid.UUID `gorm:"type:uuid;not null;index" json:"yacht_id"`
	UserID          uuid.UUID `gorm:"type:uuid;not null;index" json:"user_id"`
	SharePercentage float64   `gorm:"type:decimal(5,2);not null" json:"share_percentage"`
	DaysPerYear     int       `gorm:"not null" json:"days_per_year"`
	JoinedDate      time.Time `gorm:"type:date" json:"joined_date"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`

	// Relationships
	Yacht Yacht `gorm:"foreignKey:YachtID;constraint:OnDelete:CASCADE" json:"yacht,omitempty"`
	User  User  `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

func (SyndicateShare) TableName() string {
	return "syndicate_shares"
}
