import UIKit

final class TrackersViewController: UIViewController {

    private lazy var titleContainer = UIView()
    private lazy var stubContainer = UIView()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .custom)
        let plusImage = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
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
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
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
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        
        [titleContainer, titleNameLabel, addTrackerButton, searchBar, stubContainer, stubImage, stubLabel, datePickerView, field, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Контейнер
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            
            // DatePicker — по твоим цифрам (top 5, trailing -16)
            datePickerView.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            datePickerView.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 5),
            datePickerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 77),
            
            // Заголовок "Трекеры" — по твоим цифрам (top 44, leading 16)
            titleNameLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 44),
            titleNameLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            
            // Кнопка "+" — центрирована по пикеру
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.centerYAnchor.constraint(equalTo: datePickerView.centerYAnchor),
            addTrackerButton.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            
            // SearchBar — ПРИВЯЗАН НИЖЕ ЛЕЙБЛА НА 7 (как просил ревьюер)
            searchBar.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: titleNameLabel.bottomAnchor, constant: 7),
            
            // Внутреннее поле поиска
            field.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            field.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            
            // Заглушка (stub)
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
            
            // Коллекция
            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateVisibleCategories()
    }
}

// MARK: - Delegates
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
