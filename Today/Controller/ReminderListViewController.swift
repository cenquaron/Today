import UIKit
import EventKit
import QuartzCore

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
        view.register(ReminderItemListCell.self, forCellReuseIdentifier: ReminderItemListCell.identifier)
        view.register(ReminderCreationCell.self, forCellReuseIdentifier: ReminderCreationCell.identifier)
        view.backgroundColor = .clear
        view.separatorInset = UIEdgeInsets(top: 0.0, left: 52, bottom: 0.0, right: 0)
        view.showsVerticalScrollIndicator = false
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createButtonDidTapped))
        view.backgroundColor = .backPrimary
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(statisticsController))

        tableView.reloadData()
        setupSegmentListControl()
        setupTableView()
        updateReminderTask()
        updateProgressHeader()
        prepareReminderStore()
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
    private var progress: CGFloat {
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
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        updateProgressHeader()
        setupUI()
    }
    
    private func updateReminderTask() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminderItem = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged), name: .EKEventStoreChanged, object: nil)
                updateProgressHeader()
                tableView.reloadData()
            } catch TodayError.accessDenied, TodayError.accessRestricted {
            } catch {
                showError(error)
            }
        }
    }
    
    private func updateProgressHeader() {
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
    
    private func reminderStoreChanged() {
        Task {
            reminderItem = try await reminderStore.readAll()
            reloadTableViewData()
        }
    }
    
    private func updateReminder(_ reminder: Reminder) {
        let index = reminderItem.indexOfReminder(withId: reminder.id)
        reminderItem[index] = reminder
        do {
            try reminderStore.save(reminder)
        } catch {
            showError(error)
        }
    }
    
    private func reminder(withId id: Reminder.ID) -> Reminder {
        let index = reminderItem.indexOfReminder(withId: id)
        return reminderItem[index]
    }
    
    private func completeReminder(withId id: Reminder.ID) {
        if let index = reminderItem.firstIndex(where: { $0.id == id }) {
            reminderItem[index].isComplete.toggle()
            updateReminder(reminderItem[index])
            updateProgressHeader()
            reloadTableViewData()
        }
    }
    
    private func addReminder() {
        let newReminder = Reminder(title: "", dueDate: Date(), notes: " ")
        let editorViewController = EditorViewController(reminder: newReminder)
        editorViewController.delegate = self
        editorViewController.onSave = { [weak self] in
            self?.updateReminderTask()
            self?.reloadTableViewData()
        }
        let navigationController = UINavigationController(rootViewController: editorViewController)
        present(navigationController, animated: true)
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
    
    private func reloadTableViewData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func didChangeListStyle(_ segment: UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue: segment.selectedSegmentIndex) ?? .today
        updateProgressHeader()
        tableView.reloadData()
    }
    
    @objc func eventStoreChanged(_ notification: NSNotification) {
        reminderStoreChanged()
    }
    
    @objc func createButtonDidTapped() {
        addReminder()
    }
    
    @objc func statisticsController() {
        let statisticsController = StatisticsViewController(reminders: reminderItem)
        navigationController?.pushViewController(statisticsController, animated: true)
    }
}


//MARK: - Setup UITableViewDataSource UITableViewDelegate
extension ReminderListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterReminder.count + 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == filterReminder.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCreationCell.identifier, for: indexPath) as! ReminderCreationCell
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.clipsToBounds = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderItemListCell.identifier, for: indexPath) as! ReminderItemListCell
            let item = filterReminder[indexPath.row]
            cell.configure(with: item)
            cell.delegate = self
            cell.selectionStyle = .none
            
            if indexPath.row == 0 {
                cell.layer.cornerRadius = 10
                cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                cell.clipsToBounds = true
            } else {
                cell.layer.cornerRadius = 0
                cell.clipsToBounds = false
            }
            
            return cell
        }
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
            
            if indexPath.row == filterReminder.count {
                addReminder()
            } else {
                let selectedReminder = filterReminder[indexPath.row]
                guard let indexInReminders = reminderItem.firstIndex(where: { $0.id == selectedReminder.id }) else {
                    fatalError("Failed to find index of selected reminder in reminderItem.")
                }
                let controller = ReminderViewController(reminder: reminderItem[indexInReminders])
                let openController = UINavigationController(rootViewController: controller)
                self.present(openController, animated: true)
            }
        }
    }

    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == filterReminder.count {
            return nil
        }

        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            guard let guest = self else { return }

            let selectedReminder = guest.filterReminder[indexPath.row]
            guest.completeReminder(withId: selectedReminder.id)

            completion(true)
        }

        action.image = UIImage(systemName: "checkmark.circle.fill")
        action.backgroundColor = .systemGreen

        return UISwipeActionsConfiguration(actions: [action])
    } 
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row == filterReminder.count {
            return
        }
        
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

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == filterReminder.count {
            return nil
        }

        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            guard let guest = self else { return }

            
            let deletedReminder = guest.filterReminder[indexPath.row]
            if let indexInReminders = guest.reminderItem.firstIndex(of: deletedReminder) {
                guest.reminderItem.remove(at: indexInReminders)
                tableView.deleteRows(at: [indexPath], with: .fade)
                guest.updateProgressHeader()
                
                // Remove from Reminder Store
                do {
                    let reminderId = deletedReminder.id
                    try guest.reminderStore.remove(with: reminderId)
                } catch {
                    guest.showError(error)
                }
            }
        }

        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [action])
    }

    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == filterReminder.count {
            return .none
        } else {
            return .delete
        }
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            guard tableView.cellForRow(at: indexPath) is ReminderItemListCell else { return nil }
            
            let accomplish = UIAction(title: "Отметить", image: UIImage(systemName: "checkmark.circle.fill")) { [weak self] _ in
                guard let self = self else { return }
                let selectedReminder = self.filterReminder[indexPath.row]
                self.completeReminder(withId: selectedReminder.id)
                tableView.reloadData()
            }
  
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [self] _ in

                let selectedReminder = self.filterReminder[indexPath.row]
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
        return max(60, UITableView.automaticDimension)
    }
}


//MARK: - Setup UITableView Constrain
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
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
    }
}


//MARK: - Make UI
extension ReminderListViewController {
    private func creareButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "createButton"), for: .normal)
        btn.layer.cornerRadius = 0.5 * 44
        btn.layer.shadowColor = UIColor(red: 0/255, green: 49/255, blue: 102/255, alpha: 0.30).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 5)
        btn.layer.shadowOpacity = 0.5
        btn.addTarget(self, action: #selector(createButtonDidTapped), for: .touchUpInside)
        return btn
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
            tableView.reloadData()
        }
    }
}

extension ReminderListViewController: ReminderUpdateDelegate {
    func didUpdateReminder(_ reminder: Reminder) {
        if let index = reminderItem.firstIndex(where: { $0.id == reminder.id }) {
            reminderItem[index] = reminder
            
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
}
