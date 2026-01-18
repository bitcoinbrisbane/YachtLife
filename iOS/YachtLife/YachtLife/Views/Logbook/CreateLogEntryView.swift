import SwiftUI

struct CreateLogEntryView: View {
    @Environment(\.dismiss) var dismiss

    let currentPortEngineHours: String
    let currentStarboardEngineHours: String
    let currentFuelLevel: String

    @State private var portEngineHours: String
    @State private var starboardEngineHours: String
    @State private var fuelLevel: String
    @State private var notes = ""

    init(portEngineHours: String = "1247.5", starboardEngineHours: String = "1248.2", fuelLevel: String = "2550") {
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
                        saveLogEntry()
                    }
                    .disabled(portEngineHours.isEmpty || starboardEngineHours.isEmpty || fuelLevel.isEmpty)
                }
            }
        }
    }

    private func saveLogEntry() {
        // TODO: Save log entry to backend
        print("Saving log entry: Port Engine: \(portEngineHours)hrs, Starboard Engine: \(starboardEngineHours)hrs, Fuel: \(fuelLevel)L, Notes: \(notes)")
        dismiss()
    }
}

#Preview {
    CreateLogEntryView()
}
