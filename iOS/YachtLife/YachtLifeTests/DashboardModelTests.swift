import XCTest
@testable import YachtLife

class DashboardModelTests: XCTestCase {

    // MARK: - DashboardViewModel Tests

    func testDashboardViewModelDecoding() throws {
        let json = """
        {
            "user_name": "Captain Jack Sparrow",
            "vessel": {
                "id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
                "name": "Neptune's Pride",
                "manufacturer": "Riviera",
                "model": "Riviera 72 Sports Motor Yacht",
                "length": 72.0,
                "home_port": "Gold Coast Marina"
            },
            "port_engine_hours": 150.5,
            "starboard_engine_hours": 152.0,
            "fuel_liters": 500.0,
            "has_departure_log": false,
            "has_return_log": false,
            "active_booking": {
                "id": "525d960e-4dd0-453e-a995-d0cd89ba8932",
                "start_date": "2026-01-29T10:00:00Z",
                "end_date": "2026-02-01T19:00:00Z",
                "status": "confirmed",
                "notes": "Weekend cruise to Whitsundays"
            },
            "upcoming_bookings": [
                {
                    "id": "525d960e-4dd0-453e-a995-d0cd89ba8932",
                    "start_date": "2026-02-11T10:00:00Z",
                    "end_date": "2026-02-14T19:00:00Z",
                    "status": "pending",
                    "notes": "Family fishing trip"
                }
            ],
            "recent_activities": [
                {
                    "icon": "calendar",
                    "title": "Booking Created",
                    "subtitle": "Weekend cruise",
                    "time": "2026-01-24T10:00:00Z",
                    "color": "blue"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dashboard = try decoder.decode(DashboardViewModel.self, from: json)

        XCTAssertEqual(dashboard.userName, "Captain Jack Sparrow")
        XCTAssertEqual(dashboard.portEngineHours, 150.5)
        XCTAssertEqual(dashboard.starboardEngineHours, 152.0)
        XCTAssertEqual(dashboard.fuelLiters, 500.0)
        XCTAssertFalse(dashboard.hasDepartureLog)
        XCTAssertFalse(dashboard.hasReturnLog)
        XCTAssertNotNil(dashboard.activeBooking)
        XCTAssertEqual(dashboard.upcomingBookings.count, 1)
        XCTAssertEqual(dashboard.recentActivities.count, 1)
    }

    func testDashboardViewModelWithoutActiveBooking() throws {
        // This is critical - tests the bug we had where has_departure_log and has_return_log
        // were omitted when there was no active booking
        let json = """
        {
            "user_name": "Captain Jack Sparrow",
            "vessel": {
                "id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
                "name": "Neptune's Pride",
                "manufacturer": "Riviera",
                "model": "Riviera 72 Sports Motor Yacht",
                "length": 72.0,
                "home_port": "Gold Coast Marina"
            },
            "port_engine_hours": 0.0,
            "starboard_engine_hours": 0.0,
            "fuel_liters": 0.0,
            "has_departure_log": false,
            "has_return_log": false,
            "upcoming_bookings": [],
            "recent_activities": []
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dashboard = try decoder.decode(DashboardViewModel.self, from: json)

        XCTAssertNil(dashboard.activeBooking)
        XCTAssertFalse(dashboard.hasDepartureLog, "has_departure_log must be false, not missing")
        XCTAssertFalse(dashboard.hasReturnLog, "has_return_log must be false, not missing")
        XCTAssertTrue(dashboard.upcomingBookings.isEmpty)
        XCTAssertTrue(dashboard.recentActivities.isEmpty)
    }

    func testDashboardViewModelWithDepartureBut NoReturnLog() throws {
        let json = """
        {
            "user_name": "Captain Jack Sparrow",
            "vessel": {
                "id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
                "name": "Neptune's Pride",
                "manufacturer": "Riviera",
                "model": "Riviera 72 Sports Motor Yacht",
                "length": 72.0,
                "home_port": "Gold Coast Marina"
            },
            "port_engine_hours": 150.5,
            "starboard_engine_hours": 152.0,
            "fuel_liters": 500.0,
            "has_departure_log": true,
            "has_return_log": false,
            "active_booking": {
                "id": "525d960e-4dd0-453e-a995-d0cd89ba8932",
                "start_date": "2026-01-29T10:00:00Z",
                "end_date": "2026-02-01T19:00:00Z",
                "status": "in_progress",
                "notes": "Weekend cruise to Whitsundays"
            },
            "upcoming_bookings": [],
            "recent_activities": []
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dashboard = try decoder.decode(DashboardViewModel.self, from: json)

        XCTAssertTrue(dashboard.hasDepartureLog)
        XCTAssertFalse(dashboard.hasReturnLog)
        XCTAssertEqual(dashboard.activeBooking?.status, "in_progress")
    }

    // MARK: - BookingInfo Tests

    func testBookingInfoDecoding() throws {
        let json = """
        {
            "id": "525d960e-4dd0-453e-a995-d0cd89ba8932",
            "start_date": "2026-01-29T10:00:00Z",
            "end_date": "2026-02-01T19:00:00Z",
            "status": "confirmed",
            "notes": "Weekend cruise to Whitsundays"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let booking = try decoder.decode(BookingInfo.self, from: json)

        XCTAssertEqual(booking.status, "confirmed")
        XCTAssertEqual(booking.notes, "Weekend cruise to Whitsundays")
        XCTAssertNotNil(booking.startDate)
        XCTAssertNotNil(booking.endDate)
    }

    // MARK: - ActivityInfo Tests

    func testActivityInfoDecoding() throws {
        let json = """
        {
            "icon": "calendar",
            "title": "Booking Created",
            "subtitle": "Weekend cruise",
            "time": "2026-01-24T10:00:00Z",
            "color": "blue"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let activity = try decoder.decode(ActivityInfo.self, from: json)

        XCTAssertEqual(activity.icon, "calendar")
        XCTAssertEqual(activity.title, "Booking Created")
        XCTAssertEqual(activity.subtitle, "Weekend cruise")
        XCTAssertEqual(activity.color, "blue")
        XCTAssertNotNil(activity.time)
    }

    func testActivityInfoColorValue() {
        let blueActivity = createActivity(color: "blue")
        XCTAssertEqual(blueActivity.colorValue, .blue)

        let greenActivity = createActivity(color: "green")
        XCTAssertEqual(greenActivity.colorValue, .green)

        let orangeActivity = createActivity(color: "orange")
        XCTAssertEqual(orangeActivity.colorValue, .orange)

        let grayActivity = createActivity(color: "gray")
        XCTAssertEqual(grayActivity.colorValue, .gray)

        let unknownActivity = createActivity(color: "unknown")
        XCTAssertEqual(unknownActivity.colorValue, .gray)
    }

    // MARK: - VesselInfo Tests

    func testVesselInfoDecoding() throws {
        let json = """
        {
            "id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
            "name": "Neptune's Pride",
            "manufacturer": "Riviera",
            "model": "Riviera 72 Sports Motor Yacht",
            "length": 72.0,
            "home_port": "Gold Coast Marina"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let vessel = try decoder.decode(VesselInfo.self, from: json)

        XCTAssertEqual(vessel.name, "Neptune's Pride")
        XCTAssertEqual(vessel.manufacturer, "Riviera")
        XCTAssertEqual(vessel.model, "Riviera 72 Sports Motor Yacht")
        XCTAssertEqual(vessel.length, 72.0)
        XCTAssertEqual(vessel.homePort, "Gold Coast Marina")
    }

    // MARK: - Edge Cases

    func testDashboardViewModelWithZeroEngineHours() throws {
        let json = """
        {
            "user_name": "New Owner",
            "vessel": {
                "id": "e98b59ac-bdac-4513-9ddd-f032d3aa39f7",
                "name": "Test Yacht",
                "manufacturer": "Test",
                "model": "Model",
                "length": 50.0,
                "home_port": "Test Port"
            },
            "port_engine_hours": 0.0,
            "starboard_engine_hours": 0.0,
            "fuel_liters": 0.0,
            "has_departure_log": false,
            "has_return_log": false,
            "upcoming_bookings": [],
            "recent_activities": []
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let dashboard = try decoder.decode(DashboardViewModel.self, from: json)

        XCTAssertEqual(dashboard.portEngineHours, 0.0)
        XCTAssertEqual(dashboard.starboardEngineHours, 0.0)
        XCTAssertEqual(dashboard.fuelLiters, 0.0)
    }

    // MARK: - Helper Methods

    private func createActivity(
        icon: String = "calendar",
        title: String = "Test",
        subtitle: String = "Test subtitle",
        time: Date = Date(),
        color: String
    ) -> ActivityInfo {
        return ActivityInfo(
            icon: icon,
            title: title,
            subtitle: subtitle,
            time: time,
            color: color
        )
    }
}
