import XCTest
@testable import Today

final class ReminderListViewControllerTests: XCTestCase {

    var viewController: ReminderListViewController!
    var reminders: [Reminder]!

    override func setUpWithError() throws {
        reminders = [
            Reminder(title: "Test 1", dueDate: Date().addingTimeInterval(-1000), isComplete: false),
            Reminder(title: "Test 2", dueDate: Date().addingTimeInterval(1000), isComplete: false),
            Reminder(title: "Test 3", dueDate: Date().addingTimeInterval(2000), isComplete: true)
        ]
        viewController = ReminderListViewController(reminderItem: reminders)
        viewController.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        viewController = nil
        reminders = nil
    }

    func testFilterReminder() {
        viewController.listStyle = .today
        let filteredRemindersToday = viewController.filterReminder
        XCTAssertEqual(filteredRemindersToday.count, 1, "Filtered reminders for today should be 1")

        viewController.listStyle = .future
        let filteredRemindersFuture = viewController.filterReminder
        XCTAssertEqual(filteredRemindersFuture.count, 1, "Filtered reminders for future should be 1")

        viewController.listStyle = .all
        let filteredRemindersAll = viewController.filterReminder
        XCTAssertEqual(filteredRemindersAll.count, 3, "Filtered reminders for all should be 3")
    }

    func testProgressCalculation() {
        let progress = viewController.progress
        XCTAssertEqual(progress, 1.0 / 3.0, "Progress should be 1/3 as one out of three reminders is complete")
    }

    func testAddReminder() {
        let initialCount = viewController.reminderItem.count
        viewController.addReminder()
        let newCount = viewController.reminderItem.count
        XCTAssertEqual(newCount, initialCount + 1, "Reminder count should increase by 1 after adding a new reminder")
    }

    func testCompleteReminder() {
        let incompleteReminder = reminders[0]
        XCTAssertFalse(incompleteReminder.isComplete, "Reminder should initially be incomplete")

        viewController.completeReminder(withId: incompleteReminder.id)

        let updatedReminder = viewController.reminder(withId: incompleteReminder.id)
        XCTAssertTrue(updatedReminder.isComplete, "Reminder should be marked as complete")
    }

    func testDeleteReminder() {
        let initialCount = viewController.reminderItem.count
        let reminderToDelete = reminders[0]

        viewController.tableView(viewController.tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))

        let newCount = viewController.reminderItem.count
        XCTAssertEqual(newCount, initialCount - 1, "Reminder count should decrease by 1 after deletion")
        XCTAssertFalse(viewController.reminderItem.contains(reminderToDelete), "Deleted reminder should no longer be in the list")
    }
}
