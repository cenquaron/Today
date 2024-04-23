import UIKit

class ReminderListViewController: UIViewController {

    //MARK: - Variables
    var reminderItem: [Reminder]
    
    
    //MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 98
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 52, bottom: 0.0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ReminderItemListCell.self, forCellReuseIdentifier: ReminderItemListCell.indetifier)
//        tableView.register(CreationCell.self, forCellReuseIdentifier: CreationCell.identifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTableView()
    }
    
    init(reminderItem: [Reminder]) {
        self.reminderItem = reminderItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selectors
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        setupTableViewConstrain()
    }
}



//MARK: - Setup UITableViewDelegate
//extension ReminderListViewController: UITableViewDelegate {
//    
//}


//MARK: - Setup UITableViewDataSource
extension ReminderListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderItemListCell.indetifier, for: indexPath) as!
        ReminderItemListCell
        cell.configure(with: reminderItem[indexPath.row])
        cell.buttonAction = {
            print("Tappp")
        }
        cell.selectionStyle = .none
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


//MARK: - Setup UITableView
extension ReminderListViewController {
    private func setupTableViewConstrain() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
