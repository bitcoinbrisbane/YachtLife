import SwiftUI

struct InvoicesView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var viewModel: InvoiceViewModel?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedFilter: InvoiceFilter = .all

    enum InvoiceFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case overdue = "Overdue"
        case paid = "Paid"
        case draft = "Draft"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let viewModel = viewModel {
                        // Stats Cards
                        StatsSection(stats: viewModel.stats)
                            .padding(.horizontal)
                            .padding(.top, 10)

                        // Filter Picker
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(InvoiceFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        // Invoices List
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Invoices")
                                .font(.headline)
                                .padding(.horizontal)

                            if filteredInvoices.isEmpty {
                                Text("No invoices found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                ForEach(filteredInvoices) { invoice in
                                    NavigationLink(destination: InvoiceDetailView(invoiceId: invoice.id)) {
                                        InvoiceCard(invoice: invoice)
                                    }
                                }
                            }
                        }

                        // Recent Activities
                        if !viewModel.recentActivities.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Recent Activity")
                                    .font(.headline)
                                    .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(viewModel.recentActivities) { activity in
                                        ActivityRow(
                                            icon: activity.icon,
                                            title: activity.title,
                                            subtitle: activity.subtitle,
                                            time: activity.timeAgo,
                                            color: activity.colorValue
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 10)
                        }
                    } else if isLoading {
                        ProgressView("Loading invoices...")
                            .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text("Error loading invoices")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Invoices")
            .task {
                await loadInvoices()
            }
            .refreshable {
                await loadInvoices()
            }
        }
    }

    var filteredInvoices: [InvoiceInfo] {
        guard let viewModel = viewModel else { return [] }

        switch selectedFilter {
        case .all:
            return viewModel.invoices
        case .pending:
            return viewModel.invoices.filter { $0.status.lowercased() == "sent" }
        case .overdue:
            return viewModel.invoices.filter { $0.isOverdue }
        case .paid:
            return viewModel.invoices.filter { $0.status.lowercased() == "paid" }
        case .draft:
            return viewModel.invoices.filter { $0.status.lowercased() == "draft" }
        }
    }

    private func loadInvoices() async {
        guard let yacht = authViewModel.selectedYacht else {
            print("⚠️ No selected yacht - skipping invoice load")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            viewModel = try await APIService.shared.getInvoicesDashboard(yachtId: yacht.id)
            print("✅ Loaded invoice dashboard for \(yacht.name)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error loading invoices: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    let stats: InvoiceStats

    var body: some View {
        VStack(spacing: 15) {
            // Outstanding Amount Card
            StatCard(
                icon: "dollarsign.circle.fill",
                value: String(format: "$%.2f", stats.totalOutstanding),
                label: "Total Outstanding",
                color: stats.totalOutstanding > 0 ? .orange : .green
            )

            // Count Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(stats.paidCount)",
                    label: "Paid",
                    color: .green
                )

                StatCard(
                    icon: "clock.fill",
                    value: "\(stats.pendingCount)",
                    label: "Pending",
                    color: .blue
                )

                StatCard(
                    icon: "exclamationmark.triangle.fill",
                    value: "\(stats.overdueCount)",
                    label: "Overdue",
                    color: .red
                )

                StatCard(
                    icon: "doc.text",
                    value: "\(stats.draftCount)",
                    label: "Draft",
                    color: .gray
                )
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Invoice Card
struct InvoiceCard: View {
    let invoice: InvoiceInfo

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                // Status Icon
                Image(systemName: invoice.statusIcon)
                    .font(.system(size: 24))
                    .foregroundColor(invoice.statusColor)
                    .frame(width: 40, height: 40)
                    .background(invoice.statusColor.opacity(0.15))
                    .cornerRadius(10)

                // Invoice Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(invoice.description)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Invoice #\(invoice.invoiceNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(invoice.dueDateInfo)
                            .font(.caption)
                        if invoice.isOverdue {
                            Text("•")
                                .font(.caption)
                            Text(invoice.formattedDueDate)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(invoice.isOverdue ? .red : .secondary)
                }

                Spacer()

                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text(invoice.formattedAmount)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(invoice.status.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(invoice.statusColor.opacity(0.2))
                        .foregroundColor(invoice.statusColor)
                        .cornerRadius(6)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
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
                        LabeledContent("Issued Date", value: invoice.issuedDate, format: .dateTime)
                        LabeledContent("Status", value: invoice.status.capitalized)
                    }

                    Section("Description") {
                        Text(invoice.description)
                    }

                    if let paidDate = invoice.paidDate {
                        Section("Payment") {
                            LabeledContent("Paid Date", value: paidDate, format: .dateTime)
                        }
                    }

                    if invoice.status != "paid" {
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
