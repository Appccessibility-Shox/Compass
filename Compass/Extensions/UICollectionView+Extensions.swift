import UIKit

extension UICollectionView {
    var orientation: Orientation {
        return bounds.width > bounds.height ? .landscape : .portrait
    }
}
