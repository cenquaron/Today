import UIKit

class DailyProgressView: UIView {
    
    //MARK: - Variables
    var progress: [CGFloat] = [] {
        didSet {
            setupBarsAndLabels()
        }
    }
    var days: [String] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    var displayLast10Days: Bool = false {
        didSet {
            calculateDays()
            updateProgress()
            setupBarsAndLabels()
        }
    }
    
    
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
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBarHeightsAndLabels()
    }
    
    private func updateBarHeightsAndLabels() {
        guard !progress.isEmpty, !progress.allSatisfy({ $0 == 0 }) else { return }
        
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
        
        guard !progress.isEmpty, !progress.allSatisfy({ $0 == 0 }) else { return }
        
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

    
    private func calculateDays() {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        
        var currentDay = Date()
        let daysCount = displayLast10Days ? 10 : 7
        
        days.removeAll()
        
        for _ in 0..<daysCount {
            let dayString = dateFormatter.string(from: currentDay)
            days.append(dayString)
            currentDay = calendar.date(byAdding: .day, value: -1, to: currentDay) ?? currentDay
        }
        
        days.reverse()
    }
    
    private func updateProgress() {
        if displayLast10Days {
            progress = Array(progress.prefix(10))
        } else {
            progress = Array(progress.prefix(7))
        }
    }
}
    

//MARK: - Make UI
extension DailyProgressView {
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
