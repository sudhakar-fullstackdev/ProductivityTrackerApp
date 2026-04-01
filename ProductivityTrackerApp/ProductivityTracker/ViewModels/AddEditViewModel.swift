import Foundation
import Combine

class AddEditViewModel: ObservableObject {
    @Published var hour: Int
    @Published var score: Double
    @Published var notes: String
    @Published var tags: String
    @Published var selectedCategoryId: String
    @Published var categories: [Category] = []
    
    let date: Date
    let existingEntry: Entry?
    
    init(date: Date, hour: Int, existingEntry: Entry? = nil) {
        self.date = date
        self.hour = hour
        self.existingEntry = existingEntry
        
        let fetchedCategories = CategoryRepository.shared.fetchAll()
        self.categories = fetchedCategories
        
        if let entry = existingEntry {
            self.score = Double(entry.score)
            self.notes = entry.notes
            self.tags = entry.tags
            self.selectedCategoryId = entry.categoryId
        } else {
            self.score = 50
            self.notes = ""
            self.tags = ""
            self.selectedCategoryId = fetchedCategories.first?.id ?? ""
        }
    }
    
    func save() {
        let entry = Entry(
            id: existingEntry?.id ?? UUID().uuidString,
            date: date.dbFormat,
            hour: hour,
            score: Int(score),
            categoryId: selectedCategoryId,
            notes: notes,
            tags: tags
        )
        
        EntryRepository.shared.insertOrUpdate(entry)
        SharedData.shared.dataDidChange()
    }
}
