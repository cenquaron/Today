import UIKit

extension ReminderListViewController {
    @objc func didChangeListStyle(_ segment: UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue: segment.selectedSegmentIndex) ?? .today
        tableView.reloadData()
        refreshBackground()
        updateProgressHeader()
    }
    
    @objc func eventStoreChanged(_ notification: NSNotification) {
        reminderStoreChanged()
        
    }
}
