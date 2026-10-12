
import UIKit
import Combine

fileprivate nonisolated enum WeatherDetailSection: Hashable {
    case main
}

fileprivate nonisolated enum ForecastDetailSection: Hashable {
    case main
}

final class WeatherViewController: UIViewController {
    
    //MARK: Properties
    
    enum Constants {
        static let tempLabelFont: CGFloat = 90
        static let stackViewSpacing: CGFloat = 5
        static let topSpacerMultiplier: CGFloat = 0.03
        static let weatherDetailCollectionHeightMultiplier: CGFloat = 0.1
        static let forecastCollectionHeightMultiplier: CGFloat = 0.15
        static let navigationBarSpacer: CGFloat = 8
        
        enum DetailLayoutConstants {
            static let itemWidth: CGFloat = 0.25
            static let itemHeight: CGFloat = 1.0
            static let groupWidth: CGFloat = 1.0
            static let groupHeight: CGFloat = 1.0
            static let groupSpacing: CGFloat = 10
            static let sectionTopInset: CGFloat = 0
            static let sectionInset: CGFloat = 16
        }
        
        enum ForecastLayoutConstants {
            static let itemWidth: CGFloat = 0.25
            static let itemHeight: CGFloat = 1.0
            static let groupWidth: CGFloat = 1.0
            static let groupHeight: CGFloat = 1.0
            static let spacing: CGFloat = 10
            static let sectionTopInset: CGFloat = 0
            static let sectionInset: CGFloat = 16
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: WeatherViewModel
    
    private lazy var detailLayout = makeDetailsLayout()
    private lazy var forecastLayout = makeForecastLayout()
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI components
    
    private lazy var backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var addCityButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus")
        button.target = self
        button.action = #selector(addCityButtonTapped)
        return button
    }()
    
