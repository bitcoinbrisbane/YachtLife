import SwiftUI

struct InvoicesView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var invoices: [InvoiceInfo] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            List {
                ForEach(invoices) { invoice in
                    NavigationLink(destination: InvoiceDetailView(invoiceId: invoice.id)) {
                        InvoiceListRow(invoice: invoice)
                    }
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
        guard let yacht = authViewModel.selectedYacht else {
            print("⚠️ No selected yacht - skipping invoice load")
            isLoading = false
            return
        }

        isLoading = true
        do {
            let viewModel = try await APIService.shared.getInvoicesDashboard(yachtId: yacht.id)
            invoices = viewModel.invoices
            print("✅ Loaded \(invoices.count) invoices for \(yacht.name)")
        } catch {
            print("❌ Error loading invoices: \(error)")
        }
        isLoading = false
    }
}

struct InvoiceListRow: View {
    let invoice: InvoiceInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Invoice #\(invoice.invoiceNumber)")
                    .font(.headline)
                Spacer()
                Text(invoice.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(invoice.statusColor.opacity(0.2))
                    .foregroundColor(invoice.statusColor)
                    .cornerRadius(6)
            }

            Text(invoice.description)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Text(invoice.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("Due \(invoice.dueDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(invoice.isOverdue ? .red : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Invoice Detail View
struct InvoiceDetailView: View {
    let invoiceId: UUID
    @State private var invoice: Invoice?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let invoice = invoice {
                List {
                    Section("Invoice Details") {
                        LabeledContent("Invoice Number", value: invoice.xeroInvoiceId ?? "N/A")
                        LabeledContent("Amount", value: String(format: "$%.2f", invoice.amount))
                        LabeledContent("Due Date", value: invoice.dueDate, format: .dateTime)
                        LabeledContent("Issued Date", value: invoice.createdAt, format: .dateTime)
                        LabeledContent("Status", value: invoice.status.rawValue.capitalized)
                    }

                    Section("Description") {
                        Text(invoice.description)
                    }

                    if let paidAt = invoice.paidAt {
                        Section("Payment") {
                            LabeledContent("Paid Date", value: paidAt, format: .dateTime)
                        }
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
                .navigationTitle("Invoice Details")
            } else if isLoading {
                ProgressView("Loading invoice...")
            } else {
                Text("Invoice not found")
            }
        }
        .task {
            // TODO: Implement getInvoice(id:) in APIService
            // For now, we'd need to add an endpoint to fetch individual invoice details
            print("Loading invoice \(invoiceId)")
        }
    }
}

#Preview {
    InvoicesView()
        .environmentObject(AuthenticationViewModel())
}
