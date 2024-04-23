import UIKit

class ReminderListViewController: UIViewController {
    
    //MARK: - Variable
    var reminderStore: ReminderStore { ReminderStore.shared }
    var reminderItem: [Reminder] = []
    var listStyle: ReminderListStyle = .today
    var filterReminder: [Reminder] {
        return reminderItem.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted {
            $0.dueDate < $1.dueDate
        }
    }
    let listStyleSegmentControl = UISegmentedControl(items: [
        ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name
    ])
    
    //MARK: - UI Components
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(ReminderItemListCell.self, forCellReuseIdentifier: ReminderItemListCell.indetifier)
        view.backgroundColor = .clear
        view.estimatedRowHeight = 98
        view.separatorInset = UIEdgeInsets(top: 0.0, left: 52, bottom: 0.0, right: 0)
        view.showsVerticalScrollIndicator = false
        view.rowHeight = UITableView.automaticDimension
        return view
    }()
    
    private let headerView = ProgressHeaderView()
    private func setupSegmentListControl() {
        listStyleSegmentControl.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentControl.addTarget(self, action: #selector(didChangeListStyle), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentControl
    }
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentListControl()
        setupTableView()
        updateProgressHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        refreshBackground()
    }
    
    init(reminderItem: [Reminder]) {
        self.reminderItem = reminderItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selectors
    var progress: CGFloat {
        let chunkSize = 1.0 / CGFloat(filterReminder.count)
        let progress = filterReminder.reduce(0.0) {
            let chunk = $1.isComplete ? chunkSize : 0
            return $0 + chunk
        }
        return progress
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        setupUI()
        updateProgressHeader()
    }
    
    @objc func didChangeListStyle(_ segment: UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue: segment.selectedSegmentIndex) ?? .today
        tableView.reloadData()
        refreshBackground()
        updateProgressHeader()
    }
    
    private func updateProgressHeader() {
        headerView.progress = progress
    }
    
    private func refreshBackground() {
        tableView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradientLayer(for: listStyle, in: view.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        tableView.backgroundView = backgroundView
    }
}


//MARK: - Setup UITableViewDataSource UITableViewDelegate
extension ReminderListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterReminder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderItemListCell.indetifier, for: indexPath) as!
        ReminderItemListCell
        let item = filterReminder[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


//MARK: - Setup UITableView
extension ReminderListViewController {
    private func setupUI() {
        setupHeaderview()
        setupUITableViewConstrain()
    }
    
    private func setupHeaderview() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 400),
            headerView.widthAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupUITableViewConstrain() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


extension ReminderListViewController: ReminderItemListCellDelegate {
    func didTapDoneButton(for reminder: Reminder) {
        if let index = reminderItem.firstIndex(where: { $0.id == reminder.id }) {
            reminderItem[index] = reminder
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            updateProgressHeader()
        }
    }
}
