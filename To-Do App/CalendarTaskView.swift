
import SwiftUI

struct CalendarTaskView: View {
    let tasks: [TodoTask]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()

    var tasksForSelectedDate: [TodoTask] {
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
