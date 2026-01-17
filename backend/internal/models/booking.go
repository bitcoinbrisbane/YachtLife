package models

import (
	"time"

	"github.com/google/uuid"
)

type BookingStatus string
type BookingType string

const (
	BookingStatusPending   BookingStatus = "pending"
	BookingStatusConfirmed BookingStatus = "confirmed"
	BookingStatusCancelled BookingStatus = "cancelled"
	BookingStatusCompleted BookingStatus = "completed"

	BookingTypeRegular BookingType = "regular"
	BookingTypeStandby BookingType = "standby"
)

type Booking struct {
	ID          uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	YachtID     uuid.UUID      `gorm:"type:uuid;not null;index" json:"yacht_id"`
	UserID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	StartDate   time.Time      `gorm:"not null;index" json:"start_date"`
	EndDate     time.Time      `gorm:"not null;index" json:"end_date"`
	Status      BookingStatus  `gorm:"type:varchar(20);not null;index;default:'pending'" json:"status"`
	BookingType BookingType    `gorm:"type:varchar(20);not null;default:'regular'" json:"booking_type"`
	IsStandby   bool           `gorm:"default:false" json:"is_standby"`
	Notes       string         `gorm:"type:text" json:"notes,omitempty"`
	CancelledAt *time.Time     `json:"cancelled_at,omitempty"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`

	// Relationships
	Yacht Yacht `gorm:"foreignKey:YachtID;constraint:OnDelete:CASCADE" json:"yacht,omitempty"`
	User  User  `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

func (Booking) TableName() string {
	return "bookings"
}

type BookingChangeRequestStatus string

const (
	ChangeRequestStatusPending  BookingChangeRequestStatus = "pending"
	ChangeRequestStatusApproved BookingChangeRequestStatus = "approved"
	ChangeRequestStatusRejected BookingChangeRequestStatus = "rejected"
)

type BookingChangeRequest struct {
	ID                 uuid.UUID                  `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	BookingID          uuid.UUID                  `gorm:"type:uuid;not null;index" json:"booking_id"`
	RequestedBy        uuid.UUID                  `gorm:"type:uuid;not null" json:"requested_by"`
	ProposedStartDate  time.Time                  `json:"proposed_start_date"`
	ProposedEndDate    time.Time                  `json:"proposed_end_date"`
	Reason             string                     `gorm:"type:text" json:"reason"`
	Status             BookingChangeRequestStatus `gorm:"type:varchar(20);not null;default:'pending'" json:"status"`
	CreatedAt          time.Time                  `json:"created_at"`
	UpdatedAt          time.Time                  `json:"updated_at"`

	// Relationships
	Booking     Booking `gorm:"foreignKey:BookingID;constraint:OnDelete:CASCADE" json:"booking,omitempty"`
	RequestedByUser User `gorm:"foreignKey:RequestedBy" json:"requested_by_user,omitempty"`
}

func (BookingChangeRequest) TableName() string {
	return "booking_change_requests"
}
