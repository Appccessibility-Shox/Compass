import UIKit

final class TabCollectionVC: UICollectionViewController {
    
    // MARK: - Dependencies
    
    var vm: TabCollectionVM!
    
    // MARK: - UI Components
    
    var createNewTabButton: UIBarButtonItem!
    var closeAllTabsButton: UIBarButtonItem!
    var filterTabsSearchBar: UISearchBar!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        collectionView.backgroundColor = .lightGray
        collectionView.register(
            TabCell.self,
            forCellWithReuseIdentifier: String(describing: TabCell.self)
        )
        
        createNewTabButton = UIBarButtonItem(
            image: TabCollectionVC.CREATE_NEW_TAB_BUTTON_IMAGE,
            style: .plain,
            target: self,
            action: #selector(createNewTabButtonPressed)
        )
        
        closeAllTabsButton = UIBarButtonItem(
            title: TabCollectionVC.CLOSE_ALL_TABS_BUTTON_TEXT,
            style: .plain,
            target: self,
            action: #selector(closeAllTabsButtonPressed)
        )
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        toolbarItems = [
            closeAllTabsButton,
            spacer,
            createNewTabButton
        ]
        
        filterTabsSearchBar = UISearchBar()
        filterTabsSearchBar.placeholder = TabCollectionVC.FILTER_TABS_SEARCH_BAR_PLACEHOLDER
        navigationItem.titleView = filterTabsSearchBar
        filterTabsSearchBar.delegate = vm
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.tabCollectionVCWillAppear()
    }
    
    // MARK: - Init
    
    override init(collectionViewLayout: UICollectionViewLayout) {
        super.init(collectionViewLayout: collectionViewLayout)
        vm = TabCollectionVM(vc: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource

extension TabCollectionVC {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return vm.filteredTabs.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let tabSnapshotCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: TabCell.self),
            for: indexPath
        ) as! TabCell
        
        let relevantTab = vm.filteredTabs[indexPath.item]
        tabSnapshotCell.title = relevantTab.title
        
        return tabSnapshotCell
    }
}

// MARK: - Flow Layout

extension TabCollectionVC: UICollectionViewDelegateFlowLayout {
    
    /// A utility function which defines how many cells we want to appear per row in the
    /// `collectionView`.
    ///
    /// This function is used in determining the size of each cell. As such, the name
    /// can't be taken completely literally. For example, if `tabCount` is 1, the function
    /// returns 1.33, so as to make the presented `TabCell` artificially smaller than
    /// it would be if we returned 1.
    ///
    /// - Parameters:
    ///   - orientation: the device orientation
    ///   - tabCount: the number of tabs in the collection view
    /// - Returns: the number of tab cells that should appear in a row for the given
    /// orientation.
    private func itemsPerRow(
        forOrientation orientation: Orientation,
        andTabCount tabCount: Int
    ) -> CGFloat {
        if (tabCount == 1) { return 1.33 }
        if (tabCount == 2) { return 2 }
        switch orientation {
        case .portrait:
            return 2
        case .landscape:
            return 3
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let orientation = collectionView.orientation
        let safeAreaWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width
        
        let rowItemCount = itemsPerRow(
            forOrientation: orientation,
            andTabCount: collectionView.numberOfItems(inSection: 0)
        )
        let interItemSpacing = TabCollectionVC.INSET_PADDING * CGFloat(2 * rowItemCount)
        let itemWidth = (safeAreaWidth - interItemSpacing) / rowItemCount
        
        let deviceAspectRatio = collectionView.bounds.height / collectionView.bounds.width
        let squareAspectRatio = 1.0
        let squarifiedAspectRatio = (squareAspectRatio + deviceAspectRatio) / 2
        let aspectRatio = orientation == .portrait ? squarifiedAspectRatio : deviceAspectRatio
        
        let itemHeight = itemWidth * aspectRatio
            
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt index: NSInteger
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: TabCollectionVC.INSET_PADDING,
            left: collectionView.safeAreaInsets.left + TabCollectionVC.INSET_PADDING,
            bottom: TabCollectionVC.INSET_PADDING,
            right: collectionView.safeAreaInsets.right + TabCollectionVC.INSET_PADDING
        )
    }
}

// MARK: - Size/Rotation Transitions

extension TabCollectionVC {
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.invalidateLayout()
                self.collectionView.layoutIfNeeded()
            }
        })
    }
    
}

// MARK: - Actions

extension TabCollectionVC {
    @objc func createNewTabButtonPressed() {
        let newTabIndexPath = vm.appendNewTabToTabsArray()
        collectionView.insertItems(at: [newTabIndexPath])
    }
    
    @objc func closeAllTabsButtonPressed() {
        vm.closeAllTabs()
        collectionView.reloadData()
    }
}

// MARK: - Handlers for VM-Emitted Events

extension TabCollectionVC {
    
    func tabsLengthIsZero() {
        closeAllTabsButton.isEnabled = false
    }
    
    func tabsLengthIsPositive() {
        closeAllTabsButton.isEnabled = true
    }
    
    func filterQueryTextDidChange() {
        collectionView.reloadData()
    }
    
    func filterQuerySearchBarCancelButtonClicked() {
        filterTabsSearchBar.text = ""
        filterTabsSearchBar.resignFirstResponder()
    }
}

// MARK: - Constants

extension TabCollectionVC {
    
    private static let INSET_PADDING: CGFloat = 15
    
    /// The title of the toolbar button which, when pressed, will close all opened tabs.
    private static let CLOSE_ALL_TABS_BUTTON_TEXT = "Close All"
    
    /// The 􀅼 icon which appears in the toolbar and functions to add a new tab.
    private static let CREATE_NEW_TAB_BUTTON_IMAGE = UIImage(systemName: "plus")
    
    private static let FILTER_TABS_SEARCH_BAR_PLACEHOLDER = "Search Tabs"
}
