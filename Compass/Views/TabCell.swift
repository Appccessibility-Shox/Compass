import UIKit

final class TabCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private lazy var snapshot: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = TabCell.STANDARD_CORNER_RADIUS
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = TabCell.BACKGROUND_COLOR
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(TabCell.CLOSE_BUTTON_IMAGE, for: .normal)
        button.tintColor = TabCell.CLOSE_BUTTON_COLOR
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Public Properties
    
    weak var delegate: TabCellDelegate?
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    // MARK: - Private Properties
    
    /// Property indicating whether this cell is currently being swiped.
    ///
    /// This is used to prevent `someCellIsSwiping` from being set to `false` by cells
    /// whose gesture was explicitly cancelled because `someCellIsSwiping` was `true`.
    /// Only the cell which was actually allowed to begin the process of swiping should
    /// be able to set the `someCellIsSwiping` class variable.
    private var isSwiping = false
    
    private var contextMenuInteraction: UIContextMenuInteraction?
    
    // MARK: - Static Variables
    
    /// A class attribute representing whether any TabCell is currently being swiped.
    ///
    /// This is used to prevents multiple cells from being swiped simultaneously.
    static var someCellIsSwiping = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
        let swipeLeftGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleGestureProgress)
        )
        self.addGestureRecognizer(swipeLeftGestureRecognizer)
        swipeLeftGestureRecognizer.delegate = self
        
        let interaction = UIContextMenuInteraction(delegate: self)
        snapshot.addInteraction(interaction)
        snapshot.isUserInteractionEnabled = true
        self.contextMenuInteraction = interaction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(snapshot)
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            snapshot.topAnchor.constraint(equalTo: contentView.topAnchor),
            snapshot.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            snapshot.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            snapshot.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 8),
            
            closeButton.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: TabCell.CLOSE_BUTTON_INSET),
            closeButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -TabCell.CLOSE_BUTTON_INSET),
            closeButton.widthAnchor.constraint(
                equalToConstant: TabCell.CLOSE_BUTTON_SIZE),
            closeButton.heightAnchor.constraint(
                equalToConstant: TabCell.CLOSE_BUTTON_SIZE)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = TabCell.SHADOW_COLOR
        layer.shadowRadius = TabCell.STANDARD_CORNER_RADIUS
        layer.shadowOpacity = TabCell.SHADOW_OPACITY
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }
}

// MARK: - Animations

extension TabCell {
    
    func flyBack() {
        UIView.animate(withDuration: TabCell.FLY_BACK_ANIMATION_DURATION, animations: {
            self.transform = .identity
        })
    }
    
    func flyLeft(
        then completionHandler: @escaping (() -> Void)
    ) {
        let distanceToGo = self.center.x + self.frame.width / 2
        let speed = TabCell.FLY_LEFT_SPEED
        
        let duration = distanceToGo/speed
        
        UIView.animate(withDuration: duration, animations: {
            self.transform = self.transform.translatedBy(x: -distanceToGo, y: 0)
        }, completion: { (finished) in
            if (finished) {
                self.alpha = 0
                completionHandler()
            }
        })
    }
    
    func slideHorizontally(byAmount translationAmount: CGFloat, withScaling scale: CGFloat) {
        UIView.animate(
            withDuration: TabCell.SLIDE_HORIZONTALLY_ANIMATION_DURATION,
            animations: {
                self.transform = .identity
                    .translatedBy(x: translationAmount, y: 0)
                    .scaledBy(x: scale, y: scale)
            }
        )
    }
    
}

// MARK: - Actions

extension TabCell {
    @objc func closeButtonTapped() {
        flyLeft(
            then: {
                self.delegate?.delete(cell: self)
            }
        )
    }
}

// MARK: - Gestures

extension TabCell {
    
