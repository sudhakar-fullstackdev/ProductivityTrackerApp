import Foundation
import Combine

class SharedData: ObservableObject {
    static let shared = SharedData()
    @Published var dateChangedToggle: Bool = false
    
    func dataDidChange() {
        dateChangedToggle.toggle()
    }
}
