import UIKit

final class TrackersViewController: UIViewController {

    private lazy var titleContainer = UIView()
    private lazy var stubContainer = UIView()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        let plusImage = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(plusImage, for: .normal)
        button.tintColor = .blackYP
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .blackYP
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
   
    private lazy var datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.searchBarStyle = .minimal
        bar.placeholder = "Поиск"
        bar.searchTextField.font = .systemFont(ofSize: 17)
        return bar
    }()
    
    private lazy var stubImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "EmptyTrackerIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    private let params = CollectionLayoutParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpaсing: 9)
    private lazy var adapter = TrackersCollectionView(using: params, collectionView: collectionView)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteYP
        adapter.delegate = self
        searchBar.delegate = self
        
        addSubviews()
        setupConstraints()
        updateVisibleCategories()
    }
    
    private func addSubviews() {
        [titleContainer, stubContainer, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [titleNameLabel, addTrackerButton, searchBar, datePickerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            titleContainer.addSubview($0)
        }
        
        [stubImage, stubLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stubContainer.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let field = searchBar.searchTextField
        
        NSLayoutConstraint.activate([
            // Title Container
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            
            // Add Button & Date Picker
            addTrackerButton.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 1),
            addTrackerButton.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 18),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            
            datePickerView.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            datePickerView.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            
            // Title Label
            titleNameLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            titleNameLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -8),
            field.heightAnchor.constraint(equalToConstant: 36),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Stub Container
            stubContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            stubImage.centerXAnchor.constraint(equalTo: stubContainer.centerXAnchor),
            stubImage.topAnchor.constraint(equalTo: stubContainer.topAnchor),
            
            stubLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: stubContainer.centerXAnchor),
            stubLabel.bottomAnchor.constraint(equalTo: stubContainer.bottomAnchor)
        ])
    }
    

    @objc private func didTapAddTrackerButton() {
        let createHabitVC = CreateHabitViewController()
        createHabitVC.delegate = self
        present(UINavigationController(rootViewController: createHabitVC), animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = datePickerView.date
        updateVisibleCategories()
    }
    
    private func updateVisibleCategories() {

        visibleCategories = categories
        adapter.update(with: visibleCategories)
        
        let hasTrackers = !visibleCategories.isEmpty
        stubContainer.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
    }
}


extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateVisibleCategories()
    }
}


extension TrackersViewController: TrackersCollectionViewDelegate {
    func trackersCollectionView(_ collectionView: TrackersCollectionView, didTapPlusFor tracker: Tracker, at indexPath: IndexPath) {
        let record = TrackerRecord(trackerId: tracker.id, date: Calendar.current.startOfDay(for: currentDate))
        if completedTrackers.contains(record) { completedTrackers.remove(record) }
        else { completedTrackers.insert(record) }
        adapter.reloadItems(at: [indexPath])
    }
    
    func trackersCollectionView(_ collectionView: TrackersCollectionView, completedCountFor tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }
    
    func trackersCollectionView(_ collectionView: TrackersCollectionView, isCompleted tracker: Tracker) -> Bool {
        completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: Calendar.current.startOfDay(for: currentDate)))
    }
}

extension TrackersViewController: CreateHabitDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        categories.append(TrackerCategory(title: "Важное", trackers: [tracker]))
        updateVisibleCategories()
        dismiss(animated: true)
    }
}
