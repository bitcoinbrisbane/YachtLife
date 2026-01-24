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
                        LabeledContent("Issued Date", value: formatDate(invoice.issuedDate))
                        LabeledContent("Due Date", value: formatDate(invoice.dueDate))
                        LabeledContent("Status", value: invoice.status.rawValue.capitalized)
                    }

                    Section("Description") {
                        Text(invoice.description)
                    }

                    if let paidAt = invoice.paidAt {
                        Section("Payment") {
                            LabeledContent("Paid Date", value: formatDate(paidAt))
                        }
                    }

                    if let xeroURL = invoice.xeroURL, let url = URL(string: xeroURL) {
                        Section {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "arrow.up.right.square")
                                    Text("View in Xero")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Apple Pay button - only show for unpaid invoices
                    if invoice.status != .paid {
                        Section {
                            Button(action: {
                                // Placeholder - not wired up yet
                                print("Apple Pay button tapped")
                            }) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.title3)
                                    Text("Pay with Apple Pay")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.black)
                                .cornerRadius(8)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .navigationTitle(invoice.xeroInvoiceId ?? "Invoice")
                .navigationBarTitleDisplayMode(.inline)
            } else if isLoading {
                ProgressView("Loading invoice...")
            } else {
                Text("Invoice not found")
            }
        }
        .task {
            await loadInvoice()
        }
    }

    private func loadInvoice() async {
        isLoading = true
        do {
            invoice = try await APIService.shared.getInvoice(id: invoiceId)
            print("✅ Loaded invoice \(invoiceId)")
        } catch {
            print("❌ Error loading invoice: \(error)")
        }
        isLoading = false
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    InvoicesView()
        .environmentObject(AuthenticationViewModel())
}
