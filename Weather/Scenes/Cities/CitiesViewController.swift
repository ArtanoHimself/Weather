
import UIKit
import Combine

protocol CitiesViewControllerDelegate: AnyObject {
    func didSelectCity(city: City)
}

fileprivate nonisolated enum FetchedCitiesSection {
    case main
}

fileprivate nonisolated enum SavedCitiesSection {
    case main
}

final class CitiesViewController: UIViewController {
    
    //MARK: Properties
    
    private enum Constants {
        static let titleLabelLeadingInset: CGFloat = 20
        static let textFieldInset: CGFloat = 16
        static let textFieldCorner: CGFloat = 15
        static let textFieldTopInset: CGFloat = 16
        static let textFieldLeadingInset: CGFloat = 16
        static let textFieldTrailingInset: CGFloat = -16
        static let fetchedCitiesCVHeightMultiplier: CGFloat = 0.4
        static let stackViewTopInset: CGFloat = 16
        static let stackViewLeadingInset: CGFloat = 16
        static let stackViewTrailingInset: CGFloat = -16
        static let stackViewBottomInset: CGFloat = -16
        static let stackViewSpacing: CGFloat = 16
        
        enum LayoutConstants {
            static let itemWidth: CGFloat = 1.0
            static let itemHeight: CGFloat = 0.2
            static let groupWidth: CGFloat = 1.0
            static let groupHeight: CGFloat = 1.0
            static let groupSpacing: CGFloat = 10
            static let sectionInset: CGFloat = 16
        }
    }
    
    weak var delegate: CitiesViewControllerDelegate?
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: CitiesViewModel
    private lazy var layout = makeLayout()
    
    //MARK: UI Components
    
    private lazy var titleLabel: InfoLabel = {
        let label = InfoLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "City management"
        label.font = .preferredFont(forTextStyle: .title1)
        return label
    }()
    
