import XCTest
@testable import Today

final class DailyStatisticsViewControllerTest: XCTestCase {
    
    var dailyView: DailyStatisticsView!
    var reminders: [Reminder]!
    
    override func setUpWithError() throws {
        reminders = [
            Reminder(title: "Test Reminder 1", dueDate: Date(), notes: "Test notes 1"),
            Reminder(title: "Test Reminder 2", dueDate: Date(), notes: "Test notes 2")
        ]
        dailyView = DailyStatisticsView(reminders: reminders)
    }
    
    override func tearDownWithError() throws {
        dailyView = nil
        reminders = nil
    }
    
    func testUpdateNoTastOnLastWeek() throws {
        dailyView.updateUI()
        
        XCTAssertTrue(dailyView.noTaskMessage.isDescendant(of: dailyView.dailyTaskContentView))
        
        XCTAssertFalse(dailyView.noTaskMessage.isDescendant(of: dailyView.dailyTaskContentView))
    }
    
    func testUpdateWithTask() {
        let dueDate = Date()
        let completedReminder = Reminder(title: "Completed Reminder", dueDate: dueDate, notes: "Note 1", isComplete: true)
        let incompleteReminder = Reminder(title: "Incomplete Reminder", dueDate: dueDate, notes: "Note 2", isComplete: false)
        
        reminders = [completedReminder, incompleteReminder]
        
        dailyView.reminders = reminders
        dailyView.updateUI()
        
        XCTAssertTrue(dailyView.dailyView.isDescendant(of: dailyView.dailyTaskContentView))
        
        XCTAssertFalse(dailyView.noTaskMessage.isDescendant(of: dailyView.dailyTaskContentView))
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
