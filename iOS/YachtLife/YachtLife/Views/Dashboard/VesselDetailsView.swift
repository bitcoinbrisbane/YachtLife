import SwiftUI

struct VesselDetailsView: View {
    let yacht: Yacht

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                VesselHeroImage(yacht: yacht)

                VStack(spacing: 20) {
                    // Vessel Name & Info
                    VesselHeader(yacht: yacht)
                        .padding(.horizontal)
                        .padding(.top, 20)

                    // Quick Stats Cards (2x2 grid)
                    VesselStatsGrid(yacht: yacht)
                        .padding(.horizontal)

                    // Vessel Details
                    VesselDetailsSection(yacht: yacht)
                        .padding(.horizontal)

                    // Action Buttons
                    ActionButtons()
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Vessel Hero Image
struct VesselHeroImage: View {
    let yacht: Yacht

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Beautiful gradient placeholder (since we don't have actual yacht images yet)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.7),
                    Color.cyan.opacity(0.5),
                    Color.blue.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)

            // Yacht silhouette overlay
            Image(systemName: "ferry.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .foregroundColor(.white.opacity(0.3))
                .padding(.leading, 80)
                .padding(.bottom, 80)
        }
    }
}

// MARK: - Vessel Header
struct VesselHeader: View {
    let yacht: Yacht

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(yacht.name)
                .font(.system(size: 32, weight: .bold))

            Text("\(yacht.manufacturer) | \(yacht.model) | \(yacht.yearBuilt)")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Vessel Stats Grid (2x2)
struct VesselStatsGrid: View {
    let yacht: Yacht

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            VesselStatCard(
                title: "Engine",
                value: "\(yacht.engineHorsepower ?? 900) HP",
                icon: "engine.combustion.fill"
            )

            VesselStatCard(
                title: "Speed",
                value: "35 knots",
                icon: "speedometer"
            )

            VesselStatCard(
                title: "Length",
                value: "\(Int(yacht.length)) feet",
                icon: "ruler.fill"
            )

            VesselStatCard(
                title: "Year",
                value: "\(yacht.yearBuilt)",
                icon: "calendar"
            )
        }
    }
}

struct VesselStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.blue)

            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Vessel Details Section
struct VesselDetailsSection: View {
    let yacht: Yacht

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vessel Details")
                .font(.headline)
                .padding(.bottom, 4)

            VesselDetailRow(icon: "number", label: "Hull ID", value: yacht.hullIdentificationNumber ?? "N/A")
            VesselDetailRow(icon: "doc.text.fill", label: "Registration", value: "YCH-\(yacht.yearBuilt)-\(String(yacht.id.uuidString.prefix(3)).uppercased())")
            VesselDetailRow(icon: "globe", label: "Country", value: "Australia")
            VesselDetailRow(icon: "location.fill", label: "Home Port", value: yacht.homePort)
            VesselDetailRow(icon: "clock.fill", label: "Engine Hours", value: "1,247.5 hrs")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct VesselDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Action Buttons
struct ActionButtons: View {
    var body: some View {
        HStack(spacing: 12) {
            NavigationLink {
                Text("Full Specifications")
                    .navigationTitle("Specifications")
            } label: {
                Text("View Full Specs")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            NavigationLink {
                BookingsView()
            } label: {
                Text("Bookings")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    NavigationStack {
        VesselDetailsView(yacht: Yacht(
            id: UUID(),
            name: "Neptune's Pride",
            model: "Riviera 72 Sports Motor Yacht",
            manufacturer: "Riviera",
            year: 2022,
            lengthFeet: 72.0,
            beamFeet: 19.5,
            draftFeet: 5.2,
            hullId: "RIV72-2022-NPF001",
            registration: nil,
            registrationCountry: nil,
            homePort: "Gold Coast Marina",
            berthLocation: nil,
            berthBayNumber: nil,
            maxPassengers: 12,
            cruisingSpeedKnots: nil,
            maxSpeedKnots: nil,
            fuelCapacityLiters: 3000,
            waterCapacityLiters: 500,
            engineMake: "Volvo Penta",
            engineModel: "IPS 1200",
            engineCount: 2,
            engineHorsepower: 900,
            engineHours: nil,
            transmissionType: nil,
            heroImageUrl: nil,
            galleryImages: nil,
            specifications: nil,
            createdAt: nil,
            updatedAt: nil
        ))
    }
}
