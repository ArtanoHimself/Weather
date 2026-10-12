
import UIKit

final class InfoLabel: UILabel {
    
    private enum Constants {
        static let labelShadowOpacity: Float = 1.0
        static let labelShadowOffset: CGSize = CGSize(width: 0, height: 1)
        static let labelShadowRadius: CGFloat = 4
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        textColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.labelShadowOpacity
        layer.shadowOffset = Constants.labelShadowOffset
        layer.shadowRadius = Constants.labelShadowRadius
    }
}
