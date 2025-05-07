
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search tasks...", text: $text)
                    .onChange(of: text) { _ in
                        isSearching = !text.isEmpty
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct GlobalSearchResultsView: View {
    let tasks: [TodoTask]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(tasks) { task in
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.headline)
                        Text(task.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let note = task.note {
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }
            }
        }
    }
}
