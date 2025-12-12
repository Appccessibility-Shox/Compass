import Foundation

final class Tab: Identifiable {
    
    var id: String
    var title: String
    var url: URL?
    
    init() {
        self.id = UUID().uuidString
        self.title = Tab.DEFAULT_TITLE
    }
}

// MARK: - Equatable

extension Tab: Equatable {
    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Constants

extension Tab {
    private static let DEFAULT_TITLE = "New Tab"
}
