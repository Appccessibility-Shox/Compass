import Foundation
import UIKit

final class TabCollectionVM: NSObject {
    
    // MARK: - Dependencies
    
    let vc: TabCollectionVC
    
    // MARK: - Properties
    
    private var filterQuery = ""
    
    private var tabs: [Tab] = [] {
        didSet {
            relayIfTabLengthIsPositiveOrZero()
        }
    }
    
    var filteredTabs: [Tab] {
        if filterQuery.isEmpty {
            return tabs
        } else {
            return tabs.filter { $0.title.lowercased().contains(filterQuery.lowercased()) }
        }
    }
    
    init(vc: TabCollectionVC) {
        self.vc = vc
        
        let tabA = Tab()
        tabA.title = "Wikipedia"
        tabA.url = URL(string: "https://en.wikipedia.org/wiki/Main_Page")
        let tabB = Tab()
        tabB.title = "Wikimedia"
        tabB.url = URL(string: "https://www.wikimedia.org/")
        self.tabs = [tabA, tabB]
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
    
    /// Deletes a `Tab` object from the `tabs` array given an indexPath *that refers to
    /// the `filteredTabs` array*.
    func deleteTabFromTabsArray(
        atIndexPathForFilteredTabs filteredTabsArrayIndexPath: IndexPath
    ) {
        let tabToDelete = filteredTabs[filteredTabsArrayIndexPath.item]
        let indexToDelete = tabs.firstIndex(of: tabToDelete)!
        tabs.remove(at: indexToDelete)
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

// MARK: - UISearchBarDelegate

extension TabCollectionVM: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterQuery = searchText
        vc.filterQueryTextDidChange()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearchingAndReload()
    }
    
    private func endSearchingAndReload() {
        // If the query string was already empty, no need to reload the collection view.
        if filterQuery != "" {
            filterQuery = ""
            vc.filterQueryTextDidChange()
        }
        vc.filterQuerySearchBarCancelButtonClicked()
    }
}
