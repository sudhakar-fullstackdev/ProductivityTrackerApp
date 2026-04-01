import Foundation
import SQLite3

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

class SQLiteDatabase {
    static let shared = SQLiteDatabase()
    private let dbPointer: OpaquePointer?
    
    private init() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("ProductivityTracker.sqlite")
        
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            dbPointer = nil
        } else {
            dbPointer = db
            createTables()
        }
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    var db: OpaquePointer? {
        return dbPointer
    }
    
    private func createTables() {
        let createCategoriesTable = """
        CREATE TABLE IF NOT EXISTS categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            color TEXT NOT NULL
        );
        """
        
        let createEntriesTable = """
        CREATE TABLE IF NOT EXISTS entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            hour INTEGER NOT NULL,
            score INTEGER NOT NULL,
            category_id TEXT NOT NULL,
            notes TEXT,
            tags TEXT,
            created_at REAL NOT NULL,
            UNIQUE(date, hour)
        );
        """
        
        executeTable(statement: createCategoriesTable)
        executeTable(statement: createEntriesTable)
    }
    
    private func executeTable(statement: String) {
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, statement, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Table created successfully")
            } else {
                print("Table could not be created")
            }
        } else {
            print("CREATE TABLE statement could not be prepared")
        }
        sqlite3_finalize(createTableStatement)
    }
}
