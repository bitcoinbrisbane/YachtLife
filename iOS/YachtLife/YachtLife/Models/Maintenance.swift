import Foundation

struct MaintenanceRequest: Codable, Identifiable {
    let id: UUID
    let yachtId: UUID
    let reportedBy: UUID
    let title: String
    let description: String
    let urgency: Urgency
    let status: Status
    let location: String?
    let photoUrls: [String]?
    let estimatedCost: Double?
    let actualCost: Double?
    let assignedTo: UUID?
    let createdAt: Date
    let completedAt: Date?

    enum Urgency: String, Codable {
        case low
        case medium
        case high
        case critical
    }

    enum Status: String, Codable {
        case submitted
        case acknowledged
        case inProgress = "in_progress"
        case completed
        case cancelled
    }
}