    @objc func handleGestureProgress(sender: UIPanGestureRecognizer) {
        self.layer.zPosition = 1
        
        let translationX = sender.translation(in: self).x
        let translationLeft = -translationX
        let speedX = sender.velocity(in: self).x
        let speedLeft = -speedX
        
        switch sender.state {
        case .began:
            if (TabCell.someCellIsSwiping || sender.gestureDirection == .vertical) {
                sender.cancel()
            } else {
                TabCell.someCellIsSwiping = true
                self.isSwiping = true
            }
            delegate?.someTabCellIsBeingSwiped(isSwiping: TabCell.someCellIsSwiping)
        case .changed:
            let movingLeft = translationX < 0
            let undampenedOffset = translationX
            let dampenedOffset = translationX / TabCell.DIRECTIONAL_DAMPENING_FACTOR
            let directionallyDampenedOffset = movingLeft ? undampenedOffset : dampenedOffset
            slideHorizontally(
                byAmount: directionallyDampenedOffset,
                withScaling: TabCell.SLIDE_HORIZONTALLY_ANIMATION_DRAGGING_SCALE
            )
        case .ended, .cancelled:
            self.layer.zPosition = 0
            if (self.isSwiping == true) {
                TabCell.someCellIsSwiping = false
                self.isSwiping = false
            }
            
            if (
                translationLeft < TabCell.MINIMUM_LEFT_DISPLACEMENT_FOR_DELETION &&
                speedLeft < TabCell.MINIMUM_LEFT_SPEED_FOR_DELETION
            ) {
                flyBack()
            } else {
                // The tab was dragged sufficiently fast and/or sufficiently far and
                // should, therefore, be deleted.
                flyLeft(
                    then: {
                        self.delegate?.delete(cell: self)
                    }
                )
            }
            delegate?.someTabCellIsBeingSwiped(isSwiping: TabCell.someCellIsSwiping)
        default:
            break
        }
    }
    
}

extension TabCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

extension TabCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let delegate = self.delegate else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            var actions: [UIAction] = []

            // Copy URL action
            if delegate.canCopyURL(cell: self) {
                let copyURL = UIAction(
                    title: TabCell.COPY_URL_CONTEXT_MENU_ACTION_TITLE,
                    image: UIImage(systemName: "doc.on.clipboard")
                ) { _ in
                    delegate.copyURL(cell: self)
                }
                actions.append(copyURL)
            }

            // Close tab action
            let close = UIAction(
                title: TabCell.CLOSE_CONTEXT_MENU_ACTION_TITLE,
                image: UIImage(systemName: "xmark"),
                attributes: .destructive
            ) { _ in
                self.flyLeft(then: { self.delegate?.delete(cell: self) })
            }
            actions.append(close)

            return UIMenu(children: actions)
        }
    }
}

// MARK: - Constants

extension TabCell {
    
    static let STANDARD_CORNER_RADIUS: CGFloat = 16
    
    /// The background color for the TabCell which is visible when a snapshot does
    /// not exist.
    static let BACKGROUND_COLOR = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    
    /// The color of the shadow which appears behind the TabCell
    static let SHADOW_COLOR = UIColor.gray.cgColor
    
    /// The opacity of the shadow which appears behind the TabCell
    static let SHADOW_OPACITY: Float = 0.1
    
    /// The width and height of the close button, which appears in the top right corner
    /// of each ``TabCell``.
    private static let CLOSE_BUTTON_SIZE: CGFloat = 20
    
    /// The distance by which the close button is inset from the top and right edges of
    /// each ``TabCell``
    private static let CLOSE_BUTTON_INSET: CGFloat = 8
    
    /// The image associated to the close button which appears in the top right corner of
    /// each ``TabCell``
    private static let CLOSE_BUTTON_IMAGE = UIImage(systemName: "xmark.circle.fill")
    
    /// The color of the close button which appears in the top right corner of each
    /// ``TabCell``
    private static let CLOSE_BUTTON_COLOR = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.75)
    
    /// The speed at which the `TabCell` should fly off screen before being deleted.
    private static let FLY_LEFT_SPEED = -5000.0
    
    /// The duration (in seconds) of the `slideHorizontally(byAmount:withScaling:)` animation.
    ///
    /// Note that this value determines both how quickly the tab grows at the outset of
    /// the animation and how quickly it moves to meet the user's finger.
    private static let SLIDE_HORIZONTALLY_ANIMATION_DURATION = 0.2
    
    /// The amount by which a tab will be scaled by while the user is dragging it.
    private static let SLIDE_HORIZONTALLY_ANIMATION_DRAGGING_SCALE = 1.05
    
    /// The duration (in seconds) of the `flyBack()` animation.
    private static let FLY_BACK_ANIMATION_DURATION = 0.2
    
    /// How far a cell must be dragged for deletion, regardless of speed.
    private static let MINIMUM_LEFT_DISPLACEMENT_FOR_DELETION = 125.0
    
    
    /// How fast a cell must be swiped to be deleted, regardless of absolute displacement.
    private static let MINIMUM_LEFT_SPEED_FOR_DELETION = 1000.0
    
    /// How much the motion of the TabCell will be dampened (relative to the user's
    /// finger) when the customer drags a tab to the right.
    ///
    /// Dampening is important since it communicates to the customer that only leftward
    /// swipes will be effective to delete a tab.
    private static let DIRECTIONAL_DAMPENING_FACTOR = 5.0
    
    static let COPY_URL_CONTEXT_MENU_ACTION_TITLE = "Copy URL"
    static let CLOSE_CONTEXT_MENU_ACTION_TITLE = "Close"
}
