import SwiftUI

struct AddCategoryView: View {
    @Binding var categories: [TaskCategory]
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = Color.blue
    
    private let availableIcons = [
        "briefcase.fill", "music.note", "airplane", 
        "book.fill", "house.fill", "cart.fill", 
        "star.fill", "heart.fill", "folder.fill"
    ]
    
    private let availableColors: [Color] = [
        .blue, .red, .green, .orange, 
        .purple, .pink, .yellow, .indigo
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? selectedColor : .gray)
                                    .padding(8)
                                    .background(selectedIcon == icon ? selectedColor.opacity(0.1) : Color.clear)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 2)
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationBarTitle("New Category", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Create") {
                    let newCategory = TaskCategory(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor,
                        taskCount: 0,
                        completedCount: 0
                    )
                    categories.append(newCategory)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview {
    AddCategoryView(categories: .constant([]))
}