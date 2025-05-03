//
//  ContentView.swift
//  To-Do App
//
//  Created by Shema Charmant on 5/2/25.
//

import SwiftUI
import UserNotifications
import Foundation

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

struct Task: Identifiable {
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

struct ContentView: View {
    @State private var categories = [
        TaskCategory(name: "Work", icon: "briefcase.fill", color: .orange, taskCount: 14, completedCount: 7),
        TaskCategory(name: "Music", icon: "music.note", color: .purple, taskCount: 6, completedCount: 2),
        TaskCategory(name: "Travel", icon: "airplane", color: .green, taskCount: 7, completedCount: 3),
        TaskCategory(name: "Study", icon: "book.fill", color: .indigo, taskCount: 2, completedCount: 1),
        TaskCategory(name: "Home", icon: "house.fill", color: .red, taskCount: 14, completedCount: 10)
    ]
    @State private var tasks: [Task] = [
        Task(title: "Call Max", date: Date().addingTimeInterval(-3600), category: "Work", isDone: false, priority: .high, note: "Discuss project"),
        Task(title: "Practice piano", date: Date(), category: "Music", isDone: false, priority: .medium),
        Task(title: "Learn Spanish", date: Date().addingTimeInterval(3600), category: "Study", isDone: false, priority: .low),
        Task(title: "Finalize presentation", date: Date().addingTimeInterval(-7200), category: "Work", isDone: true, priority: .high)
    ]
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showAddTask = false
    @State private var showCalendar = false
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = "folder.fill"
    let availableIcons = ["briefcase.fill", "music.note", "airplane", "book.fill", "house.fill", "cart.fill", "star.fill", "heart.fill", "folder.fill"]
    @State private var quote: String = ""
    let quotes = [
        "The secret of getting ahead is getting started.",
        "Don't watch the clock; do what it does. Keep going.",
        "It always seems impossible until it's done.",
        "Success is the sum of small efforts, repeated day in and day out.",
        "The future depends on what you do today.",
        "You don't have to be great to start, but you have to start to be great."
    ]

    var totalTasks: Int { tasks.count }
    var completedTasks: Int { tasks.filter { $0.isDone }.count }

