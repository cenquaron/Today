import EventKit
import Foundation

final class ReminderStore {
    static let shared = ReminderStore()
    private let ekStore = EKEventStore()

    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    func requestAccess() async throws {
         let status = EKEventStore.authorizationStatus(for: .reminder)
         switch status {
         case .authorized:
             return
         case .restricted:
             throw TodayError.accessRestricted
         case .notDetermined:
             let accessGranted = try await ekStore.requestAccess(to: .reminder)
             guard accessGranted else {
                 throw TodayError.accessDenied
             }
         case .denied:
             throw TodayError.accessDenied
         @unknown default:
             throw TodayError.unknown
         }
     }
    
    func save(_ reminder: Reminder) throws {
        guard isAvailable else {
            throw TodayError.accessDenied
        }

        let newReminder = EKReminder(eventStore: ekStore)
        newReminder.title = reminder.title
        newReminder.notes = reminder.notes
        newReminder.calendar = ekStore.defaultCalendarForNewReminders()

        // Set due date
        newReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.dueDate)

        // Save the reminder
        do {
            try ekStore.save(newReminder, commit: true)
        } catch {
            throw error
        }
    }

    func removeFromRemindersApp(_ reminder: Reminder) {

        let predicate = ekStore.predicateForReminders(in: nil)
        ekStore.fetchReminders(matching: predicate) { [weak self] (reminders) in
            guard let self = self else { return }

            for ekReminder in reminders ?? [] {
                if ekReminder.calendarItemIdentifier == reminder.id {
                    do {
                        try self.ekStore.remove(ekReminder, commit: true)
                    } catch {
                        // Handle error
                        print("Error removing reminder from Reminders app: \(error)")
                    }
                    break
                }
            }
        }
    }



    func readAll() async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }

        let predicate = ekStore.predicateForReminders(in: nil)
        let ekReminders = try await ekStore.reminders(matching: predicate)
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch TodayError.reminderHasNoDueDate {
                return nil
            }
        }
        return reminders
    }
}
