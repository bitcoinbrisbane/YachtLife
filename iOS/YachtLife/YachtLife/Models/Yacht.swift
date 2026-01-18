import Foundation

struct Yacht: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let model: String
    let manufacturer: String
    let year: Int
    let lengthFeet: Double
    let beamFeet: Double?
    let draftFeet: Double?
    let hullId: String?
    let homePort: String
    let maxPassengers: Int?
    let fuelCapacityLiters: Double?
    let waterCapacityLiters: Double?
    let engineMake: String?
    let engineModel: String?
    let engineCount: Int?
    let engineHorsepower: Int?
    let heroImageUrl: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case model
        case manufacturer
        case year
        case lengthFeet = "length_feet"
        case beamFeet = "beam_feet"
        case draftFeet = "draft_feet"
        case hullId = "hull_id"
        case homePort = "home_port"
        case maxPassengers = "max_passengers"
        case fuelCapacityLiters = "fuel_capacity_liters"
        case waterCapacityLiters = "water_capacity_liters"
        case engineMake = "engine_make"
        case engineModel = "engine_model"
        case engineCount = "engine_count"
        case engineHorsepower = "engine_horsepower"
        case heroImageUrl = "hero_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Deprecated properties for backwards compatibility
    var yearBuilt: Int { year }
    var length: Double { lengthFeet }
    var hullIdentificationNumber: String? { hullId }
    var imageUrl: String? { heroImageUrl }
}

struct SyndicateShare: Codable, Identifiable {
    let id: UUID
    let yachtId: UUID
    let userId: UUID
    let sharesOwned: Int
    let purchaseDate: Date
    let purchasePrice: Double?
}
