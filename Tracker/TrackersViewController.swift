import UIKit
import CoreData

final class TrackersViewController: UIViewController {
    
    // MARK: - Stores
    private lazy var trackerStore: TrackerStore = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return TrackerStore(context: context)
    }()
    
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return TrackerCategoryStore(context: context)
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return TrackerRecordStore(context: context)
    }()
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate: Date = Date()
    
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    // MARK: - UI Elements
    private lazy var titleContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .YPBlack
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .YPWhite
        cv.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerSectionCell")
        cv.register(TrackerSectionHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "header")
        return cv
    }()
    
    private lazy var emptyStateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        let img = UIImageView(image: UIImage(named: "1"))
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .YPBlack
        stack.addArrangedSubview(img)
        stack.addArrangedSubview(label)
        NSLayoutConstraint.activate([
            img.widthAnchor.constraint(equalToConstant: 80),
            img.heightAnchor.constraint(equalToConstant: 80)
        ])
        return stack
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        view.backgroundColor = .YPWhite
        setupNavigationBar()
        
        view.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        titleContainer.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateStack)
        
        [titleContainer, titleLabel, searchBar, collectionView, emptyStateStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // titleContainer теперь закреплен за safeArea и не перекрывает контент
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContainer.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            
            // Заголовок "Трекеры"
            titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 16),
            
            // Поиск под заголовком
            searchBar.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            // Коллекция под контейнером поиска
            collectionView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupNavigationBar() {
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "plus") ?? UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .YPBlack
        addButton.addTarget(self, action: #selector(addTracker), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func fetchData() {
        do {
            self.categories = try trackerCategoryStore.fetchCategories()
            self.completedTrackers = trackerRecordStore.fetchRecords()
            updateVisibleCategories()
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
    }
    
    private func updateVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentDate)
        guard let day = WeekDay(rawValue: filterWeekday) else { return }
        
        let searchText = searchBar.text?.lowercased() ?? ""
        
        visibleCategories = categories.compactMap { category in
            let filtered = category.trackers.filter { tracker in
                let matchesDate = tracker.schedule.contains(day)
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                return matchesDate && matchesSearch
            }
            return filtered.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filtered)
        }
        
        collectionView.reloadData()
        emptyStateStack.isHidden = !visibleCategories.isEmpty
    }
    
    @objc private func addTracker() {
        let vc = CreateHabitViewController()
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func handleTrackerCompletion(tracker: Tracker, isCompleted: Bool, at indexPath: IndexPath) {
        if isCompleted {
            let newRecord = TrackerRecord(trackerId: tracker.id, date: currentDate)
            completedTrackers.insert(newRecord)
            try? trackerRecordStore.add(newRecord)
        } else {
            if let recordToRemove = completedTrackers.first(where: { record in
                record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
            }) {
                completedTrackers.remove(recordToRemove)
                try? trackerRecordStore.remove(recordToRemove)
            }
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateVisibleCategories()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerSectionCell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompletedToday = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(with: tracker, isCompleted: isCompletedToday, completedDays: completedDays)
        
        cell.onComplete = { [weak self] tracker, isCompleted in
            guard let self = self,
                  let currentIndexPath = self.collectionView.indexPath(for: cell) else { return }
            self.handleTrackerCompletion(tracker: tracker, isCompleted: isCompleted, at: currentIndexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = visibleCategories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
}

// MARK: - CreateHabitDelegate
extension TrackersViewController: CreateHabitDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        try? trackerStore.addNewTracker(tracker, toCategoryName: "Важное")
        fetchData()
    }
}

// MARK: - GeometricParams
struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
