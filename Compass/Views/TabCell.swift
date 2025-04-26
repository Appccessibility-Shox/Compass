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
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
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
}
