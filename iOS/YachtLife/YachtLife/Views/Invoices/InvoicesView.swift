import SwiftUI

struct InvoicesView: View {
    @State private var invoices: [Invoice] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            List(invoices) { invoice in
                NavigationLink(destination: InvoiceDetailView(invoice: invoice)) {
                    InvoiceRow(invoice: invoice)
                }
            }
            .navigationTitle("Invoices")
            .task {
                await loadInvoices()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }

    private func loadInvoices() async {
        isLoading = true
        do {
            invoices = try await APIService.shared.getInvoices()
        } catch {
            print("Error loading invoices: \(error)")
        }
        isLoading = false
    }
}

struct InvoiceRow: View {
    let invoice: Invoice

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(invoice.description)
                    .font(.headline)
                Text("Due: \(invoice.dueDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("$\(invoice.amount, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(invoice.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(invoice.status).opacity(0.2))
                    .foregroundColor(statusColor(invoice.status))
                    .cornerRadius(6)
            }
        }
    }

    private func statusColor(_ status: Invoice.InvoiceStatus) -> Color {
        switch status {
        case .paid: return .green
        case .sent: return .blue
        case .draft: return .gray
        case .overdue: return .red
        case .cancelled: return .gray
        }
    }
}

struct InvoiceDetailView: View {
    let invoice: Invoice

    var body: some View {
        List {
            Section("Invoice Details") {
                LabeledContent("Amount", value: String(format: "$%.2f", invoice.amount))
                LabeledContent("Due Date", value: invoice.dueDate, format: .dateTime)
                LabeledContent("Status", value: invoice.status.rawValue.capitalized)
            }

            Section("Description") {
                Text(invoice.description)
            }

            if invoice.status != .paid {
                Section {
                    Button("Pay with Apple Pay") {
                        // TODO: Implement Apple Pay
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Invoice")
    }
}

#Preview {
    InvoicesView()
}
