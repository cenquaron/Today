import UIKit

class StatisticsViewController: UIViewController {
    
    // MARK: - Variables
    private var reminders: [Reminder] = []
    private var currentRegion: Locale
    
    // MARK: - UI Components
    private let scrollView = scrollView()
    private let contentScrollView = contentView()
    private let titleDailyLabel = titleLabel()
    private let dailyTaskContentView = contentView()
    private let graphView = DailyProgressBarGraphView()
    private let noTaskMessage = noTasksLabel()
    private lazy var changeDailyGraph = optionButton()
    
    // MARK: - LifeCycle
    init(reminders: [Reminder], region: Locale = Locale.current) {
        self.reminders = reminders
        self.currentRegion = region
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Progress View"
        view.backgroundColor = .backPrimary
        setupUI()
        updateUI()
    }
    
    // MARK: - Selectors
    private func updateUI() {
        graphView.backgroundColor = .todayListCellBackground
        let dailyActivities = calculateDailyActivities(from: reminders)
        
        if dailyActivities.isEmpty || dailyActivities.allSatisfy({ $0 == 0 }) {
            setupNoTaskMessage()
        } else {
            graphView.progress = dailyActivities
        }
    }
    
    private func calculateDailyActivities(from reminders: [Reminder]) -> [CGFloat] {
        let (startOfWeek, endOfWeekPlus3) = getWeekRange(for: currentRegion)
        let filteredReminders = reminders.filter { $0.dueDate >= startOfWeek && $0.dueDate <= endOfWeekPlus3 }
        
        var dailyActivities: [CGFloat] = Array(repeating: 0, count: 7)
        var dailyCompletedTasks: [CGFloat] = Array(repeating: 0, count: 7)
        
        for reminder in filteredReminders {
            let dayOfWeek = getDayOfWeek(for: reminder.dueDate)
            dailyActivities[dayOfWeek] += 1
            if reminder.isComplete {
                dailyCompletedTasks[dayOfWeek] += 1
            }
        }
        
        for i in 0..<7 {
            if dailyActivities[i] != 0 {
                dailyActivities[i] = dailyCompletedTasks[i] / dailyActivities[i]
            }
        }
        
        return dailyActivities
    }
    
    private func getDayOfWeek(for date: Date) -> Int {
        var calendar = Calendar.current
        calendar.locale = currentRegion
        let dayOfWeek = calendar.component(.weekday, from: date) - 1
        return dayOfWeek
    }
    
    private func getWeekRange(for locale: Locale) -> (Date, Date) {
        var calendar = Calendar.current
        calendar.locale = locale
        let today = Date()
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let endOfWeekPlus3 = calendar.date(byAdding: .day, value: 10, to: startOfWeek) ?? today
        
        return (startOfWeek, endOfWeekPlus3)
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


// MARK: Setup Constrain
extension StatisticsViewController {
    private func setupUI() {
        setupScrollView()
        setupTitleDailyView()
        setupDailyTaskContentView()
        setupBarGraphView()
        setupChangeDailyGraph()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentScrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentScrollView.heightAnchor.constraint(equalToConstant: 600),
            contentScrollView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupTitleDailyView() {
        contentScrollView.addSubview(titleDailyLabel)
        
        NSLayoutConstraint.activate([
            titleDailyLabel.topAnchor.constraint(equalTo: contentScrollView.topAnchor, constant: 10),
            titleDailyLabel.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 30)
        ])
    }
    
    private func setupDailyTaskContentView() {
        contentScrollView.addSubview(dailyTaskContentView)
        
        NSLayoutConstraint.activate([
            dailyTaskContentView.topAnchor.constraint(equalTo: titleDailyLabel.bottomAnchor, constant: 10),
            dailyTaskContentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 20),
            dailyTaskContentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -20),
            dailyTaskContentView.heightAnchor.constraint(equalToConstant: 330)
        ])
    }
    
    private func setupBarGraphView() {
        dailyTaskContentView.addSubview(graphView)
        graphView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: dailyTaskContentView.topAnchor),
            graphView.leadingAnchor.constraint(equalTo: dailyTaskContentView.leadingAnchor),
            graphView.trailingAnchor.constraint(equalTo: dailyTaskContentView.trailingAnchor),
            graphView.bottomAnchor.constraint(equalTo: dailyTaskContentView.bottomAnchor)
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
        contentScrollView.addSubview(changeDailyGraph)
        
        NSLayoutConstraint.activate([
            changeDailyGraph.topAnchor.constraint(equalTo: titleDailyLabel.topAnchor, constant: -6.5),
            changeDailyGraph.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -30)
        ])
    }
}


// MARK: - Make UI
extension StatisticsViewController {
    private static func scrollView() -> UIScrollView {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = true
        view.alwaysBounceVertical = true
        view.backgroundColor = .backPrimary
        return view
    }
    
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
        label.text = "daily perfomatse".uppercased()
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
