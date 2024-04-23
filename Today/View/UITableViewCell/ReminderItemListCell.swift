import UIKit

class ReminderItemListCell: UITableViewCell {
    
    //MARK: - Variables
    static let indetifier = "ReminderItemListCell"
    private var reminder: Reminder!
    var buttonAction: (() -> Void)?
    
    //MARK: - UI Components
    private lazy var doneButton = completeButton()
    private var infoStackView = mainInfoStackView()
    private var titleLabel = labelText()
    private var dateLabel = labelText()
    private var markMore = markMoreImage()
    
    
    //MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with reminder: Reminder) {
        self.reminder = reminder
        titleLabel.text = reminder.title
        dateLabel.text = reminder.dueDate.dayAndTimeText
        updateButton()
    }
    
    
    //MARK: - Selectors
    @objc func didTapCompleteButton() {
        doneButton.isSelected = !doneButton.isSelected
        reminder.isComplete = doneButton.isSelected
        
        buttonAction?()
        updateButton()
        print("\(reminder.isComplete)")
    }
    
    func updateButton() {
        let imageName = reminder!.isComplete ? "checked" : "unchecked"
        doneButton.setImage(UIImage(named: imageName), for: .normal)
    }

}

//MARK: -  Setup Constrain
extension ReminderItemListCell {
    private func setupLayout() {
        setupCompleteButton()
        setupMarkMoreImage()
        setupInfoStackLabel()
    }
    
    private func setupCompleteButton() {
        contentView.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            doneButton.widthAnchor.constraint(equalToConstant: 24),
            doneButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupInfoStackLabel() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: markMore.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupMarkMoreImage() {
        contentView.addSubview(markMore)

        NSLayoutConstraint.activate([
            markMore.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            markMore.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            markMore.widthAnchor.constraint(equalToConstant: 7),
            markMore.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
}




//MARK: - Make UI
extension ReminderItemListCell {
    private func completeButton() -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        return btn
    }
    
    private static func labelText() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .labelPrimary
        label.numberOfLines = 3
        return label
    }
    
    private static func mainInfoStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 5
        view.axis = .vertical
        view.distribution = .fill
        return view
    }
    
    private static func markMoreImage() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "seeMore")
        return view
    }
}
