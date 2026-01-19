import SwiftUI

struct BookingsView: View {
    @State private var bookings: [Booking] = []
    @State private var isLoading = true
    @State private var showingCreateBooking = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(bookings) { booking in
                    NavigationLink(destination: BookingDetailView(booking: booking)) {
                        BookingListRow(booking: booking)
                    }
                }
            }
            .navigationTitle("Bookings")
            .toolbar {
                Button {
                    showingCreateBooking = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingCreateBooking) {
                CreateBookingView()
            }
            .task {
                await loadBookings()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }

    private func loadBookings() async {
        isLoading = true
        do {
            bookings = try await APIService.shared.getBookings()
        } catch {
            print("Error loading bookings: \(error)")
        }
        isLoading = false
    }
}

struct BookingListRow: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(booking.startDate, style: .date)
                    .font(.headline)
                Spacer()
                Text(booking.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
            }

            Text("\(booking.standbyDays) standby days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct BookingDetailView: View {
    let booking: Booking

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Start") {
                    Text(formattedDate(booking.startDate))
                }
                LabeledContent("End") {
                    Text(formattedDate(booking.endDate))
                }
                LabeledContent("Status") {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(statusColor(booking.status))
                        Text(booking.status.rawValue.capitalized)
                            .foregroundColor(statusColor(booking.status))
                    }
                }
                LabeledContent("Standby Days", value: "\(booking.standbyDays)")
                LabeledContent("Created") {
                    Text(formattedDate(booking.createdAt))
                }
            }

            if let notes = booking.notes {
                Section("Notes") {
                    Text(notes)
                }
            }
        }
        .navigationTitle("Booking Details")
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

struct CreateBookingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7)
    @State private var standbyDays = 2

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                Stepper("Standby Days: \(standbyDays)", value: $standbyDays, in: 0...7)
            }
            .navigationTitle("New Booking")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        // TODO: Implement booking creation
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BookingsView()
}
