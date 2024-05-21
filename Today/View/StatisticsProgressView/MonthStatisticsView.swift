import UIKit

class MonthStatisticsView: UIView {
    
    //MARK: - Variables
    private var reminders: [Reminder] = []
    
    
    //MARK: - UI Components
    private let contentView = contentView()
    private let monthTaskContentView = contentView()
    private let titleMonthLabel = titleLabel()
    private let monthView: MonthProgressView
    
    
    //MARK: - LifeCycle
    init(reminders: [Reminder]) {
        self.reminders = reminders
        self.monthView = MonthProgressView(reminders: reminders)
        super.init(frame: .zero)
        setupUI()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selectors
    private func updateUI() {
        monthView.backgroundColor = .todayListCellBackground
    }
}


// MARK: - Setup Constrain
extension MonthStatisticsView {
    private func setupUI() {
        setupContentView()
        setupTitleDailyView()
        setupMonthProgressView()
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
        contentView.addSubview(titleMonthLabel)
        
        NSLayoutConstraint.activate([
            titleMonthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleMonthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
        ])
    }
    
    
    private func setupMonthProgressView() {
        contentView.addSubview(monthView)
        monthView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthView.topAnchor.constraint(equalTo: titleMonthLabel.bottomAnchor, constant: 10),
            monthView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            monthView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            monthView.heightAnchor.constraint(equalToConstant: 330)
        ])
    }
}


//MARK: - Make UI
extension MonthStatisticsView {
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
        label.text = "Year Performance".uppercased()
        return label
    }
}
