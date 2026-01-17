package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

type NotificationType string
type NotificationStatus string

const (
	NotificationTypeBooking      NotificationType = "booking"
	NotificationTypeInvoice      NotificationType = "invoice"
	NotificationTypeMaintenance  NotificationType = "maintenance"
	NotificationTypeVote         NotificationType = "vote"
	NotificationTypeAnnouncement NotificationType = "announcement"
	NotificationTypeReminder     NotificationType = "reminder"

	NotificationStatusPending   NotificationStatus = "pending"
	NotificationStatusSent      NotificationStatus = "sent"
	NotificationStatusFailed    NotificationStatus = "failed"
	NotificationStatusDelivered NotificationStatus = "delivered"
	NotificationStatusRead      NotificationStatus = "read"
)

type Notification struct {
	ID          uuid.UUID          `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	UserID      *uuid.UUID         `gorm:"type:uuid;index" json:"user_id,omitempty"` // null for broadcast
	Title       string             `gorm:"size:255;not null" json:"title"`
	Message     string             `gorm:"type:text;not null" json:"message"`
	Type        NotificationType   `gorm:"type:varchar(20);not null;index" json:"type"`
	Channels    datatypes.JSON     `gorm:"type:jsonb;not null" json:"channels"` // Array: ['push', 'email', 'sms']
	Status      NotificationStatus `gorm:"type:varchar(20);not null;index;default:'pending'" json:"status"`
	RelatedID   *uuid.UUID         `gorm:"type:uuid" json:"related_id,omitempty"`   // ID of related entity
	RelatedType string             `gorm:"size:50" json:"related_type,omitempty"`    // Type of related entity
	ScheduledAt *time.Time         `gorm:"index" json:"scheduled_at,omitempty"`
	SentAt      *time.Time         `json:"sent_at,omitempty"`
	ReadAt      *time.Time         `json:"read_at,omitempty"`
	CreatedAt   time.Time          `json:"created_at"`

	// Relationships
	User *User `gorm:"foreignKey:UserID" json:"user,omitempty"`
}

func (Notification) TableName() string {
	return "notifications"
}
