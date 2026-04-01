import Foundation

struct Entry: Identifiable, Hashable {
    let id: String
    var date: String // Format: YYYY-MM-DD
    var hour: Int // 0-23
    var score: Int // 0-100
    var categoryId: String // Links to Category.id
    var notes: String
    var tags: String // comma separated tags
    let createdAt: Date
    
    init(id: String = UUID().uuidString, date: String, hour: Int, score: Int, categoryId: String, notes: String, tags: String = "", createdAt: Date = Date()) {
        self.id = id
        self.date = date
        self.hour = hour
        self.score = score
        self.categoryId = categoryId
        self.notes = notes
        self.tags = tags
        self.createdAt = createdAt
    }
}
