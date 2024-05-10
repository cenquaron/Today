import UIKit

class StatisticsViewController: UIViewController {
    
    //MARK: - Variables
    private var reminder: [Reminder] = []
    private let dropDownOptions = ["Option 1", "Option 2", "Option 3"]
    
    
    //MARK: - UI Components
    private let titleLabel = labelText()
    private let contentView = contentView()
    private lazy var dropDownBtn = dropDownButton()
    var dropDownStackView: UIStackView?

    
    //MARK: - LifeCycle
    init(reminder: [Reminder]) {
        self.reminder = reminder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .todayNavigationBackground
        setupUI()
        updateUI()
    }
    
    
    //MARK: - Selectors
    private func updateUI() {
        titleLabel.text = "daily perfomance".uppercased()
        dropDownBtn.addTarget(self, action: #selector(didTapDropDownButton), for: .touchUpInside)
        
    }
    
    func createDropDownMenu() {
        dropDownStackView = UIStackView()
        dropDownStackView?.axis = .vertical
        dropDownStackView?.alignment = .fill
        dropDownStackView?.distribution = .fillEqually
        dropDownStackView?.spacing = 5
        dropDownStackView?.translatesAutoresizingMaskIntoConstraints = false
        dropDownStackView?.backgroundColor = .systemBackground

        
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
    }
}


//MARK: Setup Constrain
extension StatisticsViewController {
    private func setupUI() {
        setupTitleLabel()
        setupContentView()
        setupDailyStatisticsView()
        setupDropDownButton()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25)
        ])
    }
    
    private func setupContentView() {
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
    
    private func setupDailyStatisticsView() {
        let barChartView = DailyStatisticsView(frame: CGRect(x: 20, y: 165, width: view.frame.width - 40, height: 280))

        barChartView.backgroundColor = .clear
    
        barChartView.layer.cornerRadius = 10
        view.addSubview(barChartView)
        
        barChartView.taskCounts = [2, 4, 1, 5, 0, 3, 2]
    }
    
    private func setupDropDownButton() {
        view.addSubview(dropDownBtn)
        
        NSLayoutConstraint.activate([
            dropDownBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2.5),
            dropDownBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
        ])
    }
}


//MARK: - Make UI
extension StatisticsViewController {
    private static func labelText() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .body
        label.textColor = .labelPrimary
        return label
    }
    
    private static func contentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .todayListCellBackground
        view.layer.cornerRadius = 5
        return view
    }
    
    private func dropDownButton() -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Select Option", for: .normal)
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
