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
        
        // TODO: Don't hard code frame. Use `sizeForItemAt`.
        tabSnapshotCell.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        tabSnapshotCell.title = relevantTab.title
        
        return tabSnapshotCell
    }
}
