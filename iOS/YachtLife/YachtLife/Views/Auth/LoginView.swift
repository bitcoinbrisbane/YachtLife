import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedVessel: Yacht?

    // Neptune Oceanic Fleet - Mock vessels
    private let mockVessels = [
        Yacht(
            id: UUID(),
            name: "Neptune's Pride",
            model: "Riviera 72 Sports Motor Yacht",
            manufacturer: "Riviera",
            yearBuilt: 2022,
            length: 72.0,
            totalShares: 8,
            homePort: "Gold Coast Marina",
            hullIdentificationNumber: "RIV72-2022-NPF001",
            imageUrl: nil,
            specifications: nil
        ),
        Yacht(
            id: UUID(),
            name: "Ocean Majesty",
            model: "Maritimo X60",
            manufacturer: "Maritimo",
            yearBuilt: 2023,
            length: 60.0,
            totalShares: 6,
            homePort: "Sanctuary Cove",
            hullIdentificationNumber: "MAR60-2023-NPF002",
            imageUrl: nil,
            specifications: nil
        ),
        Yacht(
            id: UUID(),
            name: "Blue Trident",
            model: "Sunseeker 88 Yacht",
            manufacturer: "Sunseeker",
            yearBuilt: 2021,
            length: 88.0,
            totalShares: 10,
            homePort: "Sydney Harbour",
            hullIdentificationNumber: "SUN88-2021-NPF003",
            imageUrl: nil,
            specifications: nil
        ),
        Yacht(
            id: UUID(),
            name: "Pacific Sovereign",
            model: "Princess 85 Motor Yacht",
            manufacturer: "Princess",
            yearBuilt: 2022,
            length: 85.0,
            totalShares: 10,
            homePort: "Hamilton Island Marina",
            hullIdentificationNumber: "PRI85-2022-NPF004",
            imageUrl: nil,
            specifications: nil
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Logo/Header
                VStack(spacing: 10) {
                    Image(systemName: "ferry.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)

                    Text("YachtLife")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Yacht Syndicate Management")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)

                // Vessel Selection
                VStack(spacing: 15) {
                    Picker("Vessel", selection: $selectedVessel) {
                        Text("Choose a vessel").tag(nil as Yacht?)
                        ForEach(mockVessels) { vessel in
                            Text("\(vessel.name) - \(vessel.model)").tag(vessel as Yacht?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal, 40)
                    .tint(.blue)

                    if let vessel = selectedVessel {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(vessel.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("\(vessel.model) • \(Int(vessel.length))ft")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(vessel.homePort)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                    }
                }

                // Mock Sign in
                VStack(spacing: 15) {
                    Button {
                        Task {
                            await authViewModel.mockAppleSignIn(
                                userIdentifier: UUID().uuidString,
                                email: "owner@yachtlife.com",
                                fullName: nil,
                                selectedVessel: selectedVessel
                            )
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                            Text("Sign in with Apple")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .disabled(selectedVessel == nil || authViewModel.isLoading)
                    .opacity(selectedVessel == nil ? 0.5 : 1.0)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 40)
                    }
                }

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
