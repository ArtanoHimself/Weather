
import UIKit

final class FetchedCityCell: UICollectionViewCell {
    
    private enum Constants {
        static let blurViewAlpha: CGFloat = 0.3
        static let blurViewCornerRadius: CGFloat = 15
        static let stackViewLeadingInset: CGFloat = 16
        static let stackViewTrailingInset: CGFloat = -16
    }
    
    static let identifier = "FetchedCityCell"
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = Constants.blurViewAlpha
        view.layer.cornerRadius = Constants.blurViewCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let cityNameLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let cityDescriptionLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .callout)
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
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
        backgroundColor = .clear
    }
    
    private func setupConstraints() {
        contentView.addSubview(blurView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(cityNameLabel)
        stackView.addArrangedSubview(cityDescriptionLabel)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: Constants.stackViewLeadingInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: Constants.stackViewTrailingInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with city: City) {
        cityNameLabel.text = city.name
        cityDescriptionLabel.text = city.country
        if let state = city.state {
            cityDescriptionLabel.text?.append(", \(state)")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cityNameLabel.text = nil
        cityDescriptionLabel.text = nil
    }
}
