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
    
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
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
        
        let columnWidth = bounds.width / CGFloat(7)
        let maxCount = CGFloat(taskCounts.max() ?? 1)
        let maxBarHeight = bounds.height
        
        for (index, count) in taskCounts.enumerated() {
            let barWidth = columnWidth / 3.0
            let barHeight = maxCount != 0 ? maxBarHeight * CGFloat(count) / maxCount : 0 // Check for division by zero
            let barX = CGFloat(index * 2) * columnWidth + (columnWidth - barWidth) / 2.0
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
        
        let dayOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let dayLabelHeight: CGFloat = 20
        let dayLabelWidth = bounds.width / CGFloat(7)
        for (index, day) in dayOfWeek.enumerated() {
            let label = UILabel(frame: CGRect(x: CGFloat(index) * dayLabelWidth, y: bounds.height, width: dayLabelWidth, height: dayLabelHeight))
            label.text = day
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            addSubview(label)
            
            // Check if task count for the day exists, if not, add zero
            if index < taskCounts.count {
                continue
            } else {
                taskCounts.append(0)
            }
        }
    }
}
