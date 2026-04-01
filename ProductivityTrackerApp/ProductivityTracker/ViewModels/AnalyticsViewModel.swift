import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var allEntries: [Entry] = []
    @Published var categories: [Category] = []
    
    // Processed stats
    @Published var weeklyAverage: Int = 0
    @Published var dailyAveragesForChart: [(date: String, score: Int)] = []
    @Published var categoryBreakdown: [(category: Category, count: Int)] = []
    @Published var longestStreak: Int = 0
    
    init() {
        loadData()
    }
    
    func loadData() {
        let entries = EntryRepository.shared.fetchAll()
        self.allEntries = entries
        self.categories = CategoryRepository.shared.fetchAll()
        
        processStats()
    }
    
    private func processStats() {
        // Last 7 days average
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        let lastWeekEntries = allEntries.filter { entry in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: entry.date) {
                return date >= oneWeekAgo
            }
            return false
        }
        
        let sum = lastWeekEntries.reduce(0) { $0 + $1.score }
        self.weeklyAverage = lastWeekEntries.isEmpty ? 0 : sum / lastWeekEntries.count
        
        // Detailed daily average for last 7 days chart
        var daysAccumulator: [String: (total: Int, count: Int)] = [:]
        for i in (0..<7).reversed() {
            let d = calendar.date(byAdding: .day, value: -i, to: Date())!
            daysAccumulator[d.dbFormat] = (0, 0)
        }
        
        for entry in lastWeekEntries {
            if var current = daysAccumulator[entry.date] {
                current.total += entry.score
                current.count += 1
                daysAccumulator[entry.date] = current
            }
        }
        
        self.dailyAveragesForChart = daysAccumulator.map { (date, stats) in
            let avg = stats.count > 0 ? stats.total / stats.count : 0
            return (date: date, score: avg)
        }.sorted(by: { $0.date < $1.date })
        
        // Category Breakdown
        var catCounts: [String: Int] = [:]
        for e in allEntries {
            catCounts[e.categoryId, default: 0] += 1
        }
        
        self.categoryBreakdown = catCounts.compactMap { (id, count) in
            if let cat = self.categories.first(where: { $0.id == id }) {
                return (cat, count)
            }
            return nil
        }.sorted(by: { $0.count > $1.count })
        
        // Basic streak tracking: consecutive days with > 0 productive hours
        var currentStreak = 0
        var maxStreak = 0
        var lastDate: Date? = nil
        
        let uniqueDates = Set(allEntries.map { $0.date }).sorted(by: >)
        // Check sequentially from newest to oldest
        for dateStr in uniqueDates {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: dateStr) else { continue }
            
            if let last = lastDate {
                let diff = calendar.dateComponents([.day], from: date, to: last).day ?? 0
                if diff == 1 {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            lastDate = date
            maxStreak = max(maxStreak, currentStreak)
        }
        self.longestStreak = maxStreak
    }
}
