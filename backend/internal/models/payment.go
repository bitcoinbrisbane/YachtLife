package models

import (
	"time"

	"github.com/google/uuid"
)

type PaymentMethod string
type PaymentStatus string

const (
	PaymentMethodApplePay  PaymentMethod = "apple_pay"
	PaymentMethodGooglePay PaymentMethod = "google_pay"
	PaymentMethodCard      PaymentMethod = "card"

	PaymentStatusPending   PaymentStatus = "pending"
	PaymentStatusCompleted PaymentStatus = "completed"
	PaymentStatusFailed    PaymentStatus = "failed"
	PaymentStatusRefunded  PaymentStatus = "refunded"
)

type Payment struct {
	ID              uuid.UUID     `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	InvoiceID       uuid.UUID     `gorm:"type:uuid;not null;index" json:"invoice_id"`
	UserID          uuid.UUID     `gorm:"type:uuid;not null;index" json:"user_id"`
	Amount          float64       `gorm:"type:decimal(10,2);not null" json:"amount"`
	PaymentMethod   PaymentMethod `gorm:"type:varchar(20);not null" json:"payment_method"`
	StripePaymentID string        `gorm:"size:255;index" json:"stripe_payment_id,omitempty"`
	XeroPaymentID   string        `gorm:"size:255" json:"xero_payment_id,omitempty"`
	Status          PaymentStatus `gorm:"type:varchar(20);not null;default:'pending'" json:"status"`
	PaidAt          *time.Time    `json:"paid_at,omitempty"`
	XeroSyncedAt    *time.Time    `json:"xero_synced_at,omitempty"`
	CreatedAt       time.Time     `json:"created_at"`

	// Relationships
	Invoice Invoice `gorm:"foreignKey:InvoiceID;constraint:OnDelete:CASCADE" json:"invoice,omitempty"`
	User    User    `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

func (Payment) TableName() string {
	return "payments"
}
