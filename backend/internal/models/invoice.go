package models

import (
	"time"

	"github.com/google/uuid"
)

type InvoiceStatus string

const (
	InvoiceStatusDraft     InvoiceStatus = "draft"
	InvoiceStatusSent      InvoiceStatus = "sent"
	InvoiceStatusPaid      InvoiceStatus = "paid"
	InvoiceStatusOverdue   InvoiceStatus = "overdue"
	InvoiceStatusCancelled InvoiceStatus = "cancelled"
)

type Invoice struct {
	ID            uuid.UUID     `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	XeroInvoiceID string        `gorm:"uniqueIndex;size:255" json:"xero_invoice_id"` // Xero source of truth
	YachtID       uuid.UUID     `gorm:"type:uuid;not null;index" json:"yacht_id"`
	UserID        uuid.UUID     `gorm:"type:uuid;not null;index" json:"user_id"`
	InvoiceNumber string        `gorm:"uniqueIndex;size:100;not null" json:"invoice_number"`
	Description   string        `gorm:"type:text" json:"description"`
	Amount        float64       `gorm:"type:decimal(10,2);not null" json:"amount"`
	DueDate       time.Time     `gorm:"type:date;index" json:"due_date"`
	Status        InvoiceStatus `gorm:"type:varchar(20);not null;index;default:'draft'" json:"status"`
	IssuedDate    time.Time     `gorm:"type:date" json:"issued_date"`
	PaidDate      *time.Time    `gorm:"type:date" json:"paid_date,omitempty"`
	XeroSyncedAt  *time.Time    `json:"xero_synced_at,omitempty"`
	CreatedAt     time.Time     `json:"created_at"`
	UpdatedAt     time.Time     `json:"updated_at"`

	// Relationships
	Yacht Yacht `gorm:"foreignKey:YachtID;constraint:OnDelete:CASCADE" json:"yacht,omitempty"`
	User  User  `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

func (Invoice) TableName() string {
	return "invoices"
}
