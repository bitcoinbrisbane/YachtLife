import Foundation

struct Booking: Codable, Identifiable {
    let id: UUID
    let yachtId: UUID
    let userId: UUID
    let startDate: Date
    let endDate: Date
    let standbyDays: Int
    let status: BookingStatus
    let notes: String?
    let createdAt: Date

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
    let requestedStandbyDays: Int?
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
