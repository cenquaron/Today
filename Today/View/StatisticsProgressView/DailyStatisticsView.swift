import UIKit

class DailyStatisticsView: UIView {
    
    // MARK: - Variables
    private var currentRegion: Locale
    var reminders: [Reminder] = []

    
    // MARK: - UI Components
    private lazy var changeDailyGraph = optionButton()
    private let contentView = contentView()
    private let titleDailyLabel = titleLabel()
    let dailyView = DailyProgressView()
    let noTaskMessage = noTasksLabel()
    let dailyTaskContentView = contentView()

    
    // MARK: - LifeCycle
    init(reminders: [Reminder], region: Locale = Locale.current) {
        self.reminders = reminders
        self.currentRegion = region
        super.init(frame: .zero)
        setupUI()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    func updateUI() {
        dailyView.backgroundColor = .todayListCellBackground
        let last10Days = changeDailyGraph.currentTitle == "option10DailyButton".localizable.uppercased()
        dailyView.displayLast10Days = last10Days
        let dailyActivities = calculateDailyActivities(from: reminders, last10Days: last10Days)
        
        if dailyActivities.isEmpty || dailyActivities.allSatisfy({ $0 == 0 }) {
            dailyView.progress = []
            setupNoTaskMessage()
        } else {
            noTaskMessage.removeFromSuperview()
            dailyView.progress = dailyActivities
        }
    }

    private func calculateDailyActivities(from reminders: [Reminder], last10Days: Bool) -> [CGFloat] {
        let (startOfRange, endOfRange) = getDateRange(last10Days: last10Days)
        let filteredReminders = reminders.filter {
            let reminderDate = Calendar.current.startOfDay(for: $0.dueDate)
            return reminderDate >= startOfRange && reminderDate <= endOfRange
        }
        
        let numberOfDays = last10Days ? 10 : 7
        var dailyActivities: [CGFloat] = Array(repeating: 0, count: numberOfDays)
        var dailyCompletedTasks: [CGFloat] = Array(repeating: 0, count: numberOfDays)
        
        for reminder in filteredReminders {
            let dayIndex = getDayIndex(for: reminder.dueDate, startOfRange: startOfRange)
            if dayIndex != -1 {
                dailyActivities[dayIndex] += 1
                if reminder.isComplete {
                    dailyCompletedTasks[dayIndex] += 1
                }
            }
        }
        
        for i in 0..<numberOfDays {
            if dailyActivities[i] != 0 {
                dailyActivities[i] = dailyCompletedTasks[i] / dailyActivities[i]
            }
        }
        
        return dailyActivities
    }

    private func getDateRange(last10Days: Bool) -> (Date, Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var startOfRange = today
        
        if last10Days {
            startOfRange = calendar.date(byAdding: .day, value: -9, to: startOfRange)!
        } else {
            startOfRange = calendar.date(byAdding: .day, value: -6, to: startOfRange)!
        }
        
        let endOfRange = today
        
        return (startOfRange, endOfRange)
    }

    private func getDayIndex(for date: Date, startOfRange: Date) -> Int {
        let calendar = Calendar.current
        let startOfDayDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfRange, to: startOfDayDate)
        
        if let dayIndex = components.day, dayIndex >= 0 {
            return dayIndex
        }
        
        return -1
    }
    
    @objc func didTapChangeGraphView(_ sender: UIButton) {
        if sender.currentTitle == "option7DailyButton".localizable.uppercased() {
            sender.setTitle("option10DailyButton".localizable.uppercased(), for: .normal)
        } else {
            sender.setTitle("option7DailyButton".localizable.uppercased(), for: .normal)
        }
        updateUI()
    }
}


// MARK: - Setup Constraints
extension DailyStatisticsView {
    private func setupUI() {
        setupContentView()
        setupTitleDailyView()
        setupDailyTaskContentView()
        setupBarGraphView()
        setupChangeDailyGraph()
    }
    
    private func setupContentView() {
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
    
    private func setupTitleDailyView() {
        contentView.addSubview(titleDailyLabel)
        
        NSLayoutConstraint.activate([
            titleDailyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleDailyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
        ])
    }
    
    private func setupDailyTaskContentView() {
        contentView.addSubview(dailyTaskContentView)
        
        NSLayoutConstraint.activate([
            dailyTaskContentView.topAnchor.constraint(equalTo: titleDailyLabel.bottomAnchor, constant: 10),
            dailyTaskContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dailyTaskContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dailyTaskContentView.heightAnchor.constraint(equalToConstant: 330)
        ])
    }
    
    private func setupBarGraphView() {
        dailyTaskContentView.addSubview(dailyView)
        dailyView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dailyView.topAnchor.constraint(equalTo: dailyTaskContentView.topAnchor),
            dailyView.leadingAnchor.constraint(equalTo: dailyTaskContentView.leadingAnchor),
            dailyView.trailingAnchor.constraint(equalTo: dailyTaskContentView.trailingAnchor),
            dailyView.bottomAnchor.constraint(equalTo: dailyTaskContentView.bottomAnchor)
        ])
    }
    
    private func setupNoTaskMessage() {
        dailyTaskContentView.addSubview(noTaskMessage)
        
        NSLayoutConstraint.activate([
            noTaskMessage.centerXAnchor.constraint(equalTo: dailyTaskContentView.centerXAnchor),
            noTaskMessage.centerYAnchor.constraint(equalTo: dailyTaskContentView.centerYAnchor),
            noTaskMessage.leadingAnchor.constraint(greaterThanOrEqualTo: dailyTaskContentView.leadingAnchor, constant: 20),
            noTaskMessage.trailingAnchor.constraint(lessThanOrEqualTo: dailyTaskContentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupChangeDailyGraph() {
        contentView.addSubview(changeDailyGraph)
        
        NSLayoutConstraint.activate([
            changeDailyGraph.topAnchor.constraint(equalTo: titleDailyLabel.topAnchor, constant: -6.5),
            changeDailyGraph.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30)
        ])
    }
}


// MARK: - Make UI
extension DailyStatisticsView {
    private static func contentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backPrimary
        return view
    }
    
    private static func titleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .labelPrimary
        label.text = "dailyPerformance".localizable.uppercased()
        return label
    }
    
    private static func noTasksLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "noTasksLabel".localizable
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .labelTertiary
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        return label
    }

    private func optionButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("option7DailyButton".localizable.uppercased(), for: .normal)
        btn.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        btn.adjustsImageSizeForAccessibilityContentSizeCategory = true
        btn.setTitleColor(.labelPrimary, for: .normal)
        btn.addTarget(self, action: #selector(didTapChangeGraphView(_:)), for: .touchUpInside)
        return btn
    }
}
