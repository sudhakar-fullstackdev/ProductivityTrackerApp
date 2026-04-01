import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedHour: Int = 0
    @State private var selectedEntry: Entry?
    @State private var showingAddEditSheet = false
    
    @ObservedObject private var sharedData = SharedData.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Date Navigation
                    HStack {
                        Button(action: { viewModel.changeDate(by: -1) }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title2)
                        }
                        
                        Text(viewModel.currentDate.displayFormat)
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                        
                        Button(action: { viewModel.changeDate(by: 1) }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Summary Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Summary")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Productive Hours")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.totalProductiveHours)h")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Avg Score")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.averageScore)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(scoreColor(viewModel.averageScore))
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Top Category")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(viewModel.mostUsedCategory?.name ?? "None")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: viewModel.mostUsedCategory?.colorHex ?? "#808080"))
                            }
                        }
                        
                        ProgressBarView(progress: Double(viewModel.totalProductiveHours) / 24.0, color: .blue)
                            .frame(height: 12)
                            .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Timeline
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<24) { hour in
                            let entry = viewModel.hourlyMap[hour]
                            let category = entry != nil ? viewModel.getCategory(for: entry!.categoryId) : nil
                            
                            TimelineHourView(
                                hour: hour,
                                entry: entry,
                                category: category,
                                onAddEdit: {
                                    self.selectedHour = hour
                                    self.selectedEntry = entry
                                    self.showingAddEditSheet = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showingAddEditSheet) {
                AddEditSheet(viewModel: AddEditViewModel(
                    date: viewModel.currentDate,
                    hour: selectedHour,
                    existingEntry: selectedEntry
                ))
            }
        }
        .onReceive(sharedData.$dateChangedToggle) { _ in
            viewModel.loadData()
        }
    }
    
    func scoreColor(_ score: Int) -> Color {
        if score < 30 { return .red }
        if score < 70 { return .yellow }
        return .green
    }
}
