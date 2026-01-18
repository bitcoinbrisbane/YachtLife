import Foundation

struct Yacht: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let model: String
    let manufacturer: String
    let yearBuilt: Int
    let length: Double
    let totalShares: Int
    let homePort: String
    let hullIdentificationNumber: String?
    let imageUrl: String?
    let specifications: YachtSpecifications?

    struct YachtSpecifications: Codable, Hashable {
        let beam: Double?
        let draft: Double?
        let displacement: Double?
        let fuelCapacity: Double?
        let waterCapacity: Double?
        let engineMake: String?
        let engineModel: String?
        let engineHorsepower: Int?
    }
}

struct SyndicateShare: Codable, Identifiable {
    let id: UUID
    let yachtId: UUID
    let userId: UUID
    let sharesOwned: Int
    let purchaseDate: Date
    let purchasePrice: Double?
}
