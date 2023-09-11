import UIKit

final class DistanceStatusLabel: UILabel {
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
        font = UIFont.boldSystemFont(ofSize: 18)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    }
}
