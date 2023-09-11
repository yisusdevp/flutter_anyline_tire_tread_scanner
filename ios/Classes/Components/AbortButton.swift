import UIKit

final class AbortButton: UIButton {
    
    // MARK: - Private Properties
    private let cornerRadius: CGFloat = 18
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private func
private extension AbortButton {
    func setup() {
        setTitle("Abort", for: .normal)
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        backgroundColor = UIColor(rgb: 0x0BA9C6)
        contentHorizontalAlignment = .center
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
