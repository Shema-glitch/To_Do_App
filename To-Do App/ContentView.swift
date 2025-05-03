import SwiftUI
import UserNotifications

struct ContentView: View {
    // MARK: - State
    @State private var categories = [
        TaskCategory(name: "Work", icon: "briefcase.fill", color: .orange, taskCount: 14, completedCount: 7),
        TaskCategory(name: "Music", icon: "music.note", color: .purple, taskCount: 6, completedCount: 2),
        TaskCategory(name: "Travel", icon: "airplane", color: .green, taskCount: 7, completedCount: 3),
        TaskCategory(name: "Study", icon: "book.fill", color: .indigo, taskCount: 2, completedCount: 1),
        TaskCategory(name: "Home", icon: "house.fill", color: .red, taskCount: 14, completedCount: 10)
    ]
    
    @State private var tasks: [TodoTask] = [
        TodoTask(title: "Call Max", date: Date().addingTimeInterval(-3600), category: "Work", isDone: false, priority: .high, note: "Discuss project"),
        TodoTask(title: "Practice piano", date: Date(), category: "Music", isDone: false, priority: .medium),
        TodoTask(title: "Learn Spanish", date: Date().addingTimeInterval(3600), category: "Study", isDone: false, priority: .low)
    ]
    
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showAddTask = false
    @State private var showCalendar = false
    @State private var showAddCategory = false
    
    // MARK: - Constants
    private let quotes = [
        "The secret of getting ahead is getting started.",
        "Don't watch the clock; do what it does. Keep going.",
        "It always seems impossible until it's done.",
        "Success is the sum of small efforts, repeated day in and day out.",
        "The future depends on what you do today.",
        "You don't have to be great to start, but you have to start to be great."
    ]
    
    // MARK: - Computed Properties
    private var totalTasks: Int { tasks.count }
    private var completedTasks: Int { tasks.filter { $0.isDone }.count }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) { // Added ZStack for floating button
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Quote View
                            RollingQuoteView(quotes: quotes)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            
                            // Header with Stats
                            HStack {
                                Text("Lists")
                                    .font(.largeTitle).bold()
                                Spacer()
                                Button(action: { showCalendar = true }) {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Stats and Add Category Button
                            HStack {
                                Text("Completed: \(completedTasks)/\(totalTasks) tasks")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(8)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                Button(action: { showAddCategory = true }) {
                                    Label("Add Category", systemImage: "plus.app")
                                        .font(.subheadline)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Responsive Grid
                            let adaptiveColumns = [
                                GridItem(.adaptive(minimum: 150, maximum: 250), spacing: 20)
                            ]
                            LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                                ForEach(categories) { category in
                                    CategoryCard(category: category) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding()
                            
                            // Add bottom padding for FAB
                            Spacer()
                                .frame(height: 80)
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                    .background(Color(.systemGroupedBackground))
                }
                
                // Floating Action Button
                Button(action: { showAddTask = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(24)
            }
            .sheet(item: $selectedCategory) { category in
                TaskListView(category: category, tasks: $tasks)
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(categories: categories, onAdd: { newTask in
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
                AddCategoryView(categories: $categories)
            }
        }
    }
    
    // MARK: - Notifications
    private func scheduleNotification(for task: TodoTask) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(task.title)"
        content.body = task.note ?? "You have a task due."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CategoryCard View
private struct CategoryCard: View {
    let category: TaskCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(category.color)
                    .padding(16)
                    .background(category.color.opacity(0.1))
                    .clipShape(Circle())
                Text(category.name)
                    .font(.headline)
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
    }
}

// MARK: - Preview
#Preview {
    Group {
        ContentView()
            .previewDevice("iPhone SE (3rd generation)")
        ContentView()
            .previewDevice("iPhone 15 Pro Max")
    }
}