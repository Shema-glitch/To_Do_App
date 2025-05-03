import SwiftUI

struct AddTaskView: View {
    let categories: [TaskCategory]
    var onAdd: (TodoTask) -> Void
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
                let newTask = TodoTask(title: title, date: date, category: selectedCategory, isDone: false, priority: selectedPriority, note: note.isEmpty ? nil : note, hasReminder: hasReminder, recurrence: recurrence)
                onAdd(newTask)
                presentationMode.wrappedValue.dismiss()
            }.disabled(title.isEmpty))
        }
    }
}
