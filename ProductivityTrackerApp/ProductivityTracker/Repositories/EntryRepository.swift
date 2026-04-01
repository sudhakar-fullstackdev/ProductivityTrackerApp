import Foundation
import SQLite3

class EntryRepository {
    static let shared = EntryRepository()
    private let db = SQLiteDatabase.shared.db
    
    private init() {}
    
    func insertOrUpdate(_ entry: Entry) {
        let insertStatementString = """
        INSERT INTO entries (id, date, hour, score, category_id, notes, tags, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(date, hour) DO UPDATE SET
            score = excluded.score,
            category_id = excluded.category_id,
            notes = excluded.notes,
            tags = excluded.tags;
        """
        
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (entry.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (entry.date as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 3, Int32(entry.hour))
            sqlite3_bind_int(insertStatement, 4, Int32(entry.score))
            sqlite3_bind_text(insertStatement, 5, (entry.categoryId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, (entry.notes as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (entry.tags as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 8, entry.createdAt.timeIntervalSince1970)
            
            if sqlite3_step(insertStatement) != SQLITE_DONE {
                print("Could not insert/update entry.")
            }
        } else {
            print("INSERT/UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func fetchEntries(for date: String) -> [Entry] {
        let queryStatementString = "SELECT id, hour, score, category_id, notes, tags, created_at FROM entries WHERE date = ? ORDER BY hour ASC;"
        var queryStatement: OpaquePointer?
        var entries: [Entry] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, (date as NSString).utf8String, -1, nil)
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let hour = Int(sqlite3_column_int(queryStatement, 1))
                let score = Int(sqlite3_column_int(queryStatement, 2))
                let categoryId = String(cString: sqlite3_column_text(queryStatement, 3))
                let notes = String(cString: sqlite3_column_text(queryStatement, 4))
                let tags = String(cString: sqlite3_column_text(queryStatement, 5))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 6))
                
                entries.append(Entry(id: id, date: date, hour: hour, score: score, categoryId: categoryId, notes: notes, tags: tags, createdAt: createdAt))
            }
        }
        sqlite3_finalize(queryStatement)
        return entries
    }
    
    func fetchAll() -> [Entry] {
        let queryStatementString = "SELECT id, date, hour, score, category_id, notes, tags, created_at FROM entries ORDER BY date DESC, hour DESC;"
        var queryStatement: OpaquePointer?
        var entries: [Entry] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(queryStatement, 0))
                let date = String(cString: sqlite3_column_text(queryStatement, 1))
                let hour = Int(sqlite3_column_int(queryStatement, 2))
                let score = Int(sqlite3_column_int(queryStatement, 3))
                let categoryId = String(cString: sqlite3_column_text(queryStatement, 4))
                let notes = String(cString: sqlite3_column_text(queryStatement, 5))
                let tags = String(cString: sqlite3_column_text(queryStatement, 6))
                let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(queryStatement, 7))
                
                entries.append(Entry(id: id, date: date, hour: hour, score: score, categoryId: categoryId, notes: notes, tags: tags, createdAt: createdAt))
            }
        }
        sqlite3_finalize(queryStatement)
        return entries
    }
}
