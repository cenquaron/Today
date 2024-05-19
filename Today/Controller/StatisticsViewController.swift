import UIKit

class StatisticsViewController: UIViewController {
    
    //MARK: - Variables
    private var reminders: [Reminder] = []
    private var currentRegion: Locale
    
    
    //MARK: - UI Components
    private let scrollView = scrollView()
    private let contentView = contentView()
    private var dailyProgressView: DailyStatisticsView!
    private var monthProgressView: MonthStatisticsView!
    
    //MARK: - LifeCycle
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
        dailyProgressView = DailyStatisticsView(reminders: reminders, region: currentRegion)
        monthProgressView = MonthStatisticsView(reminders: reminders)
        setupUI()
    }
}
    
    
//MARK: - Setup Constrain
extension StatisticsViewController {
    private func setupUI() {
        setupContentScrollView()
        setupDailyProgressView()
        setupMonthProgressView()
    }
    
    private func setupContentScrollView() {
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
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupDailyProgressView() {
        contentView.addSubview(dailyProgressView)
        dailyProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dailyProgressView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dailyProgressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dailyProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dailyProgressView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupMonthProgressView() {
        contentView.addSubview(monthProgressView)
        monthProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthProgressView.topAnchor.constraint(equalTo: dailyProgressView.bottomAnchor, constant: 50),
            monthProgressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            monthProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            monthProgressView.heightAnchor.constraint(equalToConstant: 400)
        ])
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
        view.heightAnchor.constraint(equalToConstant: 1200).isActive = true
        view.backgroundColor = .backPrimary
        return view
    }
}
