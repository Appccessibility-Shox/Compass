import UIKit

extension UIPanGestureRecognizer {
    func cancel() {
        self.isEnabled = false
        self.isEnabled = true
    }
    
    enum GestureDirection {
        case horizontal
        case vertical
    }
    
    /// A computed property that will tell you which axis a user is generally moving in
    /// during a pan gesture.
    var gestureDirection: GestureDirection {
        let speedX = abs(self.velocity(in: self.view).x)
        let speedY = abs(self.velocity(in: self.view).y)
        
        return abs(speedY) > abs(speedX) ? .vertical : .horizontal
    }
}
