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
                Section {
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
                } header: {
                    Text("Engine Hours")
                }

                Section {
                    HStack {
                        Image(systemName: "fuelpump.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)

                        TextField("Fuel Level (Litres)", text: $fuelLevel)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("Fuel Level")
                } footer: {
                    Text("The system will automatically determine if this is a departure or return log based on your booking.")
                        .font(.caption)
                }

                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Trip Log Entry")
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
            guard let portHours = Double(portEngineHours),
                  let starboardHours = Double(starboardEngineHours),
                  let fuelLit = Double(fuelLevel) else {
                errorMessage = "Please enter valid numbers"
                isSaving = false
                return
            }

            let request = CreateLogbookEntryRequest(
                yachtID: yachtID,
                portEngineHours: portHours,
                starboardEngineHours: starboardHours,
                fuelLiters: fuelLit,
                notes: notes.isEmpty ? nil : notes
            )

            _ = try await APIService.shared.createLogbookEntry(request)
            print("✅ Trip log entry saved successfully")
            dismiss()
        } catch {
            print("❌ Error saving trip log entry: \(error)")
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}

#Preview {
    CreateLogEntryView(yachtID: UUID())
}
