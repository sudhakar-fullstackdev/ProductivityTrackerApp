import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @ObservedObject private var sharedData = SharedData.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    HStack {
                        AnalyticsCard(title: "Weekly Ave Score", value: "\(viewModel.weeklyAverage)", color: .blue)
                        AnalyticsCard(title: "Longest Streak", value: "\(viewModel.longestStreak) Days", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Category Breakdown")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        if viewModel.categoryBreakdown.isEmpty {
                            Text("No data available.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(viewModel.categoryBreakdown, id: \.category.id) { item in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: item.category.colorHex))
                                        .frame(width: 12, height: 12)
                                    Text(item.category.name)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(item.count) hours")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
        .onAppear {
            viewModel.loadData()
        }
        .onReceive(sharedData.$dateChangedToggle) { _ in
            viewModel.loadData()
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}
