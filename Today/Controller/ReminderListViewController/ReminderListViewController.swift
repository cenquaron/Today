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
        view.backgroundColor = .systemBackground
        
        setupSegmentListControl()
        setupTableView()
        updateProgressHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
        setupTableViewAndProgressHeaderViewConstrain()
        updateProgressHeader()
    }
    
    @objc func didChangeListStyle(_ segment: UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue: segment.selectedSegmentIndex) ?? .today
        tableView.reloadData()
        updateProgressHeader()
    }
    
    private func updateProgressHeader() {
        headerView.progress = progress
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
        //        cell.buttonAction = {
        //            print("\(item.isComplete)")
        //        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


//MARK: - Setup UITableView
extension ReminderListViewController {
    private func setupTableViewAndProgressHeaderViewConstrain() {
        setupHeaderview()
        setupUITableViewConstrain()
    }
    
    private func setupHeaderview() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            headerView.widthAnchor.constraint(equalToConstant: 400),
            headerView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupUITableViewConstrain() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
