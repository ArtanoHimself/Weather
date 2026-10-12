
import UIKit

final class WeatherDetailsCell: UICollectionViewCell {
    
    private enum Constants {
        static let blurViewAlpha: CGFloat = 0.3
        static let blurViewCornerRadius: CGFloat = 16
    }
    
    static let identifier = "WeatherDetailsCell"
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = Constants.blurViewAlpha
        view.layer.cornerRadius = Constants.blurViewCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let descriptionLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .callout)
        return label
    }()
    
    private let infoLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .center
        sv.distribution = .fillProportionally
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.addSubview(blurView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with weatherDetail: WeatherDetail) {
        descriptionLabel.text = weatherDetail.description
        infoLabel.text = weatherDetail.info
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        infoLabel.text = nil
        descriptionLabel.text = nil
    }
}
