import UIKit

class ReminderItemListCell: UITableViewCell {
    
    //MARK: - Variables
    static let identifier = "ReminderItemListCell"
    weak var delegate: ReminderItemListCellDelegate?
    private var reminder: Reminder!
    
    
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
        updateUI()
    }
    
    
    //MARK: - Selectors
    private func updateUI() {
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.font =  UIFont.preferredFont(forTextStyle: .footnote)
    }
    
    func updateButton() {
        let imageName = reminder!.isComplete ? "checked" : "unchecked"
        doneButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @objc func didTapCompleteButton() {
        reminder.isComplete.toggle()
        updateButton()
        delegate?.didTapDoneButton(for: reminder)
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
        contentView.addSubview(infoStackView)
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            infoStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: doneButton.trailingAnchor, constant: 12),
            infoStackView.trailingAnchor.constraint(equalTo: markMore.trailingAnchor, constant: -16),
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
        label.textColor = .labelPrimary
        return label
    }
    
    private static func mainInfoStackView() -> UIStackView {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 4
        view.axis = .vertical
        view.distribution = .fill
        return view
    }
    
    private static func markMoreImage() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsImageSizeForAccessibilityContentSizeCategory = true
        view.image = UIImage(named: "seeMore")
        return view
    }
}
