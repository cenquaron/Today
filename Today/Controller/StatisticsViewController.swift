import UIKit

class StatisticsViewController: UIViewController {
    
    //MARK: - Variables
    private var reminders: [Reminder] = []
    private let dropDownOptions = ["Option 1", "Option 2"]
    private var selectedOptionIndex: Int = 0 {
        didSet {
            updateChartData()
        }
    }
    
    
    //MARK: - UI Components
    private let scrollView = scrollView()
    private let contentView = contentView()
    private let dailyPerfContentView = contentView()
    private let titleLabel = labelText()
    private lazy var dropDownBtn = dropDownButton()
    var dropDownStackView: UIStackView?
    private let barChartView = DailyStatisticsView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width - 40, height: 280))
    
    
    //MARK: - LifeCycle
    init(reminders: [Reminder]) {
        self.reminders = reminders
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backPrimary
        updateUI()
        setupUI()
    }
    
    
    //MARK: - Selectors
    private func updateUI() {
        titleLabel.text = "daily perfomance".uppercased()
        dropDownBtn.addTarget(self, action: #selector(didTapDropDownButton), for: .touchUpInside)
        
        dailyPerfContentView.backgroundColor = .backPrimary
        dailyPerfContentView.layer.cornerRadius = 10
        dailyPerfContentView.backgroundColor = .todayListCellBackground
        
        barChartView.backgroundColor = .clear
        barChartView.layer.cornerRadius = 10
    }
    
    func createDropDownMenu() {
        dropDownStackView = UIStackView()
        dropDownStackView?.axis = .vertical
        dropDownStackView?.alignment = .fill
        dropDownStackView?.distribution = .fillEqually
        dropDownStackView?.spacing = 5
        dropDownStackView?.translatesAutoresizingMaskIntoConstraints = false
        dropDownStackView?.backgroundColor = .backTh
        
        for option in dropDownOptions {
            let optionButton = UIButton()
            optionButton.setTitle(option, for: .normal)
            optionButton.setTitleColor(.black, for: .normal)
            optionButton.addTarget(self, action: #selector(didSelectOption(_:)), for: .touchUpInside)
            dropDownStackView?.addArrangedSubview(optionButton)
        }
        
        view.addSubview(dropDownStackView!)
        
        NSLayoutConstraint.activate([
            dropDownStackView!.topAnchor.constraint(equalTo: dropDownBtn.bottomAnchor, constant: 5),
            dropDownStackView!.leadingAnchor.constraint(equalTo: dropDownBtn.leadingAnchor, constant: -10),
            dropDownStackView!.trailingAnchor.constraint(equalTo: dropDownBtn.trailingAnchor, constant: 10)
        ])
    }
    
    private func updateChartData() {
        let dataForOption = fetchDataForOption(index: selectedOptionIndex)
        barChartView.taskCounts = dataForOption
    }
    
    private func fetchDataForOption(index: Int) -> [Int] {
        let today = Date()
        let calendar = Calendar.current
        var completedTaskCounts = [Int]()
        var range = 0..<0
        
        switch index {
        case 0:
            // Option 1: Data for the current week with a range of -3 to +3 days from today
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let start = calendar.date(byAdding: .day, value: -3, to: startOfWeek)!
            let end = calendar.date(byAdding: .day, value: 3, to: startOfWeek)!
            let days = calendar.dateComponents([.day], from: start, to: end).day!
            for day in -days/2...days/2 {
                let date = calendar.date(byAdding: .day, value: day, to: today)!
                var completedTaskCount = 0
                for reminder in reminders {
                    if calendar.isDate(reminder.dueDate, inSameDayAs: date) {
                        if reminder.isComplete {
                            completedTaskCount += 1
                        }
                    }
                }
                completedTaskCounts.append(completedTaskCount)
            }
        case 1:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let start = calendar.date(byAdding: .day, value: -3, to: startOfWeek)!
            let end = calendar.date(byAdding: .day, value: 3, to: startOfWeek)!
            range = calendar.range(of: .day, in: .weekOfMonth, for: today)!
            let days = calendar.dateComponents([.day], from: start, to: end).day!
            for day in -days/2...days/2 {
                let date = calendar.date(byAdding: .day, value: day, to: today)!
                var completedTaskCount = 0
                for reminder in reminders {
                    if calendar.isDate(reminder.dueDate, inSameDayAs: date) {
                        if reminder.isComplete {
                            completedTaskCount += 1
                        }
                    }
                }
                completedTaskCounts.append(completedTaskCount)
            }
        default:
            break
        }
        
        return completedTaskCounts
    }
    
    @objc func didTapDropDownButton() {
        if dropDownStackView == nil {
            createDropDownMenu()
        } else {
            dropDownStackView?.isHidden = !dropDownStackView!.isHidden
        }
    }
    
    @objc func didSelectOption(_ sender: UIButton) {
        dropDownBtn.setTitle(sender.currentTitle, for: .normal)
        dropDownStackView?.isHidden = true
        if let index = dropDownOptions.firstIndex(of: sender.currentTitle ?? "") {
            selectedOptionIndex = index
            if index == 1 {
                // If Option 2 is selected, update the DailyStatisticsView
                barChartView.updateForOptionTwo()
            }
        }
    }

}


//MARK: Setup Constrain
extension StatisticsViewController {
    private func setupUI() {
        setupScrollView()
        setupTitleLabel()
        setupDaylyPerfContentView()
        setupDailyStatisticsView()
        setupDropDownButton()
        updateContentViewWidth()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 800),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25)
        ])
    }
    
    private func setupDaylyPerfContentView() {
        contentView.addSubview(dailyPerfContentView)
        
        NSLayoutConstraint.activate([
            dailyPerfContentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            dailyPerfContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dailyPerfContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dailyPerfContentView.heightAnchor.constraint(equalToConstant: 330)
        ])
    }
    
    private func setupDailyStatisticsView() {
        dailyPerfContentView.addSubview(barChartView)
    }
    
    private func setupDropDownButton() {
        contentView.addSubview(dropDownBtn)

        NSLayoutConstraint.activate([
            dropDownBtn.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 2.5),
            dropDownBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
        ])
    }

    private func updateContentViewWidth() {
        let screenWidth = UIScreen.main.bounds.width
        contentView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
    }
}


//MARK: - Make UI
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
    
    private static func labelText() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .labelPrimary
        return label
    }
    
    private func dropDownButton() -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(.labelPrimary, for: .normal)
        btn.setTitle("Option 1", for: .normal)
        return btn
    }
    
    private func dropDownStaskView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 5
        return view
    }
}
