import XCTest
@testable import Today

final class MonthStatisticsViewControllerTest: XCTestCase {
    
    var monthView: MonthStatisticsView!
    var reminders: [Reminder]!
    
    override func setUpWithError() throws {
        reminders = [
            Reminder(title: "Test Reminder 1", dueDate: Date(), notes: "Test notes 1"),
            Reminder(title: "Test Reminder 2", dueDate: Date(), notes: "Test notes 2")
        ]
        monthView = MonthStatisticsView(reminders: reminders)
    }
    
    override func tearDownWithError() throws {
        monthView = nil
        reminders = nil
    }
    
    func testUpdateNoTastOnLastWeek() throws {
        monthView.updateUI()
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
