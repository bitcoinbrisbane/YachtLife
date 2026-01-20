import Foundation

// LogbookSummary represents a summarized view of a logbook entry
struct LogbookSummary: Codable, Identifiable {
    let id: UUID
    let entryType: String
    let portEngineHours: Double?
    let starboardEngineHours: Double?
    let fuelLiters: Double?
    let createdAt: Date
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case entryType = "entry_type"
        case portEngineHours = "port_engine_hours"
        case starboardEngineHours = "starboard_engine_hours"
        case fuelLiters = "fuel_liters"
        case createdAt = "created_at"
        case notes
    }
}

// BookingDetail contains detailed booking information with logbook data and calculations
struct BookingDetail: Codable {
    let booking: Booking
    let departureLog: LogbookSummary?
    let returnLog: LogbookSummary?
    let fuelConsumed: Double?
    let portHoursDelta: Double?
    let starboardHoursDelta: Double?
    let hasLogbookData: Bool

    enum CodingKeys: String, CodingKey {
        case booking
        case departureLog = "departure_log"
        case returnLog = "return_log"
        case fuelConsumed = "fuel_consumed"
        case portHoursDelta = "port_hours_delta"
        case starboardHoursDelta = "starboard_hours_delta"
        case hasLogbookData = "has_logbook_data"
    }
}
