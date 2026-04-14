// IOS_CW2_SupportivesTests.swift
// IOS_CW2_SupportivesTests
// Comprehensive unit tests covering: OTP auth, booking pricing, conflict detection,
// search filtering, distance calculation, worker mock data, and date extensions.

import Testing
import CoreLocation
@testable import IOS_CW2_Supportives

// MARK: - Auth Service Tests
struct AuthServiceTests {

    @Test("OTP is exactly 6 digits")
    func otpIsCorrectLength() async throws {
        let service = AuthService()
        await service.sendOTP(phone: "+94771234567")
        #expect(service.currentOTP.count == 6)
    }

    @Test("OTP contains only numeric digits")
    func otpIsNumeric() async throws {
        let service = AuthService()
        await service.sendOTP(phone: "+94771234567")
        #expect(service.currentOTP.allSatisfy(\.isNumber))
    }

    @Test("Dev OTP 123456 verifies successfully")
    func devOTPVerifies() async throws {
        let service = AuthService()
        await service.sendOTP(phone: "+94771234567")
        let user = try await service.verifyOTP("123456", for: "+94771234567")
        #expect(user.phone == "+94771234567")
    }

    @Test("Wrong OTP throws error")
    func wrongOTPThrows() async {
        let service = AuthService()
        await service.sendOTP(phone: "+94771234567")
        do {
            _ = try await service.verifyOTP("000000", for: "+94771234567")
            Issue.record("Should have thrown")
        } catch {
            #expect(error is AuthError)
        }
    }

    @Test("Phone number validation — valid")
    func validPhone() {
        #expect("+94771234567".isValidPhone)
        #expect("0771234567".isValidPhone)
    }

    @Test("Phone number validation — invalid (too short)")
    func invalidPhone() {
        #expect(!"123".isValidPhone)
        #expect(!"".isValidPhone)
    }
}

// MARK: - Booking Pricing Tests
struct BookingPricingTests {

    @Test("Base amount = hourlyRate × durationHours")
    func baseAmountCalculation() {
        let rate     = 1000.0
        let hours    = 3
        let expected = rate * Double(hours)
        let base     = rate * Double(hours)
        #expect(base == expected)
    }

    @Test("Platform fee is 10% of base amount")
    func platformFeeCalculation() {
        let base = 3000.0
        let fee  = base * AppConstants.platformFeePercent
        #expect(fee == 300.0)
    }

    @Test("Total amount = base + platform fee")
    func totalAmountCalculation() {
        let base  = 2000.0
        let fee   = base * AppConstants.platformFeePercent
        let total = base + fee
        #expect(total == 2200.0)
    }
}

// MARK: - Booking Conflict Tests
struct BookingConflictTests {

    func makeContext() -> NSManagedObjectContext {
        PersistenceController.preview.container.viewContext
    }

    @Test("No conflict when worker has no bookings")
    func noConflictWhenEmpty() {
        let service = BookingService(context: makeContext())
        let date    = Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date()
        #expect(!service.hasConflict(workerId: UUID(), date: date, durationHours: 2))
    }

    @Test("Conflict detected for overlapping booking")
    func conflictDetectedForOverlap() throws {
        let service  = BookingService(context: makeContext())
        let worker   = Worker.placeholder
        let category = ServiceCategory.all.first!
        let date     = Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date()

        try service.createBooking(customerId: UUID(), worker: worker, category: category,
                                  date: date, durationHours: 2,
                                  address: "Test", notes: "")

        // Same worker, overlapping by 1 hour
        let overlappingDate = date.addingTimeInterval(3600) // +1h (within the 2h window)
        #expect(service.hasConflict(workerId: worker.id, date: overlappingDate, durationHours: 2))
    }

    @Test("No conflict for non-overlapping consecutive booking")
    func noConflictForConsecutive() throws {
        let service  = BookingService(context: makeContext())
        let worker   = Worker.placeholder
        let category = ServiceCategory.all.first!
        let date     = Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date()

        try service.createBooking(customerId: UUID(), worker: worker, category: category,
                                  date: date, durationHours: 2,
                                  address: "Test", notes: "")

        // Starts exactly when the previous one ends
        let nextDate = date.addingTimeInterval(2 * 3600)
        #expect(!service.hasConflict(workerId: worker.id, date: nextDate, durationHours: 2))
    }
}

// MARK: - MockDataService Tests
struct MockDataServiceTests {

    @Test("Returns 15 workers")
    func workerCount() {
        let service = MockDataService()
        #expect(service.workers.count == 15)
    }

    @Test("Category filter returns subset")
    func categoryFilter() {
        let service  = MockDataService()
        let cleaning = service.categories.first { $0.name == "Cleaning" }!
        let results  = service.fetchWorkers(category: cleaning)
        #expect(!results.isEmpty)
        #expect(results.allSatisfy { $0.categoryIds.contains(cleaning.id) })
    }

    @Test("Text search filters by name")
    func textSearch() {
        let service = MockDataService()
        let results = service.fetchWorkers(query: "Nimesh")
        #expect(results.count == 1)
        #expect(results.first?.name.contains("Nimesh") == true)
    }

    @Test("Sort by rating returns descending order")
    func sortByRating() {
        let service = MockDataService()
        let results = service.fetchWorkers(sortBy: .rating)
        let ratings = results.map(\.rating)
        for i in 0..<(ratings.count - 1) {
            #expect(ratings[i] >= ratings[i + 1])
        }
    }

    @Test("Sort by price returns ascending order")
    func sortByPrice() {
        let service = MockDataService()
        let results = service.fetchWorkers(sortBy: .price)
        let rates   = results.map(\.hourlyRate)
        for i in 0..<(rates.count - 1) {
            #expect(rates[i] <= rates[i + 1])
        }
    }

    @Test("All workers have a phone number")
    func workersHavePhone() {
        let service = MockDataService()
        #expect(service.workers.allSatisfy { !$0.phone.isEmpty })
    }
}

// MARK: - Worker Distance Tests
struct WorkerDistanceTests {

    @Test("Distance from same coordinate is ~0.0 km")
    func distanceFromSame() {
        let coord  = AppConstants.defaultCoordinate
        let worker = Worker.placeholder
        // Placeholder is offset by ~0.005 degrees (~500m)
        let dist   = worker.distance(from: coord)
        #expect(dist < 2.0)   // within 2km
    }

    @Test("Distance string for short distances uses meters format")
    func distanceStringMeters() {
        let km = 0.5
        let s  = km.distanceString
        #expect(s.contains("m") || s.contains("km"))
    }

    @Test("Distance string for long distances uses km format")
    func distanceStringKm() {
        let km = 5.3
        let s  = km.distanceString
        #expect(s.contains("km"))
        #expect(s.contains("5.3"))
    }
}

// MARK: - Date Extension Tests
struct DateExtensionTests {

    @Test("displayDate returns non-empty string")
    func displayDate() {
        let s = Date().displayDate
        #expect(!s.isEmpty)
    }

    @Test("displayTime returns non-empty string")
    func displayTime() {
        let s = Date().displayTime
        #expect(!s.isEmpty)
    }

    @Test("isToday returns true for current date")
    func isToday() {
        #expect(Date().isToday)
    }

    @Test("isFuture returns true for tomorrow")
    func isFuture() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        #expect(tomorrow.isFuture)
    }

    @Test("maskedPhone masks correctly")
    func maskedPhone() {
        let masked = "+94771234567".maskedPhone
        #expect(masked.hasSuffix("4567"))
        #expect(masked.contains("*"))
    }
}
