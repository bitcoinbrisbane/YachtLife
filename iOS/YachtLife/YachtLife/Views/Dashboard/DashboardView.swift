import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingLogEntry = false
    @State private var bookings: [Booking] = []
    @State private var isLoadingBookings = false
    @State private var bookingsError: String?

    // Mock Neptune Oceanic Fleet yacht
    private let mockYacht = Yacht(
        id: UUID(uuidString: "e98b59ac-bdac-4513-9ddd-f032d3aa39f7")!,
        name: "Neptune's Pride",
        model: "Riviera 72 Sports Motor Yacht",
        manufacturer: "Riviera",
        year: 2022,
        lengthFeet: 72.0,
        beamFeet: 19.5,
        draftFeet: 5.2,
        hullId: "RIV72-2022-NPF001",
        homePort: "Gold Coast Marina",
        maxPassengers: 12,
        fuelCapacityLiters: 3000,
        waterCapacityLiters: 500,
        engineMake: "Volvo Penta",
        engineModel: "IPS 1200",
        engineCount: 2,
        engineHorsepower: 900,
        heroImageUrl: nil,
        createdAt: nil,
        updatedAt: nil
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    HeroSection(yacht: mockYacht, userName: authViewModel.currentUser?.fullName ?? "Owner")

                    // Stats Grid
                    StatsGrid(showingLogEntry: $showingLogEntry)
                        .padding(.horizontal)
                        .padding(.top, 20)

                    // Upcoming Bookings
                    if isLoadingBookings {
                        ProgressView("Loading bookings...")
                            .padding()
                    } else if let error = bookingsError {
                        Text("Error loading bookings: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        UpcomingBookingsSection(bookings: bookings)
                            .padding(.top, 25)
                    }

                    // Recent Activity
                    RecentActivitySection()
                        .padding(.top, 25)
                        .padding(.bottom, 20)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .onAppear {
                loadBookings()
            }
            .sheet(isPresented: $showingLogEntry) {
                CreateLogEntryView(
                    yachtID: mockYacht.id,
                    portEngineHours: "1247.5",
                    starboardEngineHours: "1248.2",
                    fuelLevel: "2550"
                )
            }
        }
    }

    private func loadBookings() {
        Task {
            isLoadingBookings = true
            bookingsError = nil

            do {
                bookings = try await APIService.shared.getBookings(yachtId: mockYacht.id)
                print("✅ Loaded \(bookings.count) bookings")
            } catch {
                bookingsError = error.localizedDescription
                print("❌ Error loading bookings: \(error)")
            }

            isLoadingBookings = false
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    let yacht: Yacht
    let userName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // TODO: Fix hero image horizontal stretching issue
            // High-res yacht image background
//            Image("yacht-hero")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(maxWidth: .infinity)
//                .frame(height: 280)
//                .clipped()

            // Dark gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)

            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back,")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))

                        Text(userName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Image(systemName: "ferry.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 8)

                // Yacht Info Card
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(yacht.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("\(yacht.manufacturer) \(yacht.model)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))

                        HStack(spacing: 15) {
                            Label("\(Int(yacht.length))ft", systemImage: "ruler")
                            Label(yacht.homePort, systemImage: "location.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    }

                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial.opacity(0.8))
                .cornerRadius(12)
            }
            .padding()
            .padding(.top, 40)
        }
    }
}

// MARK: - Stats Grid
struct StatsGrid: View {
    @Binding var showingLogEntry: Bool

    var body: some View {
        VStack(spacing: 15) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    icon: "gauge.high",
                    value: "1,247.5",
                    label: "Port Engine",
                    color: .blue
                )

                StatCard(
                    icon: "gauge.high",
                    value: "1,248.2",
                    label: "Starboard Engine",
                    color: .blue
                )
            }

            LazyVGrid(columns: [
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    icon: "fuelpump.fill",
                    value: "2,550L",
                    label: "Starting Fuel",
                    color: .green
                )
            }

            // Create Log Entry Button
            Button {
                showingLogEntry = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Log Entry")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Upcoming Bookings Section
struct UpcomingBookingsSection: View {
    let bookings: [Booking]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Upcoming Bookings")
                    .font(.headline)

                Spacer()

                NavigationLink {
                    BookingsView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            ForEach(bookings) { booking in
                BookingCard(booking: booking)
            }
        }
    }
}

struct BookingCard: View {
    let booking: Booking

    var body: some View {
        HStack(spacing: 15) {
            // Date Badge
            VStack(spacing: 2) {
                Text(booking.startDate, format: .dateTime.month(.abbreviated))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(booking.startDate, format: .dateTime.day())
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(width: 50)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 6) {
                Text(booking.notes ?? "Yacht Booking")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text("\(booking.startDate, format: .dateTime.day().month()) - \(booking.endDate, format: .dateTime.day().month())")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                if booking.standbyDays > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                        Text("\(booking.standbyDays) standby days")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Status Badge
            Text(booking.status.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor(booking.status).opacity(0.2))
                .foregroundColor(statusColor(booking.status))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func statusColor(_ status: Booking.BookingStatus) -> Color {
        switch status {
        case .confirmed: return .green
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
}

// MARK: - Recent Activity Section
struct RecentActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ActivityRow(
                    icon: "checkmark.circle.fill",
                    title: "Checklist Completed",
                    subtitle: "Pre-departure checklist",
                    time: "2 hours ago",
                    color: .green
                )

                ActivityRow(
                    icon: "fuelpump.fill",
                    title: "Fuel Added",
                    subtitle: "450L at Gold Coast Marina",
                    time: "1 day ago",
                    color: .blue
                )

                ActivityRow(
                    icon: "dollarsign.circle.fill",
                    title: "Payment Received",
                    subtitle: "Invoice #1023 - $2,450",
                    time: "3 days ago",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthenticationViewModel())
}
