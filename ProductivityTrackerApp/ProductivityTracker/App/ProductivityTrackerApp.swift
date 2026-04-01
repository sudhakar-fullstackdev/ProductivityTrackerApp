import SwiftUI

@main
struct ProductivityTrackerApp: App {
    
    init() {
        // Initialize SQLite Database schema
        _ = SQLiteDatabase.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Ensure dark mode is fully supported depending on user choice, or force it if desired
                .preferredColorScheme(.dark)
        }
    }
}
