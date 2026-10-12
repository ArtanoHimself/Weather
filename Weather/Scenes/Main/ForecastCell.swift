
import UIKit

final class ForecastCell: UICollectionViewCell {
    
    private enum Constants {
        static let blurViewAlpha: CGFloat = 0.3
        static let blurViewCornerRadius: CGFloat = 16
        static let stackViewTopInset: CGFloat = 8
    }
    
    static let identifier = "ForecastCell"
    
    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let view = UIVisualEffectView(effect: blur)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = Constants.blurViewAlpha
        view.layer.cornerRadius = Constants.blurViewCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let tempLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let tempImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let windLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let timeLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .callout)
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
        stackView.addArrangedSubview(tempLabel)
        stackView.addArrangedSubview(tempImage)
        stackView.addArrangedSubview(windLabel)
        stackView.addArrangedSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.stackViewTopInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func configure(with forecastDetail: ForecastDetail) {
        tempLabel.text = forecastDetail.tempText
        tempImage.image = makeTempImage(id: forecastDetail.imageId)
        windLabel.text = forecastDetail.windText
        timeLabel.text = forecastDetail.timeText
    }
    
    private func makeTempImage(id: Int) -> UIImage? {
        let config = UIImage.SymbolConfiguration(paletteColors: id.weatherPaletteColors)
        return UIImage(systemName: id.weatherSymbolName)?.applyingSymbolConfiguration(config)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tempLabel.text = nil
        tempImage.image = nil
        windLabel.text = nil
        timeLabel.text = nil
    }
}
