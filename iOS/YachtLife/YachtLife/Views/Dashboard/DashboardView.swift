import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingLogEntry = false
    @State private var bookings: [Booking] = []
    @State private var isLoadingBookings = false
    @State private var bookingsError: String?
    @State private var latestLogEntry: LogbookEntry?
    @State private var isLoadingLogEntry = false
    @State private var recentActivities: [Activity] = []
    @State private var isLoadingActivities = false
    @State private var activeBooking: Booking?
    @State private var hasDepartureLog = false

    var body: some View {
        NavigationStack {
            if let yacht = authViewModel.selectedYacht {
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Section
                        HeroSection(yacht: yacht, userName: authViewModel.currentUser?.fullName ?? "Owner")

                        // Stats Grid
                        StatsGrid(
                            showingLogEntry: $showingLogEntry,
                            latestLogEntry: latestLogEntry,
                            buttonText: logButtonText
                        )
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
                        RecentActivitySection(activities: recentActivities, isLoading: isLoadingActivities)
                            .padding(.top, 25)
                            .padding(.bottom, 20)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .navigationBarHidden(true)
                .sheet(isPresented: $showingLogEntry) {
                    CreateLogEntryView(
                        yachtID: yacht.id,
                        portEngineHours: String(format: "%.1f", latestLogEntry?.portEngineHours ?? 1247.5),
                        starboardEngineHours: String(format: "%.1f", latestLogEntry?.starboardEngineHours ?? 1248.2),
                        fuelLevel: String(format: "%.0f", latestLogEntry?.fuelLiters ?? 2550)
                    )
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)

                    Text("No Vessel Selected")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Please log out and select a vessel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button {
                        authViewModel.logout()
                    } label: {
                        Text("Log Out")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .onAppear {
            // Load yacht-related data when the view appears
            loadYachtData()
        }
    }

    private func loadYachtData() {
        // Only load data if we have a selected yacht
        guard authViewModel.selectedYacht != nil else {
            print("⚠️ No selected yacht - skipping data load")
            return
        }

        Task {
            await loadBookings()
            await loadLatestLogEntry()
            await loadRecentActivity()
            await checkBookingLogStatus()
        }
    }

    private var logButtonText: String {
        if let _ = activeBooking {
            if !hasDepartureLog {
                return "Create Departure Log"
            } else {
                return "Create Return Log"
            }
        }
        return "Create Trip Log"
    }

    private func checkBookingLogStatus() async {
        guard let yacht = authViewModel.selectedYacht,
              let user = authViewModel.currentUser else {
            print("⚠️ No yacht or user - cannot check booking status")
            return
        }

        do {
            // Get bookings for this yacht and user
            let allBookings = try await APIService.shared.getBookings(yachtId: yacht.id)

            // Find active booking (current date within start/end date and confirmed/in_progress status)
            let now = Date()
            activeBooking = allBookings.first { booking in
                booking.startDate <= now &&
                booking.endDate >= now &&
                booking.userId == user.id &&
                (booking.status == .confirmed || booking.status == .inProgress)
            }

            // If we have an active booking, check for departure log
            if let booking = activeBooking {
                let logs = try await APIService.shared.getLogbookEntries(bookingId: booking.id)
                hasDepartureLog = logs.contains { $0.entryType == .depart }
                print("✅ Active booking found. Has departure log: \(hasDepartureLog)")
            } else {
                hasDepartureLog = false
                print("ℹ️ No active booking found for current user")
            }
        } catch {
            print("❌ Error checking booking/log status: \(error)")
            activeBooking = nil
            hasDepartureLog = false
        }
    }

    private func loadRecentActivity() async {
        guard let yacht = authViewModel.selectedYacht else {
            print("⚠️ No yacht selected - cannot load activities")
            return
        }

        isLoadingActivities = true

        do {
            recentActivities = try await APIService.shared.getRecentActivity(yachtId: yacht.id)
            print("✅ Loaded \(recentActivities.count) recent activities for \(yacht.name)")
        } catch {
            print("❌ Error loading activities: \(error)")
            // Keep empty list on error
        }

        isLoadingActivities = false
    }

    private func loadBookings() async {
        guard let yacht = authViewModel.selectedYacht else {
            print("⚠️ No yacht selected - cannot load bookings")
            return
        }

        isLoadingBookings = true
        bookingsError = nil

        do {
            bookings = try await APIService.shared.getBookings(yachtId: yacht.id)
            print("✅ Loaded \(bookings.count) bookings for \(yacht.name)")
        } catch {
            bookingsError = error.localizedDescription
            print("❌ Error loading bookings: \(error)")
        }

        isLoadingBookings = false
    }

    private func loadLatestLogEntry() async {
        guard let yacht = authViewModel.selectedYacht else {
            print("⚠️ No yacht selected - cannot load log entry")
            return
        }

        isLoadingLogEntry = true

        do {
            let entries = try await APIService.shared.getLogbookEntries(yachtId: yacht.id)
            latestLogEntry = entries.first // API returns ordered by created_at DESC
            print("✅ Loaded latest log entry for \(yacht.name)")
        } catch {
            print("❌ Error loading latest log entry: \(error)")
            // Keep using default values if API fails
        }

        isLoadingLogEntry = false
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
    let latestLogEntry: LogbookEntry?
    let buttonText: String

    var body: some View {
        VStack(spacing: 15) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    icon: "gauge.high",
                    value: String(format: "%.1f", latestLogEntry?.portEngineHours ?? 1247.5),
                    label: "Port Engine",
                    color: .blue
                )

                StatCard(
                    icon: "gauge.high",
                    value: String(format: "%.1f", latestLogEntry?.starboardEngineHours ?? 1248.2),
                    label: "Starboard Engine",
                    color: .blue
                )
            }

            StatCard(
                icon: "fuelpump.fill",
                value: String(format: "%.0fL", latestLogEntry?.fuelLiters ?? 2550),
                label: "Current Fuel",
                color: .green
            )

            // Create Trip Log Button (text changes based on booking/log status)
            Button {
                showingLogEntry = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(buttonText)
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
            Text("Upcoming Bookings")
                .font(.headline)
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

                VStack(alignment: .leading, spacing: 4) {
                    Text("Details")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text("\(formattedDate(booking.startDate)) - \(formattedDate(booking.endDate))")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(statusColor(booking.status))
                        Text(booking.status.rawValue.capitalized)
                            .foregroundColor(statusColor(booking.status))
                    }
                    .font(.caption)

                    if booking.standbyDays > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                            Text("\(booking.standbyDays) standby days")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Recent Activity Section
struct RecentActivitySection: View {
    let activities: [Activity]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.headline)
                .padding(.horizontal)

            if isLoading {
                ProgressView("Loading activities...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if activities.isEmpty {
                Text("No recent activity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(activities) { activity in
                        ActivityRow(
                            icon: activity.icon,
                            title: activity.title,
                            subtitle: activity.subtitle,
                            time: activity.timeAgo,
                            color: activity.colorValue
                        )
                    }
                }
                .padding(.horizontal)
            }
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
