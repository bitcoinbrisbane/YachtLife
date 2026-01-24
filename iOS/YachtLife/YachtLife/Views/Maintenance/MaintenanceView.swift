import SwiftUI

struct MaintenanceView: View {
    @State private var requests: [MaintenanceRequest] = []
    @State private var isLoading = true
    @State private var showingCreateRequest = false

    var body: some View {
        NavigationStack {
            List(requests) { request in
                MaintenanceRequestRow(request: request)
            }
            .navigationTitle("Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    showingCreateRequest = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingCreateRequest) {
                CreateMaintenanceRequestView()
            }
            .task {
                await loadRequests()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }

    private func loadRequests() async {
        isLoading = true
        do {
            requests = try await APIService.shared.getMaintenanceRequests()
        } catch {
            print("Error loading maintenance requests: \(error)")
        }
        isLoading = false
    }
}

struct MaintenanceRequestRow: View {
    let request: MaintenanceRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(request.title)
                    .font(.headline)
                Spacer()
                Text(request.urgency.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(urgencyColor(request.urgency).opacity(0.2))
                    .foregroundColor(urgencyColor(request.urgency))
                    .cornerRadius(6)
            }

            Text(request.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text(request.status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let location = request.location {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func urgencyColor(_ urgency: MaintenanceRequest.Urgency) -> Color {
        switch urgency {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

struct CreateMaintenanceRequestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var urgency: MaintenanceRequest.Urgency = .medium

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Location (optional)", text: $location)

                Picker("Urgency", selection: $urgency) {
                    Text("Low").tag(MaintenanceRequest.Urgency.low)
                    Text("Medium").tag(MaintenanceRequest.Urgency.medium)
                    Text("High").tag(MaintenanceRequest.Urgency.high)
                    Text("Critical").tag(MaintenanceRequest.Urgency.critical)
                }

                Section("Photos") {
                    Button("Add Photos") {
                        // TODO: Implement photo picker
                    }
                }
            }
            .navigationTitle("New Maintenance Request")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        // TODO: Implement submission
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

#Preview {
    MaintenanceView()
}
