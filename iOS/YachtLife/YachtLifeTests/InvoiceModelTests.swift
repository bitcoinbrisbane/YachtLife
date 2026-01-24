import XCTest
@testable import YachtLife

class InvoiceModelTests: XCTestCase {

    // MARK: - Invoice Model Tests

    func testInvoiceDecoding() throws {
        let json = """
        {
            "id": "1fdd144a-555f-41bf-8fa4-c7dae1338871",
            "yacht_id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
            "user_id": "c0a3e3c4-a59e-411b-8799-e2ffb684f15c",
            "xero_invoice_id": "XERO-INV-003-SENT",
            "invoice_number": "YL-2025-001",
            "xero_url": "https://go.xero.com/AccountsReceivable/View.aspx?InvoiceID=XERO-INV-003-SENT",
            "amount": 4120.75,
            "due_date": "2026-02-05T00:00:00Z",
            "issued_date": "2026-01-21T00:00:00Z",
            "status": "sent",
            "description": "January 2025 - Monthly ownership costs and insurance",
            "created_at": "2026-01-24T12:14:36.617+10:00",
            "updated_at": "2026-01-24T12:14:36.617+10:00"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let invoice = try decoder.decode(Invoice.self, from: json)

        XCTAssertEqual(invoice.xeroInvoiceId, "XERO-INV-003-SENT")
        XCTAssertEqual(invoice.invoiceNumber, "YL-2025-001")
        XCTAssertEqual(invoice.amount, 4120.75)
        XCTAssertEqual(invoice.status, .sent)
        XCTAssertEqual(invoice.description, "January 2025 - Monthly ownership costs and insurance")
        XCTAssertNotNil(invoice.xeroURL)
        XCTAssertNotNil(invoice.issuedDate, "issued_date must be decoded")
    }

    func testInvoiceDecodingWithMissingOptionalFields() throws {
        let json = """
        {
            "id": "1fdd144a-555f-41bf-8fa4-c7dae1338871",
            "yacht_id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
            "user_id": "c0a3e3c4-a59e-411b-8799-e2ffb684f15c",
            "invoice_number": "YL-2025-001",
            "amount": 4120.75,
            "due_date": "2026-02-05T00:00:00Z",
            "issued_date": "2026-01-21T00:00:00Z",
            "status": "draft",
            "description": "Test invoice",
            "created_at": "2026-01-24T12:14:36.617+10:00",
            "updated_at": "2026-01-24T12:14:36.617+10:00"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let invoice = try decoder.decode(Invoice.self, from: json)

        XCTAssertNil(invoice.xeroInvoiceId)
        XCTAssertNil(invoice.xeroURL)
        XCTAssertNil(invoice.paidAt)
        XCTAssertEqual(invoice.status, .draft)
    }

    func testInvoiceStatusDecoding() throws {
        let statuses: [(String, Invoice.InvoiceStatus)] = [
            ("draft", .draft),
            ("sent", .sent),
            ("paid", .paid),
            ("overdue", .overdue),
            ("cancelled", .cancelled)
        ]

        for (jsonValue, expectedStatus) in statuses {
            let json = """
            {
                "id": "1fdd144a-555f-41bf-8fa4-c7dae1338871",
                "yacht_id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
                "user_id": "c0a3e3c4-a59e-411b-8799-e2ffb684f15c",
                "invoice_number": "TEST-001",
                "amount": 100.00,
                "due_date": "2026-02-05T00:00:00Z",
                "issued_date": "2026-01-21T00:00:00Z",
                "status": "\(jsonValue)",
                "description": "Test",
                "created_at": "2026-01-24T12:14:36.617+10:00",
                "updated_at": "2026-01-24T12:14:36.617+10:00"
            }
            """.data(using: .utf8)!

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let invoice = try decoder.decode(Invoice.self, from: json)
            XCTAssertEqual(invoice.status, expectedStatus, "Failed to decode status: \(jsonValue)")
        }
    }

    // MARK: - InvoiceInfo Model Tests

    func testInvoiceInfoDecoding() throws {
        let json = """
        {
            "id": "74d562bb-4721-4930-8567-91642514fbb3",
            "invoice_number": "YL-2025-002",
            "description": "February 2025 - Upcoming maintenance and berth fees",
            "amount": 2850,
            "due_date": "2026-02-24T00:00:00Z",
            "issued_date": "2026-01-24T00:00:00Z",
            "status": "draft",
            "is_overdue": false,
            "days_until_due": 30
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let info = try decoder.decode(InvoiceInfo.self, from: json)

        XCTAssertEqual(info.invoiceNumber, "YL-2025-002")
        XCTAssertEqual(info.amount, 2850)
        XCTAssertEqual(info.status, "draft")
        XCTAssertFalse(info.isOverdue)
        XCTAssertEqual(info.daysUntilDue, 30)
        XCTAssertNotNil(info.issuedDate, "issued_date must be decoded")
    }

    func testInvoiceInfoOverdue() throws {
        let json = """
        {
            "id": "57968bb7-6f3c-4395-abf9-2a9a3ca69d97",
            "invoice_number": "YL-2024-002",
            "description": "December 2024 - Fuel, cleaning and syndicate fees",
            "amount": 3890.5,
            "due_date": "2026-01-19T00:00:00Z",
            "issued_date": "2025-12-14T00:00:00Z",
            "status": "overdue",
            "is_overdue": true,
            "days_until_due": -5
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let info = try decoder.decode(InvoiceInfo.self, from: json)

        XCTAssertTrue(info.isOverdue)
        XCTAssertEqual(info.daysUntilDue, -5)
        XCTAssertEqual(info.status, "overdue")
    }

    // MARK: - InvoiceViewModel Tests

    func testInvoiceViewModelDecoding() throws {
        let json = """
        {
            "stats": {
                "total_outstanding": 8011.25,
                "paid_count": 1,
                "overdue_count": 1,
                "pending_count": 1,
                "draft_count": 1
            },
            "invoices": [
                {
                    "id": "74d562bb-4721-4930-8567-91642514fbb3",
                    "invoice_number": "YL-2025-002",
                    "description": "February 2025 - Upcoming maintenance and berth fees",
                    "amount": 2850,
                    "due_date": "2026-02-24T00:00:00Z",
                    "issued_date": "2026-01-24T00:00:00Z",
                    "status": "draft",
                    "is_overdue": false,
                    "days_until_due": 30
                }
            ],
            "recent_activities": [
                {
                    "icon": "doc.text",
                    "title": "Draft Created",
                    "subtitle": "YL-2025-002",
                    "time": "2026-01-24T12:14:36.618063+10:00",
                    "color": "gray"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let viewModel = try decoder.decode(InvoiceViewModel.self, from: json)

        XCTAssertEqual(viewModel.stats.totalOutstanding, 8011.25)
        XCTAssertEqual(viewModel.stats.paidCount, 1)
        XCTAssertEqual(viewModel.stats.overdueCount, 1)
        XCTAssertEqual(viewModel.invoices.count, 1)
        XCTAssertEqual(viewModel.recentActivities.count, 1)
    }

    // MARK: - Helper Methods Tests

    func testInvoiceInfoStatusColor() {
        let paidInfo = createInvoiceInfo(status: "paid")
        XCTAssertEqual(paidInfo.statusColor, .green)

        let sentInfo = createInvoiceInfo(status: "sent")
        XCTAssertEqual(sentInfo.statusColor, .blue)

        let overdueInfo = createInvoiceInfo(status: "overdue")
        XCTAssertEqual(overdueInfo.statusColor, .red)

        let draftInfo = createInvoiceInfo(status: "draft")
        XCTAssertEqual(draftInfo.statusColor, .gray)
    }

    func testInvoiceInfoFormattedAmount() {
        let info = createInvoiceInfo(amount: 1234.56)
        XCTAssertEqual(info.formattedAmount, "$1234.56")
    }

    // MARK: - Helper Methods

    private func createInvoiceInfo(
        id: UUID = UUID(),
        invoiceNumber: String = "TEST-001",
        description: String = "Test invoice",
        amount: Double = 100.0,
        dueDate: Date = Date(),
        issuedDate: Date = Date(),
        status: String = "draft",
        isOverdue: Bool = false,
        daysUntilDue: Int = 30
    ) -> InvoiceInfo {
        return InvoiceInfo(
            id: id,
            invoiceNumber: invoiceNumber,
            description: description,
            amount: amount,
            dueDate: dueDate,
            issuedDate: issuedDate,
            status: status,
            isOverdue: isOverdue,
            daysUntilDue: daysUntilDue
        )
    }
}
