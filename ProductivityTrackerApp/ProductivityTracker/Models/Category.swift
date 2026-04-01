import Foundation

struct Category: Identifiable, Hashable {
    let id: String
    var name: String
    var colorHex: String
    
    init(id: String = UUID().uuidString, name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}
