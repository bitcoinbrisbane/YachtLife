import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let fullName: String
    let role: UserRole
    let phone: String?
    let createdAt: Date

    enum UserRole: String, Codable {
        case admin
        case manager
        case owner
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
