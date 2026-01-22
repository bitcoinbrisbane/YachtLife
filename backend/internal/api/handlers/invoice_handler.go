package handlers

import (
	"fmt"
	"net/http"
	"time"

	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type InvoiceHandler struct {
	db *gorm.DB
}

func NewInvoiceHandler(db *gorm.DB) *InvoiceHandler {
	return &InvoiceHandler{db: db}
}

// GetInvoicesDashboard returns aggregated invoice data for the dashboard
func (h *InvoiceHandler) GetInvoicesDashboard(c *gin.Context) {
	// Get authenticated user
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Safe type assertion with validation
	uid, ok := userID.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID type"})
		return
	}

	// Get yacht_id from query parameter (optional - if not provided, get all user's invoices)
	var yachtID *uuid.UUID
	if yachtIDStr := c.Query("yacht_id"); yachtIDStr != "" {
		parsedID, err := uuid.Parse(yachtIDStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid yacht_id"})
			return
		}
		yachtID = &parsedID
	}

	// Build query for user's invoices
	query := h.db.Where("user_id = ?", uid)
	if yachtID != nil {
		query = query.Where("yacht_id = ?", *yachtID)
	}

	// Get all invoices for this user (and yacht if specified)
	var invoices []models.Invoice
	if err := query.Order("due_date DESC").Find(&invoices).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch invoices"})
		return
	}

	// Calculate statistics
	stats := calculateInvoiceStats(invoices)

	// Build invoice info list
	invoiceInfoList := make([]models.InvoiceInfo, len(invoices))
	for i, inv := range invoices {
		daysUntilDue := int(time.Until(inv.DueDate).Hours() / 24)
		isOverdue := time.Now().After(inv.DueDate) && inv.Status != models.InvoiceStatusPaid

		invoiceInfoList[i] = models.InvoiceInfo{
			ID:            inv.ID,
			InvoiceNumber: inv.InvoiceNumber,
			Description:   inv.Description,
			Amount:        inv.Amount,
			DueDate:       inv.DueDate,
			IssuedDate:    inv.IssuedDate,
			Status:        string(inv.Status),
			IsOverdue:     isOverdue,
			DaysUntilDue:  daysUntilDue,
		}
	}

	// Get recent invoice activities (last 5)
	activities := getRecentInvoiceActivities(h.db, uid, yachtID)

	// Build response
	viewModel := models.InvoiceViewModel{
		Stats:            stats,
		Invoices:         invoiceInfoList,
		RecentActivities: activities,
	}

	c.JSON(http.StatusOK, viewModel)
}

// GetInvoice returns a single invoice by ID
func (h *InvoiceHandler) GetInvoice(c *gin.Context) {
	// Get authenticated user
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Safe type assertion with validation
	uid, ok := userID.(uuid.UUID)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID type"})
		return
	}

	// Get invoice ID from URL parameter
	invoiceIDStr := c.Param("id")
	invoiceID, err := uuid.Parse(invoiceIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid invoice ID"})
		return
	}

	// Fetch invoice from database
	var invoice models.Invoice
	if err := h.db.First(&invoice, invoiceID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Invoice not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch invoice"})
		}
		return
	}

	// Verify user owns the invoice (check user_id matches)
	if invoice.UserID != uid {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	// Generate Xero URL
	invoice.GenerateXeroURL()

	c.JSON(http.StatusOK, invoice)
}

// calculateInvoiceStats computes statistics from a list of invoices
func calculateInvoiceStats(invoices []models.Invoice) models.InvoiceStats {
	stats := models.InvoiceStats{}

	for _, inv := range invoices {
		switch inv.Status {
		case models.InvoiceStatusPaid:
			stats.PaidCount++
		case models.InvoiceStatusDraft:
			stats.DraftCount++
		case models.InvoiceStatusSent:
			// Check if sent invoice is overdue
			if time.Now().After(inv.DueDate) {
				// Treat as overdue, not pending
				stats.OverdueCount++
				stats.TotalOutstanding += inv.Amount
			} else {
				// Not yet overdue - count as pending
				stats.PendingCount++
				stats.TotalOutstanding += inv.Amount
			}
		case models.InvoiceStatusOverdue:
			stats.OverdueCount++
			stats.TotalOutstanding += inv.Amount
		}
	}

	return stats
}

// getRecentInvoiceActivities returns recent invoice-related activities
func getRecentInvoiceActivities(db *gorm.DB, userID uuid.UUID, yachtID *uuid.UUID) []models.InvoiceActivity {
	// Get last 5 invoice updates
	query := db.Where("user_id = ?", userID)
	if yachtID != nil {
		query = query.Where("yacht_id = ?", *yachtID)
	}

	var invoices []models.Invoice
	if err := query.Order("updated_at DESC").Limit(5).Find(&invoices).Error; err != nil {
		return []models.InvoiceActivity{}
	}

	activities := make([]models.InvoiceActivity, 0, len(invoices))
	for _, inv := range invoices {
		var icon, title, subtitle, color string

		switch inv.Status {
		case models.InvoiceStatusPaid:
			icon = "checkmark.circle.fill"
			title = "Payment Received"
			subtitle = inv.InvoiceNumber + " - $" + formatAmount(inv.Amount)
			color = "green"
		case models.InvoiceStatusSent:
			icon = "envelope.fill"
			title = "Invoice Sent"
			subtitle = inv.InvoiceNumber + " - Due " + inv.DueDate.Format("Jan 2")
			color = "blue"
		case models.InvoiceStatusOverdue:
			icon = "exclamationmark.triangle.fill"
			title = "Invoice Overdue"
			subtitle = inv.InvoiceNumber + " - $" + formatAmount(inv.Amount)
			color = "orange"
		case models.InvoiceStatusDraft:
			icon = "doc.text"
			title = "Draft Created"
			subtitle = inv.InvoiceNumber
			color = "gray"
		default:
			continue
		}

		activities = append(activities, models.InvoiceActivity{
			Icon:     icon,
			Title:    title,
			Subtitle: subtitle,
			Time:     inv.UpdatedAt,
			Color:    color,
		})
	}

	return activities
}

// formatAmount formats a float as a currency string
func formatAmount(amount float64) string {
	return fmt.Sprintf("%.2f", amount)
}
