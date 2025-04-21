import UIKit

final class RootNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        let tabCollectionVC = TabCollectionVC(collectionViewLayout: layout)
        self.viewControllers = [tabCollectionVC]
        setToolbarHidden(false, animated: false)
    }
    
}

