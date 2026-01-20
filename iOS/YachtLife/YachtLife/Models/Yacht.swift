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
    let registration: String?
    let registrationCountry: String?
    let homePort: String
    let berthLocation: String?
    let berthBayNumber: String?
    let maxPassengers: Int?
    let cruisingSpeedKnots: Double?
    let maxSpeedKnots: Double?
    let fuelCapacityLiters: Double?
    let waterCapacityLiters: Double?
    let engineMake: String?
    let engineModel: String?
    let engineCount: Int?
    let engineHorsepower: Int?
    let engineHours: Double?
    let transmissionType: String?
    let heroImageUrl: String?
    let galleryImages: [String]?
    let specifications: [String: String]?
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
        case registration
        case registrationCountry = "registration_country"
        case homePort = "home_port"
        case berthLocation = "berth_location"
        case berthBayNumber = "berth_bay_number"
        case maxPassengers = "max_passengers"
        case cruisingSpeedKnots = "cruising_speed_knots"
        case maxSpeedKnots = "max_speed_knots"
        case fuelCapacityLiters = "fuel_capacity_liters"
        case waterCapacityLiters = "water_capacity_liters"
        case engineMake = "engine_make"
        case engineModel = "engine_model"
        case engineCount = "engine_count"
        case engineHorsepower = "engine_horsepower"
        case engineHours = "engine_hours"
        case transmissionType = "transmission_type"
        case heroImageUrl = "hero_image_url"
        case galleryImages = "gallery_images"
        case specifications
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
