import UIKit

final class ScanProgress: UIProgressView {
    
    // MARK: - Private Properties
    private let cornerRadius: CGFloat = 8
    
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
private extension ScanProgress {
    func setup() {
        trackTintColor = UIColor.white
        progressTintColor = UIColor(rgb: 0x0BA9C6)
        layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
