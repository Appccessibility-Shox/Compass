import Foundation

final class TabCollectionVM {
    
    // MARK: - Dependencies
    
    let vc: TabCollectionVC
    
    // MARK: - Properties
    
    var tabs: [Tab] = [] {
        didSet {
            relayIfTabLengthIsPositiveOrZero()
        }
    }
    
    init(vc: TabCollectionVC) {
        self.vc = vc
    }
}

// MARK: - Data Manipulation Actions

extension TabCollectionVM {
    func appendNewTabToTabsArray() -> IndexPath {
        let newTab = Tab()
        tabs.append(newTab)
        
        let newTabIndexPath = IndexPath(item: tabs.count - 1, section: 0)
        return newTabIndexPath
    }
    
    func closeAllTabs() {
        tabs = [Tab]()
    }
}

// MARK: - Handers for VC-Emitted Events

extension TabCollectionVM {
    func tabCollectionVCWillAppear() {
        relayIfTabLengthIsPositiveOrZero()
    }
}

// MARK: - Helper Functions

extension TabCollectionVM {
    func relayIfTabLengthIsPositiveOrZero() {
        if tabs.count == 0 {
            vc.tabsLengthIsZero()
        } else {
            vc.tabsLengthIsPositive()
        }
    }
}
