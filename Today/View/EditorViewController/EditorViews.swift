import UIKit

class EditorView: UIViewController {
    
    //MARK: - Variables
    weak var delegate: ReminderUpdateDelegate?
    private var notes: String?
    var reminder: Reminder
    var onSave: (() -> Void)?
    
    
    //MARK: - UI Components
    private let scrollView = scrollView()
    private let contentView = contentView()
    private let titleLabel = labelText()
    private let titleField = fieldText()
    private let dateLabel = labelText()
    private let dateStack = dateView()
    private let datePicker = datePicker()
    private let timerTextLabel = labelText()
    private let timerPicker = timePicker()
    private let notesLabel = labelText()
    private let notesField = notesText()
    
    
    //MARK: - LifeCycle
    init(reminder: Reminder) {
        self.reminder = reminder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Reminder"
        view.backgroundColor = .backPrimary
        setupUI()
        update()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTap))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    //MARK: - Selectors
    private func update() {
        titleField.delegate = self
        
        titleLabel.text = "TITLE"
        titleField.placeholder = "Что нужно делать?" //Accesebility
        titleField.text = reminder.title
        
        dateLabel.text = "DATE"
        datePicker.date = reminder.dueDate
        
        timerTextLabel.text = "TIME"
        timerTextLabel.font = .boldSystemFont(ofSize: 14)
        timerPicker.date = reminder.dueDate
        
        notesLabel.text = "NOTES"
        notesField.text = reminder.notes
    }
    
    @objc func saveButtonTap(_ sender: UIBarButtonItem) {
        reminder.title = titleField.text ?? ""
        reminder.notes = notesField.text ?? ""
        
        let selectedDate = datePicker.date
        let selectedTime = timerPicker.date
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        let day = calendar.component(.day, from: selectedDate)
        let hour = calendar.component(.hour, from: selectedTime)
        let minute = calendar.component(.minute, from: selectedTime)
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let combinedDate = calendar.date(from: dateComponents)
        
        reminder.dueDate = combinedDate ?? Date()
        
        do {
            let eventStore = ReminderStore()
            try eventStore.save(reminder)
            delegate?.didUpdateReminder(reminder)
            onSave?()
            self.dismiss(animated: true)
        } catch {
            print("failed save \(error)")
        }
    }
}


//MARK: Setup Constrain
extension EditorView {
    private func setupUI() {
        setupContentScrollView()
        setupTitleStack()
        setupDateStack()
        setupNotesStack()
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
    
    private func setupTitleStack() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleField)
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        
        titleField.leftView = leftPaddingView
        titleField.leftViewMode = .always
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: titleField.leadingAnchor, constant: 15),
            
            titleField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            titleField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupDateStack() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(dateStack)
        contentView.addSubview(datePicker)
        dateStack.addSubview(timerTextLabel)
        dateStack.addSubview(timerPicker)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 30),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            dateStack.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            dateStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateStack.topAnchor, constant: -10),
            datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            timerTextLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            timerTextLabel.leadingAnchor.constraint(equalTo: dateStack.leadingAnchor, constant: 20),
            
            timerPicker.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 3),
            timerPicker.trailingAnchor.constraint(equalTo: dateStack.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupNotesStack() {
        contentView.addSubview(notesLabel)
        contentView.addSubview(notesField)
        
        NSLayoutConstraint.activate([
            notesLabel.topAnchor.constraint(equalTo: dateStack.bottomAnchor, constant: 20),
            notesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            notesField.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 10),
            notesField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}


//MARK: - Make UI
extension EditorView {
    private static func contentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 800).isActive = true
        view.backgroundColor = .backPrimary
        return view
    }
    
    private static func scrollView() -> UIScrollView {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = true
        view.alwaysBounceVertical = true
        view.backgroundColor = .backPrimary
        return view
    }
    
    private static func labelText() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .labelPrimary
        return label
    }
    
    private static func fieldText() -> UITextField {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        view.widthAnchor.constraint(equalToConstant: 370).isActive = true
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.layer.cornerRadius = 9
        view.clearButtonMode = .whileEditing
        view.backgroundColor = .backSecondary
        return view
    }
    
    private static func dateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.backgroundColor = .backSecondary
        view.heightAnchor.constraint(equalToConstant: 380).isActive = true
        view.widthAnchor.constraint(equalToConstant: 370).isActive = true
        return view
    }
    
    private static func datePicker() -> UIDatePicker {
        let date = UIDatePicker()
        date.translatesAutoresizingMaskIntoConstraints = false
        date.tintColor = .systemBlue
        date.datePickerMode = .date
        date.preferredDatePickerStyle = .inline
        date.locale = Locale.current.calendar.locale
        date.widthAnchor.constraint(equalToConstant: 360).isActive = true
        date.heightAnchor.constraint(equalToConstant: 330).isActive = true
        return date
    }
    
    private static func timePicker() -> UIDatePicker {
        let date = UIDatePicker()
        date.translatesAutoresizingMaskIntoConstraints = false
        date.datePickerMode = .time
        date.locale = Locale.current.calendar.locale
        return date
    }
    
    private static func notesText() -> UITextView {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.backgroundColor = .backSecondary
        view.widthAnchor.constraint(equalToConstant: 370).isActive = true
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8)
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.autocorrectionType = .yes
        view.spellCheckingType = .yes
        view.dataDetectorTypes = .all
        view.keyboardType = .default
        return view
    }
}