    private lazy var dateLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private lazy var countryLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .title3)
        return label
    }()
    
    private lazy var tempLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .systemFont(ofSize: Constants.tempLabelFont, weight: .thin)
        return label
    }()
    
    private lazy var weatherDescriptionLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .callout)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [dateLabel,
                                                countryLabel,
                                                tempLabel,
                                                weatherDescriptionLabel])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = Constants.stackViewSpacing
        return sv
    }()
    
    private let topSpacer = UILayoutGuide()
    
    private lazy var forecastCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: forecastLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(ForecastCell.self, forCellWithReuseIdentifier: ForecastCell.identifier)
        return cv
    }()
    
    private lazy var weatherDetailCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: detailLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isUserInteractionEnabled = false
        cv.register(WeatherDetailsCell.self, forCellWithReuseIdentifier: WeatherDetailsCell.identifier)
        return cv
    }()
    
    private lazy var forecastDataSource: UICollectionViewDiffableDataSource<ForecastDetailSection, ForecastDetail> = {
        let dataSource = UICollectionViewDiffableDataSource<ForecastDetailSection, ForecastDetail> (collectionView: forecastCollectionView)
        { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCell.identifier, for: indexPath) as! ForecastCell
            cell.configure(with: itemIdentifier)
            return cell
        }
        return dataSource
    }()
    
    private lazy var detailsDataSource: UICollectionViewDiffableDataSource<WeatherDetailSection, WeatherDetail> = {
        let dataSource = UICollectionViewDiffableDataSource<WeatherDetailSection, WeatherDetail> (collectionView: weatherDetailCollectionView)
        { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherDetailsCell.identifier, for: indexPath) as! WeatherDetailsCell
            cell.configure(with: itemIdentifier)
            return cell
        }
        return dataSource
    }()
    
    //MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: UI/Layout Setup
    
    private func setupUI() {
        setupConstraints()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupConstraints() {
        view.addLayoutGuide(topSpacer)
        view.addSubview(backgroundImageView)
        view.addSubview(stackView)
        view.addSubview(forecastCollectionView)
        view.addSubview(weatherDetailCollectionView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            topSpacer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topSpacer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSpacer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSpacer.heightAnchor.constraint(equalTo: view.heightAnchor,
                                              multiplier: Constants.topSpacerMultiplier),

            stackView.topAnchor.constraint(equalTo: topSpacer.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            forecastCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                           multiplier: Constants.forecastCollectionHeightMultiplier),
            forecastCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastCollectionView.bottomAnchor.constraint(equalTo: weatherDetailCollectionView.topAnchor),
            
            weatherDetailCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                               multiplier: Constants.weatherDetailCollectionHeightMultiplier),
            weatherDetailCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherDetailCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherDetailCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [addCityButton]
    }
    
    private func makeForecastLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(Constants.ForecastLayoutConstants.itemWidth),
                heightDimension: .fractionalHeight(Constants.ForecastLayoutConstants.itemHeight)))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(Constants.ForecastLayoutConstants.groupWidth),
                heightDimension: .fractionalHeight(Constants.ForecastLayoutConstants.groupHeight)
            ),
            subitems: [item])
        group.interItemSpacing = .fixed(Constants.ForecastLayoutConstants.spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Constants.ForecastLayoutConstants.spacing
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.ForecastLayoutConstants.sectionTopInset,
                                                        leading: Constants.ForecastLayoutConstants.sectionInset,
                                                        bottom: Constants.ForecastLayoutConstants.sectionInset,
                                                        trailing: Constants.ForecastLayoutConstants.sectionInset)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func makeDetailsLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(Constants.DetailLayoutConstants.itemWidth),
                heightDimension: .fractionalHeight(Constants.DetailLayoutConstants.itemHeight)))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(Constants.DetailLayoutConstants.groupWidth),
                heightDimension: .fractionalHeight(Constants.DetailLayoutConstants.groupHeight)
            ),
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(Constants.DetailLayoutConstants.groupSpacing)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.DetailLayoutConstants.sectionTopInset,
                                                        leading: Constants.DetailLayoutConstants.sectionInset,
                                                        bottom: Constants.DetailLayoutConstants.sectionInset,
                                                        trailing: Constants.DetailLayoutConstants.sectionInset)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    //MARK: ViewModel update and binding
    
    private func updateUI(with viewState: WeatherViewState) {
        backgroundImageView.image = UIImage(named: viewState.backgroundImageName)
        tempLabel.text = viewState.temperatureText
        countryLabel.text = viewState.locationText
        dateLabel.text = viewState.dateText
        weatherDescriptionLabel.text = viewState.descriptionText
        
        applyDetailsSnapshot(with: viewState.details)
        applyForecastSnapshot(with: viewState.forecast)
    }
    
    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] viewState in
                guard let self = self else { return }
                guard let viewState = viewState else { return }
                self.updateUI(with: viewState)
            }
            .store(in: &cancellables)
        
        viewModel.$networkErrorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                guard let self else { return }
                
                let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    guard let self else { return }
                    self.viewModel.networkErrorMessage = nil
                })
                self.present(alert, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.$storageErrorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                guard let self else { return }
                
                let alert = UIAlertController(title: "Storage Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    guard let self else { return }
                    self.viewModel.storageErrorMessage = nil
                })
                self.present(alert, animated: true)
            }
            .store(in: &cancellables)
        
        guard let city = viewModel.currentCity else { return }
        viewModel.fetchWeather(for: city)
    }
    
    private func applyDetailsSnapshot(with details: [WeatherDetail]) {
        var snapshot = NSDiffableDataSourceSnapshot<WeatherDetailSection, WeatherDetail>()
        snapshot.appendSections([.main])
        snapshot.appendItems(details)
        detailsDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func applyForecastSnapshot(with forecast: [ForecastDetail]) {
        var snapshot = NSDiffableDataSourceSnapshot<ForecastDetailSection, ForecastDetail>()
        snapshot.appendSections([.main])
        snapshot.appendItems(forecast)
        forecastDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    //MARK: Actions
    
    @objc private func addCityButtonTapped() {
        let vc = AppFactory.createCitiesViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension WeatherViewController: CitiesViewControllerDelegate {
    func didSelectCity(city: City) {
        viewModel.fetchWeather(for: city)
    }
}

