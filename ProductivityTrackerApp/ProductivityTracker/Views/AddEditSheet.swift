import SwiftUI

struct AddEditSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddEditViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    HStack {
                        Text("Hour")
                        Spacer()
                        Text(String(format: "%02d:00", viewModel.hour))
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Category", selection: $viewModel.selectedCategoryId) {
                        ForEach(viewModel.categories) { category in
                            HStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex))
                                    .frame(width: 10, height: 10)
                                Text(category.name)
                            }.tag(category.id)
                        }
                    }
                }
                
                Section(header: Text("Productivity Score: \(Int(viewModel.score))")) {
                    Slider(value: $viewModel.score, in: 0...100, step: 1)
                        .accentColor(scoreColor(viewModel.score))
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $viewModel.notes)
                        .frame(height: 100)
                }
                
                Section(header: Text("Tags (comma separated)")) {
                    TextField("exercise, reading, coding...", text: $viewModel.tags)
                }
            }
            .navigationTitle(viewModel.existingEntry != nil ? "Edit Hour" : "Add Hour")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    viewModel.save()
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.bold)
            )
        }
    }
    
    func scoreColor(_ score: Double) -> Color {
        if score < 30 { return .red }
        if score < 70 { return .yellow }
        return .green
    }
}
