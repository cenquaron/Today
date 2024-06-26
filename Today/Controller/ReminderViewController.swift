import UIKit

class ReminderViewController: UIViewController {
    
    //MARK: - Variable
    private var picSquareHeightConstraint: NSLayoutConstraint?
    private var reminder: Reminder!
    
    
    //MARK: - UI Components
    private let scrollView = scrollView()
    private let contentView = contentView()
    private let titleLabels = labelText()
    private let dateImage = imageView()
    private let dateLabel = labelText()
    private let dateTimeImage = imageView()
    private let dateTimeLabel = labelText()
    private let descriptionImage = imageView()
    private let descriptionLabel = labelText()
    
    
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
        title = "reminderViewTitle".localizable
        view.backgroundColor = .backPrimary
        setupUI()
        update()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        update()
    }
    
    
    //MARK: - Selectors
    private func update() {
        titleLabels.text = reminder.title
        titleLabels.font = UIFont.preferredFont(forTextStyle: .title1)
        
        dateLabel.text = reminder.dueDate.dayText
        dateTimeLabel.text = reminder.dueDate.formatted(date: .omitted, time: .shortened)
        
        descriptionLabel.text = reminder.notes
        descriptionLabel.numberOfLines = 0
        
        dateImage.image = UIImage(systemName: "calendar.circle")
        dateTimeImage.image = UIImage(systemName: "clock")
        descriptionImage.image = UIImage(systemName: "note")
    }
    
    @objc func didTapEditButton() {
        let pushEditViewController = EditorViewController(reminder: reminder)
        self.navigationController?.pushViewController(pushEditViewController, animated: true)
    }
    
    @objc private func dismissScreen() {
        self.dismiss(animated: true)
    }
}


//MARK: Setup Constrain
extension ReminderViewController {
    private func setupUI() {
        setupScrollView()
        setupContentSquare()
        setupTitleStack()
        setupDateLabel()
        setupDateTimeLabel()
        setupDescriptionLabel()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupContentSquare() {
        scrollView.addSubview(contentView)
        
        picSquareHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
    }
    
    private func setupTitleStack() {
        contentView.addSubview(titleLabels)
        titleLabels.numberOfLines = 3
        
        NSLayoutConstraint.activate([
            titleLabels.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabels.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabels.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupDateLabel() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(dateImage)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabels.bottomAnchor, constant: 25),
            dateLabel.leadingAnchor.constraint(equalTo: dateImage.leadingAnchor, constant: 40),
            dateImage.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            dateImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupDateTimeLabel() {
        contentView.addSubview(dateTimeLabel)
        contentView.addSubview(dateTimeImage)
        
        NSLayoutConstraint.activate([
            dateTimeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 25),
            dateTimeLabel.leadingAnchor.constraint(equalTo: dateTimeImage.leadingAnchor, constant: 40),
            dateTimeImage.centerYAnchor.constraint(equalTo: dateTimeLabel.centerYAnchor),
            dateTimeImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupDescriptionLabel() {
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionImage)
        
        let descriptionSize = descriptionLabel.sizeThatFits(CGSize(width: contentView.bounds.width - 40, height: .greatestFiniteMagnitude))
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: dateTimeLabel.bottomAnchor, constant: 25),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionImage.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            descriptionImage.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor),
            descriptionImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        let picSquareHeight = descriptionSize.height + 170
        picSquareHeightConstraint?.constant = picSquareHeight
        
        contentView.layoutIfNeeded()
    }
}


//MARK: - Make UI
extension ReminderViewController {
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
        label.font =  UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .labelPrimary
        return label
    }
    
    private static func imageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 25).isActive = true
        view.heightAnchor.constraint(equalToConstant: 25).isActive = true
        view.adjustsImageSizeForAccessibilityContentSizeCategory = true
        return view
    }
    
    private static func contentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .todayListCellBackground
        view.widthAnchor.constraint(equalToConstant: 370).isActive = true
        view.layer.cornerRadius = 10
        return view
    }
}