    private lazy var citySearchField: UITextField = {
        let textField = UITextField()
        let inset = UIView(frame: CGRect(x: 0, y: 0, width: Constants.textFieldInset, height: 0))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .always
        textField.backgroundColor = .darkGray
        textField.font = .preferredFont(forTextStyle: .title1)
        textField.layer.cornerRadius = Constants.textFieldCorner
        textField.textColor = .white
        textField.leftView = inset
        textField.leftViewMode = .always
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter location",
            attributes: [.foregroundColor: UIColor.lightGray]
            
        )
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [savedCitiesLabel,
                                                savedCitiesTableView])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = Constants.stackViewSpacing
        return sv
    }()
    
    private lazy var savedCitiesLabel: InfoLabel = {
        let label = InfoLabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Saved Cities"
        return label
    }()
    
    private lazy var savedCitiesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SavedCityCell.self, forCellReuseIdentifier: SavedCityCell.identifier)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var savedCitiesDataSource: UITableViewDiffableDataSource<SavedCitiesSection, City> = {
        let dataSource = UITableViewDiffableDataSource<SavedCitiesSection, City> (tableView: savedCitiesTableView)
        { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: SavedCityCell.identifier, for: indexPath) as! SavedCityCell
            let isActive = indexPath.row == 0
            cell.configure(with: itemIdentifier, isActive: isActive)
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }()
    
    private lazy var fetchedCitiesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FetchedCityCell.self, forCellWithReuseIdentifier: FetchedCityCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var fetchedCitiesDataSource: UICollectionViewDiffableDataSource<FetchedCitiesSection, City> = {
        let dataSource = UICollectionViewDiffableDataSource<FetchedCitiesSection, City> (collectionView: fetchedCitiesCollectionView)
        { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FetchedCityCell.identifier, for: indexPath) as! FetchedCityCell
            cell.configure(with: itemIdentifier)
            return cell
        }
        return dataSource
    }()
    
    init(viewModel: CitiesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        fetchedCitiesCollectionView.delegate = self
        savedCitiesTableView.delegate = self
        setupConstraints()
        bindViewModel()
        setupKeyboardObservers()
        setupGestures()
        setSearchMode(false)
    }
    
    //MARK: Constraints
    
    private func setupConstraints() {
        view.addSubview(titleLabel)
        view.addSubview(citySearchField)
        view.addSubview(stackView)
        view.addSubview(fetchedCitiesCollectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: Constants.titleLabelLeadingInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            citySearchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant:
                                                    Constants.textFieldTopInset),
            citySearchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:
                                                        Constants.textFieldLeadingInset),
            citySearchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:
                                                        Constants.textFieldTrailingInset),
            
            
            fetchedCitiesCollectionView.topAnchor.constraint(equalTo: citySearchField.bottomAnchor),
            fetchedCitiesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fetchedCitiesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fetchedCitiesCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                                multiplier: Constants.fetchedCitiesCVHeightMultiplier),
            
            stackView.topAnchor.constraint(equalTo: citySearchField.bottomAnchor,
                                           constant: Constants.stackViewTopInset),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: Constants.stackViewLeadingInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: Constants.stackViewTrailingInset),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                              constant: Constants.stackViewBottomInset),
        ])
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(Constants.LayoutConstants.itemWidth),
                heightDimension: .fractionalHeight(Constants.LayoutConstants.itemHeight)))
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(Constants.LayoutConstants.groupWidth),
                heightDimension: .fractionalWidth(Constants.LayoutConstants.groupHeight)
            ),
            subitems: [item]
        )
        
        group.interItemSpacing = .fixed(Constants.LayoutConstants.groupSpacing)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: Constants.LayoutConstants.sectionInset,
                                                        leading: Constants.LayoutConstants.sectionInset,
                                                        bottom: Constants.LayoutConstants.sectionInset,
                                                        trailing: Constants.LayoutConstants.sectionInset)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: Gestures and Observers
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandle))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                setSearchMode(true)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                setSearchMode(false)
            }
            .store(in: &cancellables)
    }
    
    private func setSearchMode(_ isSearching: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.fetchedCitiesCollectionView.isHidden = !isSearching
            self.savedCitiesTableView.isHidden = isSearching
            self.savedCitiesLabel.isHidden = isSearching
        }
    }
    
    // MARK: ViewModel update and binding
    
    private func bindViewModel() {
        viewModel.$searchedCities
            .receive(on: DispatchQueue.main)
        
            .sink { [weak self] cities in
                guard let self else { return }
                self.applyCollectionViewSnapshot(with: cities)
            }
            .store(in: &cancellables)
        
        viewModel.$savedCities
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] cities in
                guard let self else { return }
                self.applyTableViewSnapshot(with: cities)
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
    }
    
    private func applyCollectionViewSnapshot(with cities: [City]) {
        var snapshot = NSDiffableDataSourceSnapshot<FetchedCitiesSection, City>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cities)
        fetchedCitiesDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applyTableViewSnapshot(with cities: [City]) {
        var snapshot = NSDiffableDataSourceSnapshot<SavedCitiesSection, City>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cities)
        snapshot.reconfigureItems(cities)
        savedCitiesDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    //MARK: Actions
    
    @objc private func textFieldDidChange() {
        guard let text = citySearchField.text else { return }
        viewModel.searchQuery = text
    }
    
    @objc private func tapGestureHandle() {
        view.endEditing(true)
    }
}

// MARK: TableView and Collection Delegates

extension CitiesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let city = fetchedCitiesDataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.saveCity(city: city)
        if viewModel.savedCities.count == 1 {
            delegate?.didSelectCity(city: city)
        }
        citySearchField.text = nil
        viewModel.clearSearchQuery()
    }
}

extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row != 0 else { return nil }
        guard let city = savedCitiesDataSource.itemIdentifier(for: indexPath) else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            self.viewModel.deleteCity(city: city)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let city = savedCitiesDataSource.itemIdentifier(for: indexPath) else { return }
        delegate?.didSelectCity(city: city)
        viewModel.reorderCity(city: city)
    }
}

