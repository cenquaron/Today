
import UIKit

class DailyStatisticsView: UIView {
    
    //MARK: - Variables
    var taskCounts: [Int] = [] {
        didSet {
            drawBarChart()
        }
    }
    
    private var bars: [UIView] = []
    private var labelCounter: [UIView] = []
    private var dayLabels: [UILabel] = []
    private var numberOfDaysInWeek = 7 // Default value
    private let columnWidth: CGFloat = 40
    private let columnSpacing: CGFloat = 10
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDayLabels()
        let totalWidth = columnWidth * 7 + columnSpacing * 6 // 7 days with spacing between them
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: totalWidth, height: frame.height)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Make UI
    private func drawBarChart() {
        bars.forEach { $0.removeFromSuperview() }
        labelCounter.forEach { $0.removeFromSuperview() }
        bars.removeAll()
        labelCounter.removeAll()
        
        guard !taskCounts.isEmpty else {
            return
        }
        
        let columnWidth = bounds.width / CGFloat(taskCounts.count)
        let maxCount = CGFloat(taskCounts.max() ?? 1)
        let maxBarHeight = bounds.height - 30 // Account for space for day labels
        
        for (index, count) in taskCounts.enumerated() {
            let barWidth = columnWidth / CGFloat(numberOfDaysInWeek) // Divide by the number of days in a week
            let barHeight = maxCount != 0 ? maxBarHeight * CGFloat(count) / maxCount : 0 // Check for division by zero
            let barX = CGFloat(index) * columnWidth + (columnWidth - barWidth) / 2.0
            let barY = maxBarHeight - barHeight
            
            let bar = UIView(frame: CGRect(x: barX, y: barY, width: barWidth, height: barHeight))
            bar.backgroundColor = .systemBlue
            addSubview(bar)
            bars.append(bar)
            
            let labelWidth: CGFloat = 30
            let labelX = barX + (barWidth - labelWidth) / 2.0
            let label = UILabel(frame: CGRect(x: labelX, y: barY - 20, width: labelWidth, height: 20))
            label.text = "\(count)"
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 15)
            addSubview(label)
            labelCounter.append(label)
        }
        
        let dayLabelHeight: CGFloat = 20
        let dayLabelWidth = bounds.width / CGFloat(taskCounts.count)
        for (index, label) in dayLabels.enumerated() {
            label.frame = CGRect(x: CGFloat(index) * dayLabelWidth, y: bounds.height - dayLabelHeight, width: dayLabelWidth, height: dayLabelHeight)
        }
    }
    
    private func setupDayLabels() {
        let dayOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let totalDays = numberOfDaysInWeek > 7 ? numberOfDaysInWeek : 7
        
        let dayLabelHeight: CGFloat = 20
        let dayLabelWidth = bounds.width / CGFloat(totalDays)
        
        for index in 0..<totalDays {
            let label = UILabel(frame: CGRect(x: CGFloat(index) * dayLabelWidth, y: bounds.height - dayLabelHeight, width: dayLabelWidth, height: dayLabelHeight))
            label.text = dayOfWeek[index % 7] // Cycling through the default days of the week
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            addSubview(label)
            dayLabels.append(label)
        }
    }
    
    func updateForOptionTwo() {
        numberOfDaysInWeek += 3
        for label in dayLabels {
            label.removeFromSuperview()
        }
        
        dayLabels.removeAll()
        setupDayLabels()
        drawBarChart()
    }
}
