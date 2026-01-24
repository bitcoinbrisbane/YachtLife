package models

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestInvoiceJSONEncoding tests that Invoice model encodes to JSON correctly
func TestInvoiceJSONEncoding(t *testing.T) {
	now := time.Now()
	paidDate := now.AddDate(0, -1, 0)
	invoice := Invoice{
		ID:            uuid.New(),
		XeroInvoiceID: "XERO-INV-001",
		YachtID:       uuid.New(),
		UserID:        uuid.New(),
		InvoiceNumber: "YL-2025-001",
		Description:   "Test invoice",
		Amount:        1000.50,
		DueDate:       now.AddDate(0, 0, 30),
		Status:        InvoiceStatusSent,
		IssuedDate:    now,
		PaidDate:      &paidDate,
		CreatedAt:     now,
		UpdatedAt:     now,
	}

	// Generate Xero URL
	invoice.GenerateXeroURL()

	// Encode to JSON
	data, err := json.Marshal(invoice)
	require.NoError(t, err, "Failed to marshal invoice to JSON")

	// Decode back
	var decoded Invoice
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err, "Failed to unmarshal invoice from JSON")

	// Verify all fields
	assert.Equal(t, invoice.ID, decoded.ID)
	assert.Equal(t, invoice.XeroInvoiceID, decoded.XeroInvoiceID)
	assert.Equal(t, invoice.InvoiceNumber, decoded.InvoiceNumber)
	assert.Equal(t, invoice.Amount, decoded.Amount)
	assert.Equal(t, invoice.Status, decoded.Status)
	assert.NotEmpty(t, decoded.XeroURL, "XeroURL should be generated")
}

// TestInvoiceViewModelJSONEncoding tests InvoiceViewModel encoding
func TestInvoiceViewModelJSONEncoding(t *testing.T) {
	now := time.Now()
	viewModel := InvoiceViewModel{
		Stats: InvoiceStats{
			TotalOutstanding: 5000.00,
			PaidCount:        2,
			OverdueCount:     1,
			PendingCount:     1,
			DraftCount:       1,
		},
		Invoices: []InvoiceInfo{
			{
				ID:            uuid.New(),
				InvoiceNumber: "YL-2025-001",
				Description:   "Test invoice",
				Amount:        1000.00,
				DueDate:       now.AddDate(0, 0, 30),
				IssuedDate:    now,
				Status:        "sent",
				IsOverdue:     false,
				DaysUntilDue:  30,
			},
		},
		RecentActivities: []InvoiceActivity{
			{
				Icon:     "envelope.fill",
				Title:    "Invoice Sent",
				Subtitle: "YL-2025-001",
				Time:     now,
				Color:    "blue",
			},
		},
	}

	// Encode to JSON
	data, err := json.Marshal(viewModel)
	require.NoError(t, err, "Failed to marshal InvoiceViewModel to JSON")

	// Decode back
	var decoded InvoiceViewModel
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err, "Failed to unmarshal InvoiceViewModel from JSON")

	// Verify structure
	assert.Equal(t, viewModel.Stats.TotalOutstanding, decoded.Stats.TotalOutstanding)
	assert.Equal(t, len(viewModel.Invoices), len(decoded.Invoices))
	assert.Equal(t, len(viewModel.RecentActivities), len(decoded.RecentActivities))

	// Verify invoice info fields
	assert.Equal(t, viewModel.Invoices[0].InvoiceNumber, decoded.Invoices[0].InvoiceNumber)
	assert.Equal(t, viewModel.Invoices[0].DaysUntilDue, decoded.Invoices[0].DaysUntilDue)
}

// TestInvoiceInfoJSONEncoding specifically tests InvoiceInfo which appears in lists
func TestInvoiceInfoJSONEncoding(t *testing.T) {
	now := time.Now()
	info := InvoiceInfo{
		ID:            uuid.New(),
		InvoiceNumber: "YL-2025-001",
		Description:   "Test invoice",
		Amount:        1000.00,
		DueDate:       now.AddDate(0, 0, 30),
		IssuedDate:    now,
		Status:        "sent",
		IsOverdue:     false,
		DaysUntilDue:  30,
	}

	// Encode to JSON
	data, err := json.Marshal(info)
	require.NoError(t, err, "Failed to marshal InvoiceInfo to JSON")

	// Print JSON to see structure
	t.Logf("InvoiceInfo JSON: %s", string(data))

	// Verify JSON contains snake_case keys
	var jsonMap map[string]interface{}
	err = json.Unmarshal(data, &jsonMap)
	require.NoError(t, err)

	// Check snake_case field names
	assert.Contains(t, jsonMap, "invoice_number", "Should use snake_case for invoice_number")
	assert.Contains(t, jsonMap, "due_date", "Should use snake_case for due_date")
	assert.Contains(t, jsonMap, "issued_date", "Should use snake_case for issued_date")
	assert.Contains(t, jsonMap, "is_overdue", "Should use snake_case for is_overdue")
	assert.Contains(t, jsonMap, "days_until_due", "Should use snake_case for days_until_due")

	// Decode back
	var decoded InvoiceInfo
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err, "Failed to unmarshal InvoiceInfo from JSON")

	// Verify all fields preserved
	assert.Equal(t, info.ID, decoded.ID)
	assert.Equal(t, info.InvoiceNumber, decoded.InvoiceNumber)
	assert.Equal(t, info.DaysUntilDue, decoded.DaysUntilDue)
	assert.Equal(t, info.IsOverdue, decoded.IsOverdue)
}

// TestInvoiceStatusValues tests that invoice status values are correct
func TestInvoiceStatusValues(t *testing.T) {
	tests := []struct {
		status   InvoiceStatus
		expected string
	}{
		{InvoiceStatusDraft, "draft"},
		{InvoiceStatusSent, "sent"},
		{InvoiceStatusPaid, "paid"},
		{InvoiceStatusOverdue, "overdue"},
		{InvoiceStatusCancelled, "cancelled"},
	}

	for _, tt := range tests {
		t.Run(string(tt.status), func(t *testing.T) {
			assert.Equal(t, tt.expected, string(tt.status))
		})
	}
}

// TestGenerateXeroURL tests the XeroURL generation
func TestGenerateXeroURL(t *testing.T) {
	tests := []struct {
		name          string
		xeroInvoiceID string
		expectedURL   string
	}{
		{
			name:          "Valid Xero ID",
			xeroInvoiceID: "XERO-INV-001",
			expectedURL:   "https://go.xero.com/AccountsReceivable/View.aspx?InvoiceID=XERO-INV-001",
		},
		{
			name:          "Empty Xero ID",
			xeroInvoiceID: "",
			expectedURL:   "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			invoice := Invoice{
				XeroInvoiceID: tt.xeroInvoiceID,
			}
			invoice.GenerateXeroURL()
			assert.Equal(t, tt.expectedURL, invoice.XeroURL)
		})
	}
}
