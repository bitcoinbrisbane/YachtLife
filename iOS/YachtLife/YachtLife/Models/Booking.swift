import Foundation

struct Booking: Codable, Identifiable {
    let id: UUID
    let yachtId: UUID
    let userId: UUID
    let startDate: Date
    let endDate: Date
    let status: BookingStatus
    let notes: String?
    let cancelledAt: Date?
    let createdAt: Date
    let updatedAt: Date?

    // Nested objects (optional, will be ignored if not needed)
    let yacht: Yacht?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case yachtId = "yacht_id"
        case userId = "user_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case status
        case notes
        case cancelledAt = "cancelled_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case yacht
        case user
    }

    enum BookingStatus: String, Codable {
        case pending
        case confirmed
        case inProgress = "in_progress"
        case completed
        case cancelled
    }
}

struct BookingChangeRequest: Codable, Identifiable {
    let id: UUID
    let bookingId: UUID
    let userId: UUID
    let requestedStartDate: Date?
    let requestedEndDate: Date?
    let reason: String
    let status: RequestStatus
    let createdAt: Date
    let resolvedAt: Date?
    let resolvedBy: UUID?

    enum RequestStatus: String, Codable {
        case pending
        case approved
        case denied
    }
}
