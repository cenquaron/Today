import UIKit

class ReminderCreationCell: UITableViewCell {
    
    //MARK: - Variables
    static let identifier = "ReminderCreationCell"
    
    
    //MARK: - UI Components
    private let titleTextLabel = labelText()
    private lazy var iconImage = iconImageView()
    
    
    //MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayoutView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: -  Setup Constrain
extension ReminderCreationCell {
    private func setupLayoutView() {
        addSubview(iconImage)
        addSubview(titleTextLabel)
        
        NSLayoutConstraint.activate([
            iconImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleTextLabel.leadingAnchor.constraint(equalTo: iconImage.trailingAnchor, constant: 12),
            titleTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            titleTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
    
    
//MARK: - Make UI
extension ReminderCreationCell {
    private func iconImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        var image = UIImage(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        image = image.withTintColor(.backPrimary)
        
        view.image = image
        view.widthAnchor.constraint(equalToConstant: 12).isActive = true
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true

        return view
    }
    
    private static func labelText() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "createTaskOnTableView".localizable
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true

        label.textColor = .labelTertiary
        return label
    }
}
