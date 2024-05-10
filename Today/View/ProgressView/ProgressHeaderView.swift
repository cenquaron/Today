import UIKit

class ProgressHeaderView: UIView {
    
    //MARK: - Variables
    var progress: CGFloat = 0 {
        didSet {
            heightConstraint?.constant = progress * bounds.height
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    
    //MARK: - UI Components
    private let upperView = takedView()
    private let lowerView = takedView()
    private let containerView = takedView()
    private var heightConstraint: NSLayoutConstraint?
    
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        heightConstraint?.constant = progress * bounds.height
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.5 * containerView.bounds.width
    }
}


//MARK: - Setup Constrain
extension ProgressHeaderView {
    private func setupLayout() {
        heightConstraint = lowerView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        setupContainerView()
        setupLowerAndUpperPosition()
    }
    
    private func setupContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1),
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85)
        ])
    }
    
    private func setupLowerAndUpperPosition() {
        containerView.addSubview(upperView)
        containerView.addSubview(lowerView)
        upperView.translatesAutoresizingMaskIntoConstraints = false
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        upperView.backgroundColor = .todayProgressUpperBackground //clearPlace
        lowerView.backgroundColor = .todayProgressLowerBackground //filling


        NSLayoutConstraint.activate([
            upperView.topAnchor.constraint(equalTo: topAnchor),
            upperView.bottomAnchor.constraint(equalTo: lowerView.topAnchor),
            lowerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            upperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            upperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lowerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}


//MARK: - Make UI
extension ProgressHeaderView {
    private static func takedView() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
