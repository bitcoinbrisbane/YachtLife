import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    let role: UserRole
    let phone: String?
    let country: String?
    let profileImageUrl: String?
    let createdAt: Date?

    enum UserRole: String, Codable {
        case admin
        case manager
        case owner

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let roleString = try container.decode(String.self)

            // Handle empty string as default "owner" role
            if roleString.isEmpty {
                self = .owner
                return
            }

            // Try to decode from the string value
            if let role = UserRole(rawValue: roleString) {
                self = role
            } else {
                // If invalid role, default to owner
                self = .owner
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case role
        case phone
        case country
        case profileImageUrl = "profile_image_url"
        case createdAt = "created_at"
    }

    // Computed property for full name
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}
