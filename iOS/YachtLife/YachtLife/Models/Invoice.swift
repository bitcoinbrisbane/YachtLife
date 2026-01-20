import Foundation
import SwiftUI

struct Invoice: Codable, Identifiable {
    let id: UUID
    let yachtId: UUID
    let userId: UUID
    let xeroInvoiceId: String?
    let amount: Double
    let dueDate: Date
    let status: InvoiceStatus
    let description: String
    let createdAt: Date
    let paidAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case yachtId = "yacht_id"
        case userId = "user_id"
        case xeroInvoiceId = "xero_invoice_id"
        case amount
        case dueDate = "due_date"
        case status
        case description
        case createdAt = "created_at"
        case paidAt = "paid_at"
    }

    enum InvoiceStatus: String, Codable {
        case draft
        case sent
        case paid
        case overdue
        case cancelled
    }
}

struct Payment: Codable, Identifiable {
    let id: UUID
    let invoiceId: UUID
    let userId: UUID
    let amount: Double
    let paymentMethod: PaymentMethod
    let stripePaymentId: String?
    let xeroPaymentId: String?
    let status: PaymentStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case invoiceId = "invoice_id"
        case userId = "user_id"
        case amount
        case paymentMethod = "payment_method"
        case stripePaymentId = "stripe_payment_id"
        case xeroPaymentId = "xero_payment_id"
        case status
        case createdAt = "created_at"
    }

    enum PaymentMethod: String, Codable {
        case stripe
        case applePay = "apple_pay"
        case googlePay = "google_pay"
        case bankTransfer = "bank_transfer"
    }

    enum PaymentStatus: String, Codable {
        case pending
        case completed
        case failed
        case refunded
    }
}

// MARK: - Invoice ViewModel (Dashboard)

struct InvoiceViewModel: Codable {
    let stats: InvoiceStats
    let invoices: [InvoiceInfo]
    let recentActivities: [InvoiceActivity]

    enum CodingKeys: String, CodingKey {
        case stats
        case invoices
        case recentActivities = "recent_activities"
    }
}

struct InvoiceStats: Codable {
    let totalOutstanding: Double
    let paidCount: Int
    let overdueCount: Int
    let pendingCount: Int
    let draftCount: Int

    enum CodingKeys: String, CodingKey {
        case totalOutstanding = "total_outstanding"
        case paidCount = "paid_count"
        case overdueCount = "overdue_count"
        case pendingCount = "pending_count"
        case draftCount = "draft_count"
    }
}

struct InvoiceInfo: Codable, Identifiable {
    let id: UUID
    let invoiceNumber: String
    let description: String
    let amount: Double
    let dueDate: Date
    let issuedDate: Date
    let status: String
    let isOverdue: Bool
    let daysUntilDue: Int

    enum CodingKeys: String, CodingKey {
        case id
        case invoiceNumber = "invoice_number"
        case description
        case amount
        case dueDate = "due_date"
        case issuedDate = "issued_date"
        case status
        case isOverdue = "is_overdue"
        case daysUntilDue = "days_until_due"
    }

    var statusColor: Color {
        switch status.lowercased() {
        case "paid": return .green
        case "sent": return .blue
        case "overdue": return .red
        case "draft": return .gray
        default: return .gray
        }
    }

    var statusIcon: String {
        switch status.lowercased() {
        case "paid": return "checkmark.circle.fill"
        case "sent": return "envelope.fill"
        case "overdue": return "exclamationmark.triangle.fill"
        case "draft": return "doc.text"
        default: return "doc"
        }
    }

    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }

    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: dueDate)
    }

    var dueDateInfo: String {
        if isOverdue {
            return "Overdue"
        } else if daysUntilDue == 0 {
            return "Due today"
        } else if daysUntilDue == 1 {
            return "Due tomorrow"
        } else if daysUntilDue > 0 {
            return "Due in \(daysUntilDue) days"
        } else {
            return "Overdue by \(abs(daysUntilDue)) days"
        }
    }
}

struct InvoiceActivity: Codable, Identifiable {
    let icon: String
    let title: String
    let subtitle: String
    let time: Date
    let color: String

    var id: String {
        "\(icon)_\(time.timeIntervalSince1970)"
    }

    var colorValue: Color {
        switch color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "gray": return .gray
        default: return .gray
        }
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: time, relativeTo: Date())
    }
}
