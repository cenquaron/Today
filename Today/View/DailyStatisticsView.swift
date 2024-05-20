import UIKit

class DailyStatisticsView: UIView {
    
    // MARK: - Variables
    private var reminders: [Reminder] = []
    private var currentRegion: Locale
    
    // MARK: - UI Components
    private let contentView = DailyStatisticsView.contentView()
    private let titleDailyLabel = DailyStatisticsView.titleLabel()
    private let dailyTaskContentView = DailyStatisticsView.contentView()
    private let dailyView = DailyProgressView()
    private let noTaskMessage = DailyStatisticsView.noTasksLabel()
    private lazy var changeDailyGraph = optionButton()
    
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
    private func updateUI() {
        dailyView.backgroundColor = .todayListCellBackground
        let last10Days = changeDailyGraph.currentTitle == "last 10 day >".uppercased()
        dailyView.displayLast10Days = last10Days
        let dailyActivities = calculateDailyActivities(from: reminders, last10Days: last10Days)
        
        if dailyActivities.isEmpty || dailyActivities.allSatisfy({ $0 == 0 }) {
            setupNoTaskMessage()
        } else {
            dailyView.progress = dailyActivities
        }
    }

    private func calculateDailyActivities(from reminders: [Reminder], last10Days: Bool) -> [CGFloat] {
        let (startOfRange, endOfRange) = getDateRange(last10Days: last10Days)
        let filteredReminders = reminders.filter { $0.dueDate >= startOfRange && $0.dueDate <= endOfRange }
        
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
        let today = Date()
        var startOfRange = calendar.startOfDay(for: today)
        
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
        let components = calendar.dateComponents([.day], from: startOfRange, to: date)
        
        if let dayIndex = components.day, dayIndex >= 0 {
            return dayIndex
        }
        
        return -1
    }
    
    @objc func didTapChangeGraphView(_ sender: UIButton) {
        if sender.currentTitle == "last 7 day >".uppercased() {
            sender.setTitle("last 10 day >".uppercased(), for: .normal)
        } else {
            sender.setTitle("last 7 day >".uppercased(), for: .normal)
        }
        
        updateUI()
    }
}


// MARK: - Setup Constrain
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
        label.font = .body
        label.textColor = .labelPrimary
        label.text = "daily performance".uppercased()
        return label
    }
    
    private static func noTasksLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "На этой неделе вы не выполнили ни одной задачи"
        label.textAlignment = .center
        label.font = .title
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
        btn.setTitle("last 7 day >".uppercased(), for: .normal)
        btn.titleLabel?.font = .body
        btn.setTitleColor(.labelPrimary, for: .normal)
        btn.addTarget(self, action: #selector(didTapChangeGraphView(_:)), for: .touchUpInside)
        return btn
    }
}
