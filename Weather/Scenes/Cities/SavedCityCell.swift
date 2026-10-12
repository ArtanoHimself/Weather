
import UIKit

final class SavedCityCell: UITableViewCell {
    
    private enum Constants {
        static let stackViewTopInset: CGFloat = 8
        static let stackViewLeadingInset: CGFloat = 16
        static let stackViewTrailingInset: CGFloat = -16
        static let stackViewBottomInset: CGFloat = -8
        static let contentViewCornerRadius: CGFloat = 20
    }
    
    static let identifier = "SavedCityCell"
    
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
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupConstraints()
        backgroundColor = .clear
        selectionStyle = .none
        contentView.layer.cornerRadius = Constants.contentViewCornerRadius
    }
    
    private func setupConstraints() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(cityNameLabel)
        stackView.addArrangedSubview(cityDescriptionLabel)
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: Constants.stackViewTopInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: Constants.stackViewLeadingInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: Constants.stackViewTrailingInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: Constants.stackViewBottomInset)
        ])
    }
    
    func configure(with city: City, isActive: Bool) {
        contentView.backgroundColor = isActive ? .systemBlue : .clear
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
        contentView.backgroundColor = .clear
    }
}
    

