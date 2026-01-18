import SwiftUI

struct DashboardView: View {
    @State private var yachts: [Yacht] = []
    @State private var upcomingBookings: [Booking] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Yacht Cards
                    if !yachts.isEmpty {
                        ForEach(yachts) { yacht in
                            YachtCard(yacht: yacht)
                        }
                    }

                    // Upcoming Bookings
                    if !upcomingBookings.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Upcoming Bookings")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(upcomingBookings) { booking in
                                BookingRow(booking: booking)
                            }
                        }
                    }

                    if isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        isLoading = true
        do {
            yachts = try await APIService.shared.getYachts()
            upcomingBookings = try await APIService.shared.getBookings()
        } catch {
            print("Error loading dashboard: \(error)")
        }
        isLoading = false
    }
}

struct YachtCard: View {
    let yacht: Yacht

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageUrl = yacht.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(yacht.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(yacht.manufacturer) \(yacht.model)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Label("\(Int(yacht.length))ft", systemImage: "ruler")
                    Spacer()
                    Label(yacht.homePort, systemImage: "location.fill")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct BookingRow: View {
    let booking: Booking

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Booking")
                    .font(.headline)
                Text(booking.startDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(booking.status.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor(booking.status).opacity(0.2))
                .foregroundColor(statusColor(booking.status))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
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

#Preview {
    DashboardView()
}
