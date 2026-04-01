import Foundation
import SQLite3

class CategoryRepository {
    static let shared = CategoryRepository()
    private let db = SQLiteDatabase.shared.db
    
    private init() {
        if fetchAll().isEmpty {
            insert(Category(name: "Work", colorHex: "#3498db"))
            insert(Category(name: "Study", colorHex: "#9b59b6"))
            insert(Category(name: "Break", colorHex: "#f1c40f"))
            insert(Category(name: "Exercise", colorHex: "#e74c3c"))
            insert(Category(name: "Other", colorHex: "#95a5a6"))
        }
    }
    
    func insert(_ category: Category) {
        let insertStatementString = "INSERT INTO categories (id, name, color) VALUES (?, ?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (category.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (category.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (category.colorHex as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func fetchAll() -> [Category] {
        let queryStatementString = "SELECT id, name, color FROM categories;"
        var queryStatement: OpaquePointer?
        var categories: [Category] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let colorHex = String(cString: sqlite3_column_text(queryStatement, 2))
                
                categories.append(Category(id: id, name: name, colorHex: colorHex))
            }
        }
        sqlite3_finalize(queryStatement)
        return categories
    }
    
    func fetch(by id: String) -> Category? {
        let queryStatementString = "SELECT name, color FROM categories WHERE id = ?;"
        var queryStatement: OpaquePointer?
        var category: Category?
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (id as NSString).utf8String, -1, nil)
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(queryStatement, 0))
                let colorHex = String(cString: sqlite3_column_text(queryStatement, 1))
                category = Category(id: id, name: name, colorHex: colorHex)
            }
        }
        sqlite3_finalize(queryStatement)
        return category
    }
}
