import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Public Properties
    
    // Используем системный UIDatePicker, так как DatePickerView вызывает ошибку scope
    lazy var datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Private Properties
    
    private lazy var titleNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .black 
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "plus")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "1")
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .black
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stubContainer = UIView()
    private lazy var titleContainer = UIView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let params = CollectionLayoutParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpaсing: 9)
    private lazy var trackersCollectionView = TrackersCollectionView(using: params, collectionView: collectionView)
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(title: "Важное", trackers: [])
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addSubviews()
        setupConstraints()
        setupDelegates()
        
        applyFilter(for: datePickerView.date)
    }
    
    // MARK: - Tracker completion helpers
    
    func normalizedDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let normalized = normalizedDate(date)
        return completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(normalizedDate(record.date), inSameDayAs: normalized)
        }
    }
    
    func completedCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }
    
    // MARK: - Actions
    
    @objc private func dateChanged() {
        applyFilter(for: datePickerView.date)
    }
    
    @objc private func didTapAddTrackerButton() {
        
        let createHabitVC = CreateHabitViewController()
        let nav = UINavigationController(rootViewController: createHabitVC)
        present(nav, animated: true)
    }
    
    // MARK: - Setup UI
    
    private func addSubviews() {
        view.addSubview(titleContainer)
        [titleNameLabel, addTrackerButton, searchBar, datePickerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            titleContainer.addSubview($0)
        }
        
        view.addSubview(stubContainer)
        [stubImage, stubLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stubContainer.addSubview($0)
        }
        
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        [addTrackerButton, datePickerView, titleNameLabel, searchBar, collectionView, stubImage, stubLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            
            addTrackerButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),

            // 2. DatePicker
            datePickerView.centerYAnchor.constraint(equalTo: addTrackerButton.centerYAnchor),
            datePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // 3. Заголовок
            titleNameLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            titleNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // 4. Поиск
            searchBar.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 36),

            // 5. Коллекция
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // 6. Заглушка
            stubImage.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: stubImage.centerXAnchor)
        ])
    }
    
    private func setupDelegates() {
        searchBar.delegate = self
        trackersCollectionView.delegate = self
    }
    
    // MARK: - Filtering
    
    func applyFilter(for date: Date) {
        // Здесь будет ваша логика фильтрации по Weekday
        let hasTrackers = !categories[0].trackers.isEmpty
        stubContainer.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
        trackersCollectionView.update(with: categories)
    }
}

// MARK: - Extensions
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter(for: datePickerView.date)
    }
}

extension TrackersViewController: TrackersCollectionViewDelegate {
    func trackersCollectionView(_ collectionView: TrackersCollectionView, didTapPlusFor tracker: Tracker, at indexPath: IndexPath) {
        // Логика отметки трекера
    }
    
    func trackersCollectionView(_ collectionView: TrackersCollectionView, completedCountFor tracker: Tracker) -> Int {
        completedCount(for: tracker)
    }
    
    func trackersCollectionView(_ collectionView: TrackersCollectionView, isCompleted tracker: Tracker) -> Bool {
        isTrackerCompleted(tracker, on: datePickerView.date)
    }
    
    func trackersCollectionViewGetCurrentDate(_ collectionView: TrackersCollectionView) -> Date {
        datePickerView.date
    }
}
