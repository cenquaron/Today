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
    lazy var tableView: UITableView = {
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
        tableView.reloadData()
        setupSegmentListControl()
        setupTableView()
        updateReminderTask()
        updateProgressHeader()
        prepareReminderStore()
        refreshBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateReminderTask()
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
    
    func updateReminderTask() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminderItem = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged), name: .EKEventStoreChanged, object: nil)
                updateProgressHeader() // Обновляем заголовок после загрузки данных
                tableView.reloadData() // Обновляем таблицу сразу после загрузки данных
            } catch TodayError.accessDenied, TodayError.accessRestricted {
            } catch {
                showError(error)
            }
        }
    }
    
    func updateProgressHeader() {
        headerView.progress = progress
    }
    
    private func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminderItem = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
            } catch {
                showError(error)
            }
            updateProgressHeader()
        }
    }
    
    func reminderStoreChanged() {
        Task {
            reminderItem = try await reminderStore.readAll()
        }
    }
    
    func updateReminder(_ reminder: Reminder) {
        let index = reminderItem.indexOfReminder(withId: reminder.id)
        reminderItem[index] = reminder
        do {
            try reminderStore.save(reminder)
        } catch {
            showError(error)
        }
    }
    
    
    func reminder(withId id: Reminder.ID) -> Reminder {
        let index = reminderItem.indexOfReminder(withId: id)
        return reminderItem[index]
    }
    
    func completeReminder(withId id: Reminder.ID) {
        if let index = reminderItem.firstIndex(where: { $0.id == id }) {
            reminderItem[index].isComplete.toggle()
            updateReminder(reminderItem[index])
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            updateProgressHeader()
        }
    }
    
    
    func addReminder(_ reminder: Reminder) {
        var reminder = reminder
        do {
            let idFromStore = try reminderStore.save(reminder)
            reminder.id = idFromStore
            reminderItem.append(reminder)
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    func refreshBackground() {
        tableView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradientLayer(for: listStyle, in: view.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        tableView.backgroundView = backgroundView
    }
    
    
    private func showError(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alert = UIAlertController(
            title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "Alert OK button title")
        alert.addAction(
            UIAlertAction(
                title: actionTitle, style: .default,
                handler: { [weak self] _ in
                    self?.dismiss(animated: true)
                }))
        present(alert, animated: true, completion: nil)
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.17) {
            guard let selectedCell = tableView.cellForRow(at: indexPath) else {
                fatalError("Error appearing while selecting cell. Check UITableView conformance - didSelectRowAt.")
            }
            selectedCell.transform = CGAffineTransform(scaleX: 1.033, y: 1.033)
        } completion: { [self] _ in
            UIView.animate(withDuration: 0.17) {
                guard let selectedCell = tableView.cellForRow(at: indexPath) else {
                    fatalError("Error appearing while selecting cell. Check UITableView conformance - didSelectRowAt.")
                }
                selectedCell.transform = .identity
                tableView.deselectRow(at: indexPath, animated: true)
            }
            let selectedReminder = reminderItem[indexPath.row]
            let controller = ReminderViewController(reminder: selectedReminder)
            controller.delegate = self
            let openController = UINavigationController(rootViewController: controller)
            self.present(openController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedReminder = filterReminder[indexPath.row]
            if let indexInReminders = reminderItem.firstIndex(of: deletedReminder) {
                reminderItem.remove(at: indexInReminders)
                tableView.deleteRows(at: [indexPath], with: .fade)
                updateProgressHeader()
                
                //rm in Reminder
                do {
                    let reminderId = deletedReminder.id
                    try reminderStore.remove(with: reminderId)
                } catch {
                    showError(error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            guard tableView.cellForRow(at: indexPath) is ReminderItemListCell else { return nil }
            
            let accomplish = UIAction(title: "Отметить", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in
                guard let self = self else { return }
                let selectedReminder = self.filterReminder[indexPath.row]
                self.completeReminder(withId: selectedReminder.id)
            }
            
            
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                let selectedReminder = self.reminderItem[indexPath.row]
                let controller = EditorViewController(reminder: selectedReminder)
                controller.delegate = self
                let openController = UINavigationController(rootViewController: controller)
                self.present(openController, animated: true)
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash.fill")) { [self] _ in
                let deletedReminder = filterReminder[indexPath.row]
                if let indexInReminders = reminderItem.firstIndex(of: deletedReminder) {
                    reminderItem.remove(at: indexInReminders)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    updateProgressHeader()
                    
                    //rm in Reminder
                    do {
                        let reminderId = deletedReminder.id
                        try reminderStore.remove(with: reminderId)
                    } catch {
                        showError(error)
                    }
                }
            }
            
            let menu = UIMenu(children: [accomplish, edit, delete])
            
            return menu
        }
        
        return configuration
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

//MARK: - Used Protocol
extension ReminderListViewController: ReminderItemListCellDelegate {
    func didTapDoneButton(for reminder: Reminder) {
        if let index = reminderItem.firstIndex(where: { $0.id == reminder.id }) {
            reminderItem[index] = reminder
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            updateProgressHeader()
            updateReminder(reminder)
        }
    }
}

extension ReminderListViewController: ReminderUpdateDelegate {
    func didUpdateReminder(_ reminder: Reminder) {
        if let index = reminderItem.firstIndex(where: { $0.id == reminder.id }) {
            reminderItem[index] = reminder
            
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

