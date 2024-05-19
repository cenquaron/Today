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
        
        // Инициализация месяцев
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        for i in 0..<10 {
            let monthDate = calendar.date(byAdding: .month, value: i, to: Date())!
            let monthName = dateFormatter.string(from: monthDate).uppercased()
            completedTasksPerMonth[monthName] = 0
        }
        
        // Подсчет выполненных задач по месяцам
        for reminder in reminders {
            if reminder.isComplete {
                let monthName = dateFormatter.string(from: reminder.dueDate).uppercased()
                if let count = completedTasksPerMonth[monthName] {
                    completedTasksPerMonth[monthName] = count + 1
                }
            }
        }
        
        // Преобразование данных для MonthProgressView
        let sortedMonths = completedTasksPerMonth.keys.sorted(by: { dateFormatter.date(from: $0)! < dateFormatter.date(from: $1)! })
        self.months = sortedMonths
        self.dataPoints = sortedMonths.map { CGFloat(completedTasksPerMonth[$0] ?? 0) }
    }
    
    
    //MARK: - Make UI
    override func draw(_ rect: CGRect) {
        guard dataPoints.count == months.count else { return }
        
        // Удаление существующих меток
        subviews.forEach { $0.removeFromSuperview() }
        
        let margin: CGFloat = 40
        let chartMargin: CGFloat = 10
        let spacing = (rect.width - 2 * margin) / CGFloat(dataPoints.count - 1)
        
        let maxDataPoint = dataPoints.max() ?? 1
        let scale = (rect.height - 2 * margin) / maxDataPoint
        
        let path = UIBezierPath()
        let circlePath = UIBezierPath()
        
        for (index, dataPoint) in dataPoints.enumerated() {
            let x = margin + CGFloat(index) * spacing
            let y = rect.height - margin - dataPoint * scale
            
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
        
        // Рисуем метки оси X (месяцы)
        for (index, month) in months.enumerated() {
            let x = margin + CGFloat(index) * spacing
            let label = UILabel(frame: CGRect(x: x - 15, y: rect.height - margin + 5, width: 30, height: 20))
            label.text = month
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .center
            addSubview(label)
        }
        
        // Рисуем метки оси Y и линии сетки (количество задач)
        let yAxisLabelCount = 6
        for i in 0..<yAxisLabelCount {
            let y = rect.height - margin - (CGFloat(i) * (rect.height - 2 * margin) / CGFloat(yAxisLabelCount - 1))
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
        
        // Рисуем рамку вокруг области графика
        let borderPath = UIBezierPath(rect: CGRect(x: margin, y: chartMargin, width: rect.width - 2 * margin, height: rect.height - margin - chartMargin))
        UIColor.orange.setStroke()
        borderPath.lineWidth = 1
        borderPath.stroke()
    }
}
