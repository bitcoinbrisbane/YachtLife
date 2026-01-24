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

            if let notes = booking.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct BookingDetailView: View {
    let booking: Booking
    @State private var bookingDetail: BookingDetail?
    @State private var isLoading = true

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
                LabeledContent("Created") {
                    Text(formattedDate(booking.createdAt))
                }
            }

            if let detail = bookingDetail, detail.hasLogbookData {
                // Departure Log Section
                if let departureLog = detail.departureLog {
                    Section("Departure Log") {
                        LabeledContent("Recorded") {
                            Text(formattedTime(departureLog.createdAt))
                                .font(.caption)
                        }

                        if let fuel = departureLog.fuelLiters {
                            LabeledContent("Fuel Level") {
                                Text("\(Int(fuel))L")
                                    .fontWeight(.semibold)
                            }
                        }

                        if let portHours = departureLog.portEngineHours {
                            LabeledContent("Port Engine") {
                                Text(String(format: "%.1f hrs", portHours))
                                    .fontWeight(.semibold)
                            }
                        }

                        if let starboardHours = departureLog.starboardEngineHours {
                            LabeledContent("Starboard Engine") {
                                Text(String(format: "%.1f hrs", starboardHours))
                                    .fontWeight(.semibold)
                            }
                        }

                        if let notes = departureLog.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Return Log Section
                if let returnLog = detail.returnLog {
                    Section("Return Log") {
                        LabeledContent("Recorded") {
                            Text(formattedTime(returnLog.createdAt))
                                .font(.caption)
                        }

                        if let fuel = returnLog.fuelLiters {
                            LabeledContent("Fuel Level") {
                                Text("\(Int(fuel))L")
                                    .fontWeight(.semibold)
                            }
                        }

                        if let portHours = returnLog.portEngineHours {
                            LabeledContent("Port Engine") {
                                Text(String(format: "%.1f hrs", portHours))
                                    .fontWeight(.semibold)
                            }
                        }

                        if let starboardHours = returnLog.starboardEngineHours {
                            LabeledContent("Starboard Engine") {
                                Text(String(format: "%.1f hrs", starboardHours))
                                    .fontWeight(.semibold)
                            }
                        }

                        if let notes = returnLog.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Summary Section (only if we have both departure and return)
                if detail.departureLog != nil && detail.returnLog != nil {
                    Section("Trip Summary") {
                        if let fuelConsumed = detail.fuelConsumed {
                            LabeledContent("Fuel Consumed") {
                                HStack(spacing: 4) {
                                    Image(systemName: "fuelpump.fill")
                                        .foregroundColor(.green)
                                    Text("\(Int(fuelConsumed))L")
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                        }

                        if let portDelta = detail.portHoursDelta {
                            LabeledContent("Port Engine Hours") {
                                Text(String(format: "+%.1f hrs", portDelta))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }

                        if let starboardDelta = detail.starboardHoursDelta {
                            LabeledContent("Starboard Engine Hours") {
                                Text(String(format: "+%.1f hrs", starboardDelta))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            } else if !isLoading {
                Section {
                    Text("No logbook entries for this booking")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }

            if let notes = booking.notes {
                Section("Notes") {
                    Text(notes)
                }
            }
        }
        .navigationTitle("Voyage")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isLoading {
                ProgressView("Loading...")
            }
        }
        .task {
            await loadBookingDetail()
        }
    }

    private func loadBookingDetail() async {
        isLoading = true
        do {
            bookingDetail = try await APIService.shared.getBookingDetail(id: booking.id)
            print("✅ Loaded booking detail with logbook data")
        } catch {
            print("❌ Error loading booking detail: \(error)")
        }
        isLoading = false
    }

    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
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

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
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
