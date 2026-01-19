import Foundation

struct LogbookEntry: Codable, Identifiable {
    let id: UUID
    let yachtID: UUID
    let bookingID: UUID?
    let userID: UUID
    let entryType: EntryType
    let fuelLiters: Double?
    let fuelCost: Double?
    let hoursOperated: Double?
    let notes: String?
    let createdAt: Date
    let yacht: Yacht?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case yachtID = "yacht_id"
        case bookingID = "booking_id"
        case userID = "user_id"
        case entryType = "entry_type"
        case fuelLiters = "fuel_liters"
        case fuelCost = "fuel_cost"
        case hoursOperated = "hours_operated"
        case notes
        case createdAt = "created_at"
        case yacht
        case user
    }

    enum EntryType: String, Codable {
        case departure
        case `return`
        case fuel
        case maintenance
        case general
        case incident
    }
}

struct CreateLogbookEntryRequest: Codable {
    let yachtID: UUID
    let entryType: LogbookEntry.EntryType?
    let fuelLiters: Double?
    let fuelCost: Double?
    let hoursOperated: Double?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case yachtID = "yacht_id"
        case entryType = "entry_type"
        case fuelLiters = "fuel_liters"
        case fuelCost = "fuel_cost"
        case hoursOperated = "hours_operated"
        case notes
    }
}
