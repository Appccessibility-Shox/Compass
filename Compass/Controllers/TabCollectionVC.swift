import UIKit

final class TabCollectionVC: UICollectionViewController {
    
    // MARK: - Dependencies
    
    var vm = TabCollectionVM()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        collectionView.backgroundColor = .lightGray
        collectionView.register(
            TabCell.self,
            forCellWithReuseIdentifier: String(describing: TabCell.self)
        )
    }
}

// MARK: - UICollectionViewDataSource

extension TabCollectionVC {
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return vm.tabs.count
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let tabSnapshotCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: TabCell.self),
            for: indexPath
        ) as! TabCell
        
        let relevantTab = vm.tabs[indexPath.item]
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

// MARK: - Constants

extension TabCollectionVC {
    
    private static let INSET_PADDING: CGFloat = 15
    
}
