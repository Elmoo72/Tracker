import UIKit

final class TrackersViewController: UIViewController {

    private lazy var titleContainer = UIView()
    private lazy var stubContainer = UIView()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        let plusImage = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(plusImage, for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(didTapAddTrackerButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .black
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
        let iv = UIImageView(image: UIImage(named: "1"))
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
        view.backgroundColor = .white
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
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),

            datePickerView.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            datePickerView.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 5),
            datePickerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 77),

            titleNameLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 44),
            titleNameLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),

            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.centerYAnchor.constraint(equalTo: datePickerView.centerYAnchor),
            addTrackerButton.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),

            searchBar.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            field.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            stubContainer.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            stubContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stubContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stubContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            stubImage.centerXAnchor.constraint(equalTo: stubContainer.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: stubContainer.centerYAnchor),

            stubLabel.centerXAnchor.constraint(equalTo: stubImage.centerXAnchor),
            stubLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubLabel.leadingAnchor.constraint(greaterThanOrEqualTo: stubContainer.leadingAnchor, constant: 16),
            stubLabel.trailingAnchor.constraint(lessThanOrEqualTo: stubContainer.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        
        // ПРОВЕРКА ДАТЫ (Пункт 7.4): Запрет на отметку в будущем
        let dateToCompare = Calendar.current.startOfDay(for: currentDate)
        let today = Calendar.current.startOfDay(for: Date())
        
        if dateToCompare > today {
            return // Выходим, если пользователь пытается отметить трекер завтра или позже
        }

        let record = TrackerRecord(trackerId: tracker.id, date: dateToCompare)
        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }
        adapter.reloadItems(at: [indexPath])
    }
    
    func trackersCollectionView(_ collectionView: TrackersCollectionView, completedCountFor tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }
    
    func trackersCollectionView(_ collectionView: TrackersCollectionView, isCompleted tracker: Tracker) -> Bool {
        completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: Calendar.current.startOfDay(for: currentDate)))
    }
    
    func trackersCollectionViewGetCurrentDate(_ collectionView: TrackersCollectionView) -> Date {
        return currentDate
    }
}

extension TrackersViewController: CreateHabitDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        categories.append(TrackerCategory(title: "Важное", trackers: [tracker]))
        updateVisibleCategories()
        dismiss(animated: true)
    }
}
