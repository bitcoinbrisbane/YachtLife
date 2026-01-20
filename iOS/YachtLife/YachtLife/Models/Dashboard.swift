import Foundation
import SwiftUI

struct DashboardViewModel: Codable {
    let userName: String
    let vessel: VesselInfo
    let portEngineHours: Double
    let starboardEngineHours: Double
    let fuelLiters: Double
    let activeBooking: BookingInfo?
    let hasDepartureLog: Bool
    let upcomingBookings: [BookingInfo]
    let recentActivities: [ActivityInfo]
}

struct VesselInfo: Codable {
    let id: UUID
    let name: String
    let manufacturer: String
    let model: String
    let length: Double
    let homePort: String
}

struct BookingInfo: Codable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let status: String
    let standbyDays: Int
    let notes: String
}

struct ActivityInfo: Codable, Identifiable {
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
