import UIKit

class MonthProgressView: UIView {
    
    //MARK: - Variables
    private var reminders: [Reminder] = []
    
    
    //MARK: - UI Components
    var dataPoints: [CGFloat] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var months: [String] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    //MARK: - LifeCycle
    init(reminders: [Reminder]) {
        self.reminders = reminders
        super.init(frame: .zero)
        backgroundColor = .clear
        setupData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupData()
    }
    
    
    //MARK: - Selectors
    private func setupData() {
        let calendar = Calendar.current
        var completedTasksPerMonth: [String: Int] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for i in 0..<12 {
            let monthDate = calendar.date(byAdding: .month, value: i, to: Date())!
            let monthName = dateFormatter.string(from: monthDate).uppercased()
            completedTasksPerMonth[monthName] = 0
        }
        
        for reminder in reminders {
            if reminder.isComplete {
                let monthName = dateFormatter.string(from: reminder.dueDate).uppercased()
                if let count = completedTasksPerMonth[monthName] {
                    completedTasksPerMonth[monthName] = count + 1
                }
            }
        }
        
        let sortedMonths = completedTasksPerMonth.keys.sorted(by: { dateFormatter.date(from: $0)! < dateFormatter.date(from: $1)! })
        self.months = sortedMonths
        self.dataPoints = sortedMonths.map { CGFloat(completedTasksPerMonth[$0] ?? 0) }
    }
    
    
    //MARK: - Make UI
    override func draw(_ rect: CGRect) {
        guard dataPoints.count == months.count else { return }
        
        subviews.forEach { $0.removeFromSuperview() }
        
        let margin: CGFloat = 40
        let chartMargin: CGFloat = 10
        let spacing = (rect.width - 2 * margin) / CGFloat(dataPoints.count - 1)
        let verticalOffset: CGFloat = 20
        
        let maxDataPoint = dataPoints.max() ?? 1
        let scale = (rect.height - 2 * margin - verticalOffset) / maxDataPoint
        
        let path = UIBezierPath()
        let circlePath = UIBezierPath()
        
        for (index, dataPoint) in dataPoints.enumerated() {
            let x = margin + CGFloat(index) * spacing
            let y = rect.height - margin - dataPoint * scale - verticalOffset
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            circlePath.move(to: CGPoint(x: x + 3, y: y))
            circlePath.addArc(withCenter: CGPoint(x: x, y: y), radius: 3, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        }
        
        UIColor.blue.setStroke()
        path.lineWidth = 2
        path.stroke()
        
        UIColor.blue.setFill()
        circlePath.fill()
        
        for (index, month) in months.enumerated() {
            let x = margin + CGFloat(index) * spacing
            let label = UILabel(frame: CGRect(x: x - 15, y: rect.height - margin + 5 - verticalOffset, width: 30, height: 20))
            label.text = month
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .center
            addSubview(label)
        }
        
        let yAxisLabelCount = 6
        for i in 0..<yAxisLabelCount {
            let y = rect.height - margin - (CGFloat(i) * (rect.height - 2 * margin - verticalOffset) / CGFloat(yAxisLabelCount - 1)) - verticalOffset
            let value = (maxDataPoint / CGFloat(yAxisLabelCount - 1)) * CGFloat(i)
            
            let label = UILabel(frame: CGRect(x: 0, y: y - 10, width: 30, height: 20))
            label.text = String(format: "%.0f", value)
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .right
            addSubview(label)
            
            let gridLine = UIBezierPath()
            gridLine.move(to: CGPoint(x: margin, y: y))
            gridLine.addLine(to: CGPoint(x: rect.width - margin, y: y))
            UIColor.lightGray.setStroke()
            gridLine.lineWidth = 0.5
            gridLine.stroke()
        }
    }
}
