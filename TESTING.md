# YachtLife Testing Guide

This document explains the test suite for YachtLife and how to run the tests.

## Overview

We have comprehensive unit tests for both the Go backend and Swift iOS app to catch encoding/decoding errors early.

## Go Backend Tests

### Running Tests

```bash
# Run all tests
cd backend
go test ./internal/models/...

# Run with verbose output
go test -v ./internal/models/...

# Run specific test
go test -v ./internal/models/ -run TestInvoiceJSONEncoding

# Run with coverage
go test -cover ./internal/models/...
```

### Test Files

#### `internal/models/invoice_test.go`

Tests invoice model JSON encoding/decoding:
- **TestInvoiceJSONEncoding**: Verifies Invoice model encodes and decodes correctly
- **TestInvoiceViewModelJSONEncoding**: Tests InvoiceViewModel with all nested structures
- **TestInvoiceInfoJSONEncoding**: Validates snake_case field names in JSON output
- **TestInvoiceStatusValues**: Confirms invoice status enum values
- **TestGenerateXeroURL**: Tests Xero URL generation logic

**Key scenarios tested:**
- All fields encode/decode correctly
- Snake_case JSON field names (`invoice_number`, `due_date`, etc.)
- Optional fields (nullable pointers)
- Date/time handling
- Nested structures (stats, invoices array, activities array)

#### `internal/models/dashboard_test.go`

Tests dashboard model JSON encoding/decoding:
- **TestDashboardViewModelJSONEncoding**: Full dashboard with all fields
- **TestDashboardViewModelWithNilActiveBooking**: Critical test for missing booking scenario
- **TestBookingInfoJSONEncoding**: Booking info structure
- **TestActivityInfoJSONEncoding**: Activity info structure

**Key scenarios tested:**
- `has_departure_log` and `has_return_log` are ALWAYS present (not omitted when false)
- Active booking can be nil
- Empty arrays for bookings and activities
- Zero values for engine hours and fuel

### What These Tests Catch

1. **Missing Fields**: If backend doesn't return a required field, Swift decoding will fail
2. **Wrong Field Names**: Snake_case vs camelCase mismatches
3. **Type Mismatches**: String vs Int, nullable vs non-nullable
4. **Omitted Boolean Fields**: The `has_departure_log` bug we fixed
5. **Date Format Issues**: ISO8601 encoding/decoding

## Swift iOS Tests

### Running Tests

```bash
# From command line
cd iOS/YachtLife
xcodebuild test -scheme YachtLife -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Or use Xcode:
# 1. Open YachtLife.xcodeproj
# 2. Press Cmd+U to run all tests
# 3. Or click test diamond next to individual tests
```

### Test Files

#### `YachtLifeTests/InvoiceModelTests.swift`

Tests invoice model decoding from backend JSON:
- **testInvoiceDecoding**: Decodes full invoice with all fields
- **testInvoiceDecodingWithMissingOptionalFields**: Tests nil optionals
- **testInvoiceStatusDecoding**: Validates all status enum values
- **testInvoiceInfoDecoding**: Tests list view invoice info
- **testInvoiceInfoOverdue**: Tests overdue invoice scenario
- **testInvoiceViewModelDecoding**: Full invoice dashboard response
- **testInvoiceInfoStatusColor**: UI color mapping logic
- **testInvoiceInfoFormattedAmount**: Currency formatting

**Key scenarios tested:**
- Real JSON from backend API
- All invoice statuses (draft, sent, paid, overdue, cancelled)
- Missing optional fields (xeroInvoiceId, xeroURL, paidAt)
- `issued_date` field decoding (caught our bug!)
- Computed properties (statusColor, formattedAmount)

#### `YachtLifeTests/DashboardModelTests.swift`

