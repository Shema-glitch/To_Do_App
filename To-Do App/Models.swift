import SwiftUI

struct TaskCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    var taskCount: Int
    var completedCount: Int
}

enum TaskPriority: String, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    var id: String { self.rawValue }
}

enum TaskRecurrence: String, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    var id: String { self.rawValue }
}

struct TodoTask: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let category: String
    var isDone: Bool = false
    var priority: TaskPriority
    var note: String? = nil
    var hasReminder: Bool = false
    var recurrence: TaskRecurrence = .none
}