import UIKit

final class DistanceStatusLabel: UILabel {
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
private extension DistanceStatusLabel {
    func setup() {
        text = "Trying to set the focus point, please focus on the middle of the running surface"
        textColor = UIColor.white
        textAlignment = .center
        font = UIFont.boldSystemFont(ofSize: 14)
        lineBreakMode = NSLineBreakMode.byWordWrapping
        numberOfLines = 0
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
//        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        
    }
}