    init() {
        // Request notification permissions on app launch
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("DEBUG: Notification permission error: \(error.localizedDescription)")
            } else {
                print("DEBUG: Notification permission granted: \(granted)")
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Motivational quote
                VStack(alignment: .leading, spacing: 8) {
                    Text(quote)
                        .font(.title3)
                        .italic()
                        .foregroundColor(.blue)
                        .padding(.top, 16)
                        .padding(.horizontal)
                    HStack {
                        Text("Completed: \(completedTasks)/\(totalTasks) tasks")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                HStack {
                    Text("Lists")
                        .font(.largeTitle).bold()
                        .padding(.top, 32)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        showCalendar = true
                        print("DEBUG: Calendar opened")
                    }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .padding(.top, 32)
                            .padding(.trailing)
                    }
                }
                // Add Category Button
                HStack {
                    Spacer()
                    Button(action: {
                        showAddCategory = true
                    }) {
                        Label("Add Category", systemImage: "plus.app")
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.trailing)
                }
                // Category grid with swipe to delete
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(categories) { category in
                        Button(action: {
                            print("DEBUG: Selected category \(category.name)")
                            selectedCategory = category
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 28))
                                    .foregroundColor(category.color)
                                    .padding(16)
                                    .background(category.color.opacity(0.1))
                                    .clipShape(Circle())
                                Text(category.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(category.taskCount) Tasks")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                ProgressView(value: Float(category.completedCount) / Float(max(category.taskCount, 1)))
                                    .accentColor(category.color)
                                    .frame(height: 6)
                                    .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                if let idx = categories.firstIndex(where: { $0.id == category.id }) {
                                    print("DEBUG: Deleted category \(category.name)")
                                    categories.remove(at: idx)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("DEBUG: Add new task tapped")
                        showAddTask = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(item: $selectedCategory) { category in
                TaskListView(category: category, tasks: $tasks)
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(categories: categories, onAdd: { newTask in
                    print("DEBUG: Added task \(newTask.title) in category \(newTask.category)")
                    tasks.append(newTask)
                    if newTask.hasReminder {
                        scheduleNotification(for: newTask)
                    }
                })
            }
            .sheet(isPresented: $showCalendar) {
                CalendarTaskView(tasks: tasks)
            }
            .sheet(isPresented: $showAddCategory) {
                NavigationView {
                    Form {
                        Section(header: Text("Category Name")) {
                            TextField("Enter name", text: $newCategoryName)
                        }
                        Section(header: Text("Icon")) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(availableIcons, id: \.self) { icon in
                                        Button(action: { newCategoryIcon = icon }) {
                                            Image(systemName: icon)
                                                .font(.title2)
                                                .padding(8)
                                                .background(newCategoryIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarTitle("New Category", displayMode: .inline)
                    .navigationBarItems(leading: Button("Cancel") {
                        showAddCategory = false
                        newCategoryName = ""
                        newCategoryIcon = "folder.fill"
                    }, trailing: Button("Add") {
                        let newCat = TaskCategory(name: newCategoryName, icon: newCategoryIcon, color: .blue, taskCount: 0, completedCount: 0)
                        categories.append(newCat)
                        print("DEBUG: Added category \(newCategoryName)")
                        showAddCategory = false
                        newCategoryName = ""
                        newCategoryIcon = "folder.fill"
                    }.disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty))
                }
            }
            .onAppear {
                quote = quotes.randomElement() ?? "Stay productive!"
            }
        }
    }

    func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(task.title)"
        content.body = task.note ?? "You have a task due."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger: UNCalendarNotificationTrigger
        
        switch task.recurrence {
        case .daily:
            let dailyComponents = DateComponents(hour: triggerDate.hour, minute: triggerDate.minute)
            trigger = UNCalendarNotificationTrigger(dateMatching: dailyComponents, repeats: true)
        case .weekly:
            let weeklyComponents = DateComponents(hour:
            triggerDate.hour,
            minute: triggerDate.minute,
            weekday: triggerDate.weekday)
            trigger = UNCalendarNotificationTrigger(dateMatching: weeklyComponents, repeats: true)
        case .monthly:
            let monthlyComponents = DateComponents(day: triggerDate.day, hour: triggerDate.hour, minute: triggerDate.minute)
            trigger = UNCalendarNotificationTrigger(dateMatching: monthlyComponents, repeats: true)
        default:
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("DEBUG: Notification scheduled for \(task.title) at \(task.date) [recurrence: \(task.recurrence.rawValue)]")
            }
        }
    }
}

struct TaskListView: View {
    let category: TaskCategory
    @Binding var tasks: [Task]
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var filter: TaskFilter = .all

    enum TaskFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        var id: String { self.rawValue }
    }

    var filteredTasks: [Task] {
        tasks.filter { $0.category == category.name }
            .filter { task in
                (searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText) || (task.note?.localizedCaseInsensitiveContains(searchText) ?? false))
            }
            .filter { task in
                switch filter {
                case .all: return true
                case .active: return !task.isDone
                case .completed: return task.isDone
                }
            }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(.trailing, 8)
                }
                Text(category.name)
                    .font(.largeTitle).bold()
                Spacer()
            }
            .padding()
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search tasks...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding([.horizontal, .bottom])
            // Filter segmented control
            Picker("Filter", selection: $filter) {
                ForEach(TaskFilter.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal, .bottom])
            List {
                ForEach(filteredTasks) { task in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.headline)
                            if let note = task.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(task.date, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            if task.recurrence != .none {
                                Text("Repeats: \(task.recurrence.rawValue)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        Spacer()
                        Text(task.priority.rawValue)
                            .font(.caption)
                            .padding(6)
                            .background(priorityColor(task.priority).opacity(0.15))
                            .foregroundColor(priorityColor(task.priority))
                            .cornerRadius(8)
                        if task.isDone {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                            tasks[idx].isDone.toggle()
                            print("DEBUG: Toggled done for \(task.title)")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                                tasks[idx].isDone.toggle()
                                print("DEBUG: Swipe complete toggled for \(task.title)")
                            }
                        } label: {
                            Label(task.isDone ? "Uncomplete" : "Complete", systemImage: task.isDone ? "arrow.uturn.left" : "checkmark")
                        }
                        .tint(task.isDone ? .gray : .green)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                                print("DEBUG: Deleted task \(task.title)")
                                tasks.remove(at: idx)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

struct AddTaskView: View {
    let categories: [TaskCategory]
    var onAdd: (Task) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var date = Date()
    @State private var note = ""
    @State private var selectedCategory: String = "Work"
    @State private var selectedPriority: TaskPriority = .medium
    @State private var hasReminder = false
    @State private var recurrence: TaskRecurrence = .none

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    TextField("What are you planning?", text: $title)
                }
                Section(header: Text("Date & Time")) {
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                    Toggle("Set Reminder", isOn: $hasReminder)
                }
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories) { cat in
                            Text(cat.name).tag(cat.name)
                        }
                    }
                }
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Recurrence")) {
                    Picker("Repeat", selection: $recurrence) {
                        ForEach(TaskRecurrence.allCases) { r in
                            Text(r.rawValue).tag(r)
                        }
                    }
                }
                Section(header: Text("Note")) {
                    TextField("Add note", text: $note)
                }
            }
            .navigationBarTitle("New Task", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Create") {
                let newTask = Task(title: title, date: date, category: selectedCategory, isDone: false, priority: selectedPriority, note: note.isEmpty ? nil : note, hasReminder: hasReminder, recurrence: recurrence)
                onAdd(newTask)
                presentationMode.wrappedValue.dismiss()
            }.disabled(title.isEmpty))
        }
    }
}

struct CalendarTaskView: View {
    let tasks: [Task]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()

    var tasksForSelectedDate: [Task] {
        let calendar = Calendar.current
        return tasks.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .onChange(of: selectedDate) { newDate in
                        print("DEBUG: Selected date \(newDate)")
                    }
                List {
                    if tasksForSelectedDate.isEmpty {
                        Text("No tasks for this date.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(tasksForSelectedDate) { task in
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.headline)
                                if let note = task.note, !note.isEmpty {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Text(task.date, style: .time)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                if task.recurrence != .none {
                                    Text("Repeats: \(task.recurrence.rawValue)")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Calendar", displayMode: .inline)
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
