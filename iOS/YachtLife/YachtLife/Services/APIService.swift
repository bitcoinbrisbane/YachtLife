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

        // Custom date decoder to handle backend's various ISO8601 formats
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try various date formats that the backend might return
            let formatters: [DateFormatter] = {
                let locale = Locale(identifier: "en_US_POSIX")
                let tz = TimeZone(secondsFromGMT: 0)

                // Format with fractional seconds (6 digits) and timezone
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
                formatter1.locale = locale
                formatter1.timeZone = tz

                // Format without fractional seconds but with timezone
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                formatter2.locale = locale
                formatter2.timeZone = tz

                return [formatter1, formatter2]
            }()

            // Try each formatter
            for formatter in formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            // Fallback to ISO8601 formatter
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }

            // Try without fractional seconds
            iso8601Formatter.formatOptions = [.withInternetDateTime]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
        }

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

    // MARK: - Activity
    func getRecentActivity(yachtId: UUID? = nil) async throws -> [Activity] {
        var endpoint = "/activity/recent"
        if let yachtId = yachtId {
            endpoint += "?yacht_id=\(yachtId)"
        }

        let response: RecentActivityResponse = try await request(endpoint: endpoint)
        return response.activities
    }

    // MARK: - Logbook
    func getLogbookEntries(yachtId: UUID? = nil, bookingId: UUID? = nil) async throws -> [LogbookEntry] {
        var endpoint = "/logbook"
        var params: [String] = []

        if let yachtId = yachtId {
            params.append("yacht_id=\(yachtId)")
        }
        if let bookingId = bookingId {
            params.append("booking_id=\(bookingId)")
        }

        if !params.isEmpty {
            endpoint += "?" + params.joined(separator: "&")
        }

        return try await request(endpoint: endpoint)
    }

    func createLogbookEntry(_ request: CreateLogbookEntryRequest) async throws -> LogbookEntry {
        try await self.request(endpoint: "/logbook", method: "POST", body: request)
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
