import XCTest
@testable import Today

final class EditorViewControllerTest: XCTestCase {
    
    var viewController: EditorViewController!
    var reminders: Reminder!
    
    override func setUpWithError() throws {
        reminders = Reminder(title: "Test Reminder", dueDate: Date(), notes: "Test notes")
        viewController = EditorViewController(reminder: reminders)
        viewController.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        viewController = nil
        reminders = nil
    }
    
    func testSaveButtonAction() {
        let initialReminder = viewController.reminder
        viewController.titleField.text = "New Title"
        viewController.notesField.text = "New notes"
        let newDate = Date().addingTimeInterval(3600)
        viewController.datePicker.date = newDate
        viewController.timerPicker.date = newDate
        viewController.saveButtonTap(UIBarButtonItem())
        
        XCTAssertEqual(viewController.reminder.title, "New Title", "Title should be updated after saving")
        XCTAssertEqual(viewController.reminder.notes, "New notes", "Notes should be updated after saving")
        XCTAssertEqual(viewController.reminder.dueDate, newDate, "Due date should be updated after saving")
        XCTAssertNotEqual(viewController.reminder, initialReminder, "Reminder object should be updated after saving")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
