import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var currentDate: Date = Date()
    @Published var hourlyMap: [Int: Entry] = [:] // Hour (0-23) to Entry
    
    @Published var totalProductiveHours: Int = 0
    @Published var averageScore: Int = 0
    @Published var mostUsedCategory: Category?
    
    private var allCategories: [Category] = []
    
    init() {
        loadData()
    }
    
    func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) {
            currentDate = newDate
            loadData()
        }
        SharedData.shared.dataDidChange()
    }
    
    func loadData() {
        allCategories = CategoryRepository.shared.fetchAll()
        
        let entries = EntryRepository.shared.fetchEntries(for: currentDate.dbFormat)
        
        var newHourlyMap: [Int: Entry] = [:]
        for entry in entries {
            newHourlyMap[entry.hour] = entry
        }
        self.hourlyMap = newHourlyMap
        
        calculateStats(from: entries)
    }
    
    private func calculateStats(from entries: [Entry]) {
        self.totalProductiveHours = entries.count
        
        let totalScore = entries.reduce(0) { $0 + $1.score }
        self.averageScore = entries.isEmpty ? 0 : totalScore / entries.count
        
        var categoryCounts: [String: Int] = [:]
        for entry in entries {
            categoryCounts[entry.categoryId, default: 0] += 1
        }
        
        if let mostUsedId = categoryCounts.max(by: { $0.value < $1.value })?.key {
            self.mostUsedCategory = allCategories.first(where: { $0.id == mostUsedId })
        } else {
            self.mostUsedCategory = nil
        }
    }
    
    func getCategory(for id: String) -> Category? {
        return allCategories.first(where: { $0.id == id })
    }
}
