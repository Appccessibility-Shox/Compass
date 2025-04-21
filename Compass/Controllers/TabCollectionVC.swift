import UIKit

final class TabCollectionVC: UICollectionViewController {
    
    // MARK: - Dependencies
    
    var vm = TabCollectionVM()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        collectionView.backgroundColor = .lightGray
    }
}


