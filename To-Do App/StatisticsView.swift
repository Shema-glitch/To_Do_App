
import SwiftUI
import Charts

struct StatisticsView: View {
    let tasks: [TodoTask]
    @State private var selectedTimeframe: Timeframe = .week
    @State private var showingDetailedStats = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var completionRate: Double {
        let total = Double(tasks.count)
        let completed = Double(tasks.filter { $0.isDone }.count)
        return total > 0 ? (completed / total) * 100 : 0
    }
    
    var tasksByPriority: [(TaskPriority, Double)] {
        let grouped = Dictionary(grouping: tasks, by: { $0.priority })
        let total = Double(tasks.count)
        return TaskPriority.allCases.map { priority in
            let count = Double(grouped[priority]?.count ?? 0)
            return (priority, total > 0 ? (count / total) * 100 : 0)
        }
    }
    
    var productivityScore: Int {
        let completedOnTime = tasks.filter { task in
            task.isDone && task.date >= Date()
        }.count
        let total = tasks.count
        return total > 0 ? (completedOnTime * 100) / total : 0
    }
    
    var mostProductiveTime: String {
        let hours = Dictionary(grouping: tasks.filter { $0.isDone }, by: { Calendar.current.component(.hour, from: $0.date) })
        if let peak = hours.max(by: { $0.value.count < $1.value.count })?.key {
            let formatter = DateFormatter()
            formatter.dateFormat = "ha"
            let date = Calendar.current.date(from: DateComponents(hour: peak)) ?? Date()
            return formatter.string(from: date)
        }
        return "N/A"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Selector
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Main Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Completion Rate",
                               value: String(format: "%.1f%%", completionRate),
                               icon: "checkmark.circle.fill",
                               color: .green)
                        
                        StatCard(title: "Productivity Score",
                               value: "\(productivityScore)",
                               icon: "chart.bar.fill",
                               color: .blue)
                        
                        StatCard(title: "Total Tasks",
                               value: "\(tasks.count)",
                               icon: "list.bullet",
                               color: .purple)
                        
                        StatCard(title: "Peak Activity",
                               value: mostProductiveTime,
                               icon: "clock.fill",
                               color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Progress Chart
                    VStack(alignment: .leading) {
                        Text("Task Completion Trend")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(getProgressData(), id: \.date) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Completed", item.completed)
                            )
                            .foregroundStyle(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            
                            AreaMark(
                                x: .value("Date", item.date),
                                y: .value("Completed", item.completed)
                            )
                            .foregroundStyle(LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        }
                        .frame(height: 200)
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)
                    
                    // Priority Distribution
                    VStack(alignment: .leading) {
                        Text("Priority Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(tasksByPriority, id: \.0) { priority, percentage in
                            BarMark(
                                x: .value("Priority", priority.rawValue.capitalized),
                                y: .value("Percentage", percentage)
                            )
                            .foregroundStyle(by: .value("Priority", priority.rawValue))
                        }
                        .frame(height: 150)
                        .padding()
                        .chartForegroundStyleScale([
                            "high": Color.red,
                            "medium": Color.orange,
                            "low": Color.green
                        ])
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    .padding(.horizontal)
                    
                    // Category Performance
                    CategoryPerformanceView(tasks: tasks)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingDetailedStats) {
                DetailedStatsView(tasks: tasks)
            }
            .toolbar {
                Button("Detailed Stats") {
                    showingDetailedStats = true
                }
            }
        }
    }
    
    private func getProgressData() -> [(date: Date, completed: Int)] {
        let calendar = Calendar.current
        let endDate = Date()
        var startDate: Date
        
        switch selectedTimeframe {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
        }
        
        return createDateRange(from: startDate, to: endDate).map { date in
            let completedCount = tasks.filter { task in
                task.isDone && calendar.isDate(task.date, inSameDayAs: date)
            }.count
            return (date: date, completed: completedCount)
        }
    }
    
    private func createDateRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct CategoryPerformanceView: View {
    let tasks: [TodoTask]
    
    var categoryStats: [(String, Int, Int)] {
        let grouped = Dictionary(grouping: tasks) { $0.category }
        return grouped.map { category, tasks in
            (category, tasks.count, tasks.filter { $0.isDone }.count)
        }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Category Performance")
                .font(.headline)
                .padding(.bottom, 8)
            
            ForEach(categoryStats, id: \.0) { category, total, completed in
                CategoryProgressRow(
                    name: category,
                    completed: completed,
                    total: total
                )
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct CategoryProgressRow: View {
    let name: String
    let completed: Int
    let total: Int
    
    var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text("\(completed)/\(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [.blue, .purple],
                                           startPoint: .leading,
                                           endPoint: .trailing))
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 6)
            .cornerRadius(3)
        }
    }
}

struct DetailedStatsView: View {
    let tasks: [TodoTask]
    
    var body: some View {
        NavigationView {
            List {
                // Add detailed statistics here
                Text("Detailed statistics coming soon")
            }
            .navigationTitle("Detailed Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