Tests dashboard model decoding:
- **testDashboardViewModelDecoding**: Full dashboard with active booking
- **testDashboardViewModelWithoutActiveBooking**: No active booking scenario (critical!)
- **testDashboardViewModelWithDepartureButNoReturnLog**: Partial log state
- **testBookingInfoDecoding**: Booking structure
- **testActivityInfoDecoding**: Activity feed items
- **testActivityInfoColorValue**: Color string to SwiftUI Color mapping
- **testVesselInfoDecoding**: Vessel details
- **testDashboardViewModelWithZeroEngineHours**: New owner scenario

**Key scenarios tested:**
- `has_departure_log` and `has_return_log` required fields
- Nil vs empty arrays
- Zero vs missing engine hours
- Date parsing with ISO8601

### What These Tests Catch

1. **Backend API Changes**: If backend changes field names or types, tests fail immediately
2. **Missing CodingKeys**: If you forget to add snake_case mapping
3. **Required vs Optional**: If backend returns nil but Swift expects non-nil
4. **Date Parsing**: ISO8601 format must match exactly
5. **Enum Values**: Status strings must match exactly

## Common Issues These Tests Prevent

### 1. The `has_departure_log` Bug

**Problem**: Backend omitted boolean fields when false, causing Swift decode failure.

**Test that catches it**: `testDashboardViewModelWithoutActiveBooking`

```swift
XCTAssertFalse(dashboard.hasDepartureLog, "has_departure_log must be false, not missing")
XCTAssertFalse(dashboard.hasReturnLog, "has_return_log must be false, not missing")
```

### 2. The `issued_date` Bug

**Problem**: Swift Invoice model was missing `issuedDate` field.

**Test that catches it**: `testInvoiceDecoding`

```swift
XCTAssertNotNil(invoice.issuedDate, "issued_date must be decoded")
```

### 3. Snake Case Mismatches

**Problem**: Backend uses `invoice_number` but Swift expects `invoiceNumber`.

**Test that catches it**: `testInvoiceInfoJSONEncoding`

```go
assert.Contains(t, jsonMap, "invoice_number", "Should use snake_case for invoice_number")
```

## Running Tests in CI/CD

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: Run backend tests
        run: |
          cd backend
          go test -v -cover ./internal/models/...

  ios-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run iOS tests
        run: |
          cd iOS/YachtLife
          xcodebuild test \
            -scheme YachtLife \
            -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Best Practices

### When Adding New Models

1. **Go Backend**: Create `*_test.go` file with:
   - JSON encoding test
   - JSON decoding test
   - Snake_case field verification
   - Nil/zero value tests

2. **Swift iOS**: Create test in `YachtLifeTests/` with:
   - Decoding from real JSON
   - Missing optional fields test
   - All enum values test
   - Edge cases (nil, empty, zero)

### When Changing Existing Models

1. Run tests BEFORE making changes (should pass)
2. Make your changes
3. Run tests AGAIN (they should fail if you broke something)
4. Update tests to match new expected behavior
5. Verify tests pass with new code

### Test-Driven Development

1. Write the test first (it should fail)
2. Implement the feature
3. Run test (it should pass)
4. Refactor if needed
5. Run test again (still passes)

## Dependencies

### Go Tests
- `github.com/stretchr/testify` - assertion library
  ```bash
  go get github.com/stretchr/testify
  ```

### Swift Tests
- XCTest framework (included with Xcode)
- No additional dependencies needed

## Troubleshooting

### Go Tests Fail with "cannot find package"

```bash
cd backend
go mod tidy
go mod download
```

### Swift Tests Fail with Simulator Not Found

```bash
# List available simulators
xcrun simctl list devices

# Use a different simulator
xcodebuild test -scheme YachtLife -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Date Parsing Failures

Ensure both Go and Swift use ISO8601:

**Go:**
```go
time.Now().Format(time.RFC3339)
```

**Swift:**
```swift
decoder.dateDecodingStrategy = .iso8601
```

## Next Steps

1. Add tests for handlers (`*_handler_test.go`)
2. Add integration tests (full API calls)
3. Add UI tests for Swift views
4. Set up CI/CD pipeline
5. Add test coverage reporting
