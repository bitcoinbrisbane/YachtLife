import Foundation

class APIService {
    static let shared = APIService()

    private let baseURL: String
    private var authToken: String?

    private init() {
        #if DEBUG
        baseURL = "http://localhost:8080/api/v1"
        #else
        baseURL = "https://api.yachtlife.com/api/v1"
        #endif
    }

    func setAuthToken(_ token: String) {
        self.authToken = token
        UserDefaults.standard.set(token, forKey: "auth_token")
    }

    func clearAuthToken() {
        self.authToken = nil
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }

    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken ?? UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            // Try to get error message from response
            if let errorBody = String(data: data, encoding: .utf8) {
                print("API Error (\(httpResponse.statusCode)): \(errorBody)")
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // Print the raw JSON and decoding error for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Failed to decode JSON: \(jsonString)")
            }
            print("Decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Authentication
    func login(email: String, password: String) async throws -> AuthResponse {
        try await request(
            endpoint: "/auth/login",
            method: "POST",
            body: LoginRequest(email: email, password: password)
        )
    }

    func getCurrentUser() async throws -> User {
        try await request(endpoint: "/auth/me")
    }

    // MARK: - Bookings
    func getBookings(yachtId: UUID? = nil) async throws -> [Booking] {
        let endpoint = yachtId != nil ? "/bookings?yacht_id=\(yachtId!)" : "/bookings"
        return try await request(endpoint: endpoint)
    }

    func createBooking(_ booking: Booking) async throws -> Booking {
        try await request(endpoint: "/bookings", method: "POST", body: booking)
    }

    // MARK: - Invoices
    func getInvoices() async throws -> [Invoice] {
        try await request(endpoint: "/invoices")
    }

    // MARK: - Maintenance
    func getMaintenanceRequests(yachtId: UUID? = nil) async throws -> [MaintenanceRequest] {
        let endpoint = yachtId != nil ? "/maintenance?yacht_id=\(yachtId!)" : "/maintenance"
        return try await request(endpoint: endpoint)
    }

    func createMaintenanceRequest(_ request: MaintenanceRequest) async throws -> MaintenanceRequest {
        try await self.request(endpoint: "/maintenance", method: "POST", body: request)
    }

    // MARK: - Yachts
    func getYachts() async throws -> [Yacht] {
        try await request(endpoint: "/yachts")
    }

    func getYacht(id: UUID) async throws -> Yacht {
        try await request(endpoint: "/yachts/\(id)")
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
