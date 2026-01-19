import SwiftUI

struct CreateLogEntryView: View {
    @Environment(\.dismiss) var dismiss

    let yachtID: UUID
    let currentPortEngineHours: String
    let currentStarboardEngineHours: String
    let currentFuelLevel: String

    @State private var portEngineHours: String
    @State private var starboardEngineHours: String
    @State private var fuelLevel: String
    @State private var notes = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(yachtID: UUID, portEngineHours: String = "1247.5", starboardEngineHours: String = "1248.2", fuelLevel: String = "2550") {
        self.yachtID = yachtID
        self.currentPortEngineHours = portEngineHours
        self.currentStarboardEngineHours = starboardEngineHours
        self.currentFuelLevel = fuelLevel

        _portEngineHours = State(initialValue: portEngineHours)
        _starboardEngineHours = State(initialValue: starboardEngineHours)
        _fuelLevel = State(initialValue: fuelLevel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Engine Hours") {
                    HStack {
                        Image(systemName: "gauge.high")
                            .foregroundColor(.blue)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Port Engine")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Port Engine Hours", text: $portEngineHours)
                                .keyboardType(.decimalPad)
                        }
                    }

                    HStack {
                        Image(systemName: "gauge.high")
                            .foregroundColor(.blue)
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Starboard Engine")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Starboard Engine Hours", text: $starboardEngineHours)
                                .keyboardType(.decimalPad)
                        }
                    }
                }

                Section("Fuel") {
                    HStack {
                        Image(systemName: "fuelpump.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)

                        TextField("Fuel Level (Litres)", text: $fuelLevel)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Create Log Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveLogEntry()
                        }
                    }
                    .disabled(isSaving || portEngineHours.isEmpty || starboardEngineHours.isEmpty || fuelLevel.isEmpty)
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func saveLogEntry() async {
        isSaving = true
        errorMessage = nil

        do {
            // Calculate average engine hours and hours operated
            guard let portHours = Double(portEngineHours),
                  let starboardHours = Double(starboardEngineHours),
                  let fuelLit = Double(fuelLevel),
                  let prevPortHours = Double(currentPortEngineHours),
                  let prevStarboardHours = Double(currentStarboardEngineHours) else {
                errorMessage = "Please enter valid numbers"
                isSaving = false
                return
            }

            let hoursOperated = ((portHours - prevPortHours) + (starboardHours - prevStarboardHours)) / 2

            let request = CreateLogbookEntryRequest(
                yachtID: yachtID,
                entryType: .general,
                fuelLiters: fuelLit,
                fuelCost: nil,
                hoursOperated: hoursOperated > 0 ? hoursOperated : nil,
                notes: notes.isEmpty ? nil : notes
            )

            _ = try await APIService.shared.createLogbookEntry(request)
            print("✅ Log entry saved successfully")
            dismiss()
        } catch {
            print("❌ Error saving log entry: \(error)")
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}

#Preview {
    CreateLogEntryView(yachtID: UUID())
}
