import Foundation
import SwiftUI

enum ActivityType: String, Codable {
    case checklist
    case fuel
    case payment
    case maintenance
    case booking
}

struct Activity: Codable, Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let subtitle: String
    let icon: String
    let color: String
    let timestamp: Date
    let relatedId: UUID?
    let relatedType: String?

    enum CodingKeys: String, CodingKey {
        case id, type, title, subtitle, icon, color, timestamp
        case relatedId = "related_id"
        case relatedType = "related_type"
    }

    // Computed property for SwiftUI Color
    var colorValue: Color {
        Color(hex: color) ?? .gray
    }

    // Relative time string ("2 hours ago", "1 day ago")
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct RecentActivityResponse: Codable {
    let activities: [Activity]
}

// MARK: - Color Extension for Hex Parsing
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(.sRGB, red: red, green: green, blue: blue)
    }
}
