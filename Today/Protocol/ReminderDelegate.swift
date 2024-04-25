//
protocol ReminderItemListCellDelegate: AnyObject {
    func didTapDoneButton(for reminder: Reminder)
}

protocol ReminderUpdateDelegate: AnyObject {
    func didUpdateReminder(_ reminder: Reminder)
}
