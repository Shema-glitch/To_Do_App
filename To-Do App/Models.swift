
import SwiftUI

struct TaskCategory: Identifiable, Codable {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var taskCount: Int
    var completedCount: Int
    
    var displayColor: Color {
        Color(hex: color) ?? .blue
    }
    
    init(id: UUID = UUID(), name: String, icon: String, color: String, taskCount: Int = 0, completedCount: Int = 0) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.taskCount = taskCount
        self.completedCount = completedCount
    }
}

struct TodoTask: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var date: Date
    var category: String
    var isDone: Bool
    var priority: TaskPriority
    var note: String?
    var hasReminder: Bool
    var recurrence: TaskRecurrence
    
    init(id: UUID = UUID(), title: String, date: Date, category: String, isDone: Bool = false, priority: TaskPriority, note: String? = nil, hasReminder: Bool = false, recurrence: TaskRecurrence = .none) {
        self.id = id
        self.title = title
        self.date = date
        self.category = category
        self.isDone = isDone
        self.priority = priority
        self.note = note
        self.hasReminder = hasReminder
        self.recurrence = recurrence
    }
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    var id: String { self.rawValue }
}

enum TaskRecurrence: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    var id: String { self.rawValue }
}

// Color extension for hex support
extension Color {
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") {
            str.remove(at: str.startIndex)
        }
        
        if str.count != 6 {
            return nil
        }
        
        var rgb: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02X%02X%02X",
                     Int(r * 255),
                     Int(g * 255),
                     Int(b * 255))
    }
}
