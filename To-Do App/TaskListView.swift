import SwiftUI

struct TaskListView: View {
    let category: TaskCategory
    @Binding var tasks: [TodoTask]
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var filter: TaskFilter = .all

    enum TaskFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        var id: String { self.rawValue }
    }

    var filteredTasks: [TodoTask] {
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

            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search tasks...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding([.horizontal, .bottom])

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
                            Text(task.title).font(.headline)
                            if let note = task.note, !note.isEmpty {
                                Text(note).font(.caption).foregroundColor(.secondary)
                            }
                            Text(task.date, style: .time).font(.caption2).foregroundColor(.secondary)
                            if task.recurrence != .none {
                                Text("Repeats: \(task.recurrence.rawValue)").font(.caption2).foregroundColor(.blue)
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
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                            tasks[idx].isDone.toggle()
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
                                tasks[idx].isDone.toggle()
                            }
                        } label: {
                            Label(task.isDone ? "Uncomplete" : "Complete", systemImage: task.isDone ? "arrow.uturn.left" : "checkmark")
                        }.tint(task.isDone ? .gray : .green)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
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
