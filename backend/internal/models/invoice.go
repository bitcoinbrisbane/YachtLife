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

// InvoiceViewModel - Aggregated view for invoice dashboard
type InvoiceViewModel struct {
	Stats            InvoiceStats      `json:"stats"`
	Invoices         []InvoiceInfo     `json:"invoices"`
	RecentActivities []InvoiceActivity `json:"recent_activities"`
}

// InvoiceStats - Summary statistics for invoices
type InvoiceStats struct {
	TotalOutstanding float64 `json:"total_outstanding"`
	PaidCount        int     `json:"paid_count"`
	OverdueCount     int     `json:"overdue_count"`
	PendingCount     int     `json:"pending_count"`
	DraftCount       int     `json:"draft_count"`
}

// InvoiceInfo - Simplified invoice data for list view
type InvoiceInfo struct {
	ID            uuid.UUID `json:"id"`
	InvoiceNumber string    `json:"invoice_number"`
	Description   string    `json:"description"`
	Amount        float64   `json:"amount"`
	DueDate       time.Time `json:"due_date"`
	IssuedDate    time.Time `json:"issued_date"`
	Status        string    `json:"status"`
	IsOverdue     bool      `json:"is_overdue"`
	DaysUntilDue  int       `json:"days_until_due"`
}

// InvoiceActivity - Recent invoice-related activity
type InvoiceActivity struct {
	Icon     string    `json:"icon"`
	Title    string    `json:"title"`
	Subtitle string    `json:"subtitle"`
	Time     time.Time `json:"time"`
	Color    string    `json:"color"`
}
