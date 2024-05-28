import XCTest
@testable import Today

final class StatisticsViewControllerTest: XCTestCase {
    
    var viewController: StatisticsViewController!
    var reminders: [Reminder]!

    override func setUpWithError() throws {
        reminders = [Reminder(title: "Test Reminder", dueDate: Date(), notes: "Test notes")]
        viewController = StatisticsViewController(reminders: reminders)
        viewController.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        viewController = nil
        reminders = nil
    }

    func testDailyProgressView() throws {
        XCTAssertEqual(viewController.dailyProgressView.reminders.count, reminders.count)
    }
    
    func testMonthProgressView() throws {
        XCTAssertEqual(viewController.monthProgressView.reminders.count, reminders.count)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
