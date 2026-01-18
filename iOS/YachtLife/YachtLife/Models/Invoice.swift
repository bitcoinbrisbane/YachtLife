import Foundation

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
