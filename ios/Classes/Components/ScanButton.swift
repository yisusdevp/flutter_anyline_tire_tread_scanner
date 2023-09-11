import UIKit

final class ScanButton: UIButton {
    
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
private extension ScanButton {
    func setup() {
        setTitle("Scan", for: .normal)
        setTitleColor(UIColor(rgb: 0xBFBFBF), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        backgroundColor = UIColor(rgb: 0xE1E1E1)
        contentHorizontalAlignment = .center
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        isEnabled = false
    }
}
