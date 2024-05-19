import UIKit

class DailyProgressBarGraphView: UIView {
    
    //MARK: - Variables
    var progress: [CGFloat] = [] {
        didSet {
            setupBarsAndLabels()
        }
    }
    var days: [String] = ["S", "M", "T", "W", "T", "F", "S"]
    
    //MARK: - UI Components
    private var bars: [UIView] = []
    private var labels: [UILabel] = []
    private var taskCountLabels: [UILabel] = []
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBarHeightsAndLabels()
    }
    
    private func updateBarHeightsAndLabels() {
        guard !progress.isEmpty else { return }
        
        let barWidth = bounds.width / CGFloat(progress.count)
        let actualBarWidth = barWidth / 2
        
        for (index, ratio) in progress.enumerated() {
            let barHeight = ratio * bounds.height * 0.8
            let bar = bars[index]
            let label = labels[index]
            let taskCountLabel = taskCountLabels[index]
            
            bar.frame = CGRect(x: CGFloat(index) * barWidth + (barWidth - actualBarWidth) / 2, y: self.bounds.height - barHeight - 20, width: actualBarWidth, height: barHeight)
            label.frame = CGRect(x: CGFloat(index) * barWidth, y: self.bounds.height - 20, width: barWidth, height: 20)
            taskCountLabel.frame = CGRect(x: CGFloat(index) * barWidth, y: self.bounds.height - barHeight - 40, width: barWidth, height: 20)
            
            taskCountLabel.text = "\(Int(progress[index] * 100))%"
            
            if let gradientLayer = bar.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = bar.bounds
            }
        }
    }
    
    
    //MARK: - Setup Bars and Labels
    private func setupBarsAndLabels() {
        bars.forEach { $0.removeFromSuperview() }
        labels.forEach { $0.removeFromSuperview() }
        taskCountLabels.forEach { $0.removeFromSuperview() }
        bars.removeAll()
        labels.removeAll()
        taskCountLabels.removeAll()
        
        days = progress.count == 10 ? ["F", "S", "S", "M", "T", "W", "T", "F", "S", "S"] : ["M", "T", "W", "T", "F", "S", "S"]
        
        for day in days {
            let bar = createBarView()
            let label = createLabel(text: day)
            let taskCountLabel = createLabel(text: "0")
            addSubview(bar)
            addSubview(label)
            addSubview(taskCountLabel)
            bars.append(bar)
            labels.append(label)
            taskCountLabels.append(taskCountLabel)
        }
        
        updateBarHeightsAndLabels()
    }
}


//MARK: - Make UI
extension DailyProgressBarGraphView {
    private func createBarView() -> UIView {
        let barView = UIView()
        barView.translatesAutoresizingMaskIntoConstraints = false
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.systemBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.cornerRadius = 5
        barView.layer.addSublayer(gradientLayer)
        
        return barView
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
