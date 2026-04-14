// BookingService.swift
// IOS_CW2_Supportives
// Full CoreData write-through persistence + conflict detection.

import Foundation
import CoreData
import Combine

final class BookingService: ObservableObject {
    @Published private(set) var bookings: [Booking] = []

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        loadFromCoreData()
        if bookings.isEmpty { seedDemoBookings() }
    }

    // MARK: - Query
    func bookings(for userId: UUID, asCustomer: Bool = true) -> [Booking] {
        bookings.filter { asCustomer ? $0.customerId == userId : $0.workerId == userId }
            .sorted { $0.scheduledDate > $1.scheduledDate }
    }

    // MARK: - Conflict check
    /// Returns true if the worker already has a booking that overlaps the requested window.
    func hasConflict(workerId: UUID, date: Date, durationHours: Int) -> Bool {
        let newStart = date
        let newEnd   = date.addingTimeInterval(Double(durationHours) * 3600)

        return bookings.contains { b in
            guard b.workerId == workerId,
                  b.status == .confirmed || b.status == .pending else { return false }
            let existStart = b.scheduledDate
            let existEnd   = b.scheduledDate.addingTimeInterval(Double(b.durationHours) * 3600)
            return newStart < existEnd && newEnd > existStart   // overlap check
        }
    }

    // MARK: - Create
    @discardableResult
    func createBooking(customerId: UUID, worker: Worker, category: ServiceCategory,
                       date: Date, durationHours: Int, address: String,
                       notes: String) throws -> Booking {

        // Conflict guard
        if hasConflict(workerId: worker.id, date: date, durationHours: durationHours) {
            throw BookingError.workerUnavailable(
                "\(worker.name) already has a booking at this time. Please choose a different slot."
            )
        }

        let base    = worker.hourlyRate * Double(durationHours)
        let fee     = base * AppConstants.platformFeePercent
        let booking = Booking(
            id: UUID(),
            customerId: customerId,
            workerId: worker.id,
            categoryId: category.id,
            workerName: worker.name,
            categoryName: category.name,
            scheduledDate: date,
            durationHours: durationHours,
            status: .pending,
            baseAmount: base,
            platformFee: fee,
            totalAmount: base + fee,
            notes: notes,
            address: address,
            createdAt: Date(),
            calendarEventId: nil
        )
        saveBooking(booking)
        return booking
    }

    // MARK: - Update status
    func updateStatus(_ bookingId: UUID, status: BookingStatus) {
        guard let idx = bookings.firstIndex(where: { $0.id == bookingId }) else { return }
        bookings[idx].status = status
        saveToCoreData()
    }

    func cancel(_ bookingId: UUID) { updateStatus(bookingId, status: .cancelled) }

    func setCalendarEventId(_ eventId: String, for bookingId: UUID) {
        guard let idx = bookings.firstIndex(where: { $0.id == bookingId }) else { return }
        bookings[idx].calendarEventId = eventId
        saveToCoreData()
    }

    // MARK: - CoreData persistence
    private func saveBooking(_ booking: Booking) {
        bookings.append(booking)
        writeToCoreData(booking)
    }

    /// Write all bookings to CoreData (upsert by id).
    private func saveToCoreData() {
        // Delete all, then re-insert (simple approach for coursework)
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BookingEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? viewContext.execute(deleteRequest)

        for booking in bookings {
            writeToCoreData(booking)
        }
        try? viewContext.save()
        objectWillChange.send()
    }

    private func writeToCoreData(_ booking: Booking) {
        guard let entity = NSEntityDescription.entity(forEntityName: "BookingEntity", in: viewContext) else { return }
        let obj = NSManagedObject(entity: entity, insertInto: viewContext)
        obj.setValue(booking.id,            forKey: "id")
        obj.setValue(booking.customerId,    forKey: "customerId")
        obj.setValue(booking.workerId,      forKey: "workerId")
        obj.setValue(booking.categoryId,    forKey: "categoryId")
        obj.setValue(booking.workerName,    forKey: "workerName")
        obj.setValue(booking.categoryName,  forKey: "categoryName")
        obj.setValue(booking.scheduledDate, forKey: "scheduledDate")
        obj.setValue(booking.durationHours, forKey: "durationHours")
        obj.setValue(booking.status.rawValue, forKey: "status")
        obj.setValue(booking.baseAmount,    forKey: "baseAmount")
        obj.setValue(booking.platformFee,   forKey: "platformFee")
        obj.setValue(booking.totalAmount,   forKey: "totalAmount")
        obj.setValue(booking.notes,         forKey: "notes")
        obj.setValue(booking.address,       forKey: "address")
        obj.setValue(booking.createdAt,     forKey: "createdAt")
        obj.setValue(booking.calendarEventId, forKey: "calendarEventId")
        try? viewContext.save()
    }

    private func loadFromCoreData() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "BookingEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "scheduledDate", ascending: false)]

        guard let objects = try? viewContext.fetch(request) else { return }
        bookings = objects.compactMap { obj -> Booking? in
            guard
                let id           = obj.value(forKey: "id")           as? UUID,
                let customerId   = obj.value(forKey: "customerId")   as? UUID,
                let workerId     = obj.value(forKey: "workerId")     as? UUID,
                let categoryId   = obj.value(forKey: "categoryId")   as? UUID,
                let workerName   = obj.value(forKey: "workerName")   as? String,
                let categoryName = obj.value(forKey: "categoryName") as? String,
                let scheduled    = obj.value(forKey: "scheduledDate") as? Date,
                let dur          = obj.value(forKey: "durationHours") as? Int32,
                let statusStr    = obj.value(forKey: "status")       as? String,
                let status       = BookingStatus(rawValue: statusStr),
                let base         = obj.value(forKey: "baseAmount")   as? Double,
                let fee          = obj.value(forKey: "platformFee")  as? Double,
                let total        = obj.value(forKey: "totalAmount")  as? Double,
                let notes        = obj.value(forKey: "notes")        as? String,
                let address      = obj.value(forKey: "address")      as? String,
                let created      = obj.value(forKey: "createdAt")    as? Date
            else { return nil }

            return Booking(
                id: id,
                customerId: customerId,
                workerId: workerId,
                categoryId: categoryId,
                workerName: workerName,
                categoryName: categoryName,
                scheduledDate: scheduled,
                durationHours: Int(dur),
                status: status,
                baseAmount: base,
                platformFee: fee,
                totalAmount: total,
                notes: notes,
                address: address,
                createdAt: created,
                calendarEventId: obj.value(forKey: "calendarEventId") as? String
            )
        }
    }

    // MARK: - Demo seed
    private func seedDemoBookings() {
        let userId     = User.placeholder.id
        let worker     = Worker.placeholder
        let cat        = ServiceCategory.all.first!
        let pastDate   = Calendar.current.date(byAdding: .day, value: -7,  to: Date()) ?? Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 3,   to: Date()) ?? Date()

        try? createBooking(customerId: userId, worker: worker, category: cat,
                           date: pastDate, durationHours: 2,
                           address: "12 Galle Rd, Colombo 03",
                           notes: "Please bring cleaning supplies.")
        if let b = bookings.first { updateStatus(b.id, status: .completed) }

        try? createBooking(customerId: userId, worker: worker, category: cat,
                           date: futureDate, durationHours: 3,
                           address: "45 Union Pl, Colombo 02",
                           notes: "Focus on kitchen and bathrooms.")
    }
}

// MARK: - Booking Error
enum BookingError: LocalizedError {
    case workerUnavailable(String)
    var errorDescription: String? {
        switch self { case .workerUnavailable(let m): return m }
    }
}
