import Foundation

struct LogbookEntry: Codable, Identifiable {
    let id: UUID
    let yachtID: UUID
    let bookingID: UUID?
    let userID: UUID
    let entryType: EntryType
    let portEngineHours: Double?
    let starboardEngineHours: Double?
    let fuelLiters: Double?
    let notes: String?
    let createdAt: Date
    let yacht: Yacht?
    let booking: Booking?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case yachtID = "yacht_id"
        case bookingID = "booking_id"
        case userID = "user_id"
        case entryType = "entry_type"
        case portEngineHours = "port_engine_hours"
        case starboardEngineHours = "starboard_engine_hours"
        case fuelLiters = "fuel_liters"
        case notes
        case createdAt = "created_at"
        case yacht
        case booking
        case user
    }

    enum EntryType: String, Codable {
        case depart
        case `return`
        case fuel
        case maintenance
        case general
        case incident
    }
}

struct CreateLogbookEntryRequest: Codable {
    let yachtID: UUID
    let portEngineHours: Double?
    let starboardEngineHours: Double?
    let fuelLiters: Double?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case yachtID = "yacht_id"
        case portEngineHours = "port_engine_hours"
        case starboardEngineHours = "starboard_engine_hours"
        case fuelLiters = "fuel_liters"
        case notes
    }
}
