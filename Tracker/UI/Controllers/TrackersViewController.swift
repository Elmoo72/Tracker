import UIKit
import CoreData

final class TrackersViewController: UIViewController {
    
    // MARK: - Analytics
    private let analyticsReporter = AnalyticsReporter()
    
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
    private var currentFilter: TrackerFilter = .allTrackers
    private var pinnedTrackers: Set<UUID> = []
    
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    // MARK: - UI Elements
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(systemName: "plus") ?? UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .YPBlack
        button.addTarget(self, action: #selector(addTracker), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "trackers".localized
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
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("filters".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.YPWhite, for: .normal)
        button.backgroundColor = .YPBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        return button
    }()
    
    private lazy var noResultsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        let img = UIImageView(image: UIImage(named: "1"))
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .YPBlack
        stack.addArrangedSubview(img)
        stack.addArrangedSubview(label)
        stack.isHidden = true
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
        loadPinnedTrackers()
        fetchData()
        setupDarkModeSupport()
        
        // Подписываемся на изменения локализации
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localizationDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsReporter.report(event: .open(screen: .main))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsReporter.report(event: .close(screen: .main))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func localizationDidChange() {
        updateLocalization()
    }
    
    private func updateLocalization() {
        titleLabel.text = "trackers".localized
        filtersButton.setTitle("filters".localized, for: .normal)
        
        // Обновляем tab bar
        if let tabBarController = tabBarController {
            tabBarController.tabBar.items?[0].title = "trackers_tab".localized
            tabBarController.tabBar.items?[1].title = "statistics_tab".localized
        }
        
        // Перезагружаем коллекцию для обновления количества дней
        collectionView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTheme()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .YPWhite
        setupNavigationBar()
        
        view.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        titleContainer.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateStack)
        view.addSubview(noResultsStack)
        view.addSubview(filtersButton)
        
        [titleContainer, titleLabel, searchBar, collectionView, emptyStateStack, noResultsStack, filtersButton].forEach {
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
            
            // Empty state
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // No results state
            noResultsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Filters button
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Настройка отступов для кнопки фильтров
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 66, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        
        // Настройка цветов для темной темы
        updateColorsForCurrentTheme()
    }
    
    private func setupNavigationBar() {
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
        
        // Фильтруем только категории с трекерами для отображения на главном экране
        let categoriesWithTrackers = categories.filter { !$0.trackers.isEmpty }
        
        var allVisibleTrackers: [(tracker: Tracker, categoryTitle: String)] = []
        var pinnedVisibleTrackers: [Tracker] = []
        var regularCategories: [TrackerCategory] = []
        
        // Собираем все подходящие трекеры
        for category in categoriesWithTrackers {
            let filtered = category.trackers.filter { tracker in
                let matchesDate = tracker.schedule.contains(day)
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
                let matchesFilter = matchesCurrentFilter(tracker: tracker)
                return matchesDate && matchesSearch && matchesFilter
            }
            
            for tracker in filtered {
                if pinnedTrackers.contains(tracker.id) {
                    pinnedVisibleTrackers.append(tracker)
                } else {
                    allVisibleTrackers.append((tracker: tracker, categoryTitle: category.title))
                }
            }
        }
        
        // Группируем обычные трекеры по категориям
        let groupedTrackers = Dictionary(grouping: allVisibleTrackers) { $0.categoryTitle }
        regularCategories = groupedTrackers.compactMap { (title, trackers) in
            let trackersOnly = trackers.map { $0.tracker }
            return trackersOnly.isEmpty ? nil : TrackerCategory(title: title, trackers: trackersOnly)
        }
        
        // Формируем итоговый список категорий
        visibleCategories = []
        
        // Добавляем закрепленные трекеры в отдельную секцию, если они есть
        if !pinnedVisibleTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(title: "pinned".localized, trackers: pinnedVisibleTrackers)
            visibleCategories.append(pinnedCategory)
        }
        
        // Добавляем обычные категории
        visibleCategories.append(contentsOf: regularCategories)
        
        updateUIState()
    }
    
    private func matchesCurrentFilter(tracker: Tracker) -> Bool {
        let isCompletedToday = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        
        switch currentFilter {
        case .allTrackers, .todayTrackers:
            return true
        case .completed:
            return isCompletedToday
        case .notCompleted:
            return !isCompletedToday
        }
    }
    
    private func updateUIState() {
        let hasTrackers = !categories.isEmpty
        let hasVisibleTrackers = !visibleCategories.isEmpty
        let isSearching = !(searchBar.text?.isEmpty ?? true)
        let isFiltering = currentFilter != .allTrackers
        
        // Показываем/скрываем элементы UI
        collectionView.isHidden = !hasVisibleTrackers
        emptyStateStack.isHidden = hasTrackers || isSearching || isFiltering
        noResultsStack.isHidden = hasVisibleTrackers || !hasTrackers || (!isSearching && !isFiltering)
        filtersButton.isHidden = !hasTrackers
        
        // Обновляем цвет кнопки фильтров
        updateFiltersButtonAppearance()
        
        collectionView.reloadData()
    }
    
    private func updateFiltersButtonAppearance() {
        let isFilterActive = currentFilter != .allTrackers && currentFilter != .todayTrackers
        filtersButton.setTitleColor(isFilterActive ? .YPRed : .YPWhite, for: .normal)
    }
    
    @objc private func addTracker() {
        analyticsReporter.report(event: .click(screen: .main, item: .addTrack))
        let vc = CreateHabitViewController()
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func showFilters() {
        analyticsReporter.report(event: .click(screen: .main, item: .filter))
        let filtersVC = FiltersViewController()
        filtersVC.currentFilter = currentFilter
        filtersVC.delegate = self
        present(UINavigationController(rootViewController: filtersVC), animated: true)
    }
    
    // MARK: - Dark Mode Support
    private func setupDarkModeSupport() {
        updateColorsForCurrentTheme()
    }
    
    private func updateColorsForCurrentTheme() {
        // Обновляем цвета основных элементов
        view.backgroundColor = .YPWhite
        collectionView.backgroundColor = .YPWhite
        titleLabel.textColor = .YPBlack
        
        // Обновляем цвет кнопки добавления в навигации
        addButton.tintColor = .YPBlack
        
        // Обновляем цвета поисковой строки
        updateSearchBarColors()
        
        // Обновляем цвета empty state
        updateEmptyStateColors()
        
        // Обновляем цвета кнопки фильтров
        updateFiltersButtonAppearance()
        
        // Перезагружаем коллекцию для обновления ячеек
        collectionView.reloadData()
    }
    
    private func updateSearchBarColors() {
        // Настройка цветов для поисковой строки в зависимости от темы
        searchBar.backgroundColor = .clear
        
        if let textField = searchBar.searchTextField as UITextField? {
            textField.backgroundColor = .YPBackground
            textField.textColor = .YPBlack
            textField.attributedPlaceholder = NSAttributedString(
                string: "Поиск",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.YPGray]
            )
            
            // Принудительно обновляем цвета
            textField.layer.backgroundColor = UIColor.YPBackground.cgColor
        }
        
        // Обновляем цвет иконки поиска
        if let searchIcon = searchBar.searchTextField.leftView as? UIImageView {
            searchIcon.tintColor = .YPGray
        }
    }
    
    private func updateEmptyStateColors() {
        // Обновляем цвет текста в empty state
        if let label = emptyStateStack.arrangedSubviews.last as? UILabel {
            label.textColor = .YPBlack
        }
        
        // Обновляем цвет текста в no results state
        if let label = noResultsStack.arrangedSubviews.last as? UILabel {
            label.textColor = .YPBlack
        }
    }
    
    private func handleTrackerCompletion(tracker: Tracker, isCompleted: Bool, at indexPath: IndexPath) {
        analyticsReporter.report(event: .click(screen: .main, item: .track))
        
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
    
    // MARK: - Context Menu
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isPinned = pinnedTrackers.contains(tracker.id)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pinAction = UIAction(
                title: isPinned ? "unpin".localized : "pin".localized,
                image: UIImage(systemName: isPinned ? "pin.slash" : "pin")
            ) { _ in
                self.togglePinTracker(tracker)
            }
            
            let editAction = UIAction(
                title: "edit".localized,
                image: UIImage(systemName: "pencil")
            ) { _ in
                self.editTracker(tracker)
            }
            
            let deleteAction = UIAction(
                title: "delete".localized,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.deleteTracker(tracker)
            }
            
            return UIMenu(children: [pinAction, editAction, deleteAction])
        }
    }
    
    private func togglePinTracker(_ tracker: Tracker) {
        if pinnedTrackers.contains(tracker.id) {
            pinnedTrackers.remove(tracker.id)
        } else {
            pinnedTrackers.insert(tracker.id)
        }
        
        // Сохраняем состояние закрепленных трекеров в UserDefaults
        let pinnedArray = Array(pinnedTrackers).map { $0.uuidString }
        UserDefaults.standard.set(pinnedArray, forKey: "pinnedTrackers")
        
        // Обновляем отображение
        updateVisibleCategories()
    }
    
    private func loadPinnedTrackers() {
        if let pinnedArray = UserDefaults.standard.array(forKey: "pinnedTrackers") as? [String] {
            pinnedTrackers = Set(pinnedArray.compactMap { UUID(uuidString: $0) })
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        analyticsReporter.report(event: .click(screen: .main, item: .edit))
        let vc = CreateHabitViewController()
        vc.tracker = tracker
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        analyticsReporter.report(event: .click(screen: .main, item: .delete))
        let alert = UIAlertController(
            title: "delete_tracker_title".localized,
            message: "delete_tracker_message".localized,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "delete".localized, style: .destructive) { _ in
            self.confirmDeleteTracker(tracker)
        })
        
        present(alert, animated: true)
    }
    
    private func confirmDeleteTracker(_ tracker: Tracker) {
        do {
            // Удаляем из закрепленных, если был закреплен
            pinnedTrackers.remove(tracker.id)
            let pinnedArray = Array(pinnedTrackers).map { $0.uuidString }
            UserDefaults.standard.set(pinnedArray, forKey: "pinnedTrackers")
            
            // Удаляем трекер из базы данных
            try trackerStore.deleteTracker(tracker)
            fetchData()
        } catch {
            print("Ошибка удаления трекера: \(error)")
        }
    }
}

// MARK: - CreateHabitDelegate
extension TrackersViewController: CreateHabitDelegate {
    func didCreateTracker(_ tracker: Tracker, inCategory category: TrackerCategory) {
        do {
            try trackerStore.addNewTracker(tracker, toCategoryName: category.title)
            fetchData()
        } catch {
            print("Ошибка добавления трекера: \(error)")
        }
    }
    
    func didEditTracker(_ tracker: Tracker, inCategory category: TrackerCategory) {
        do {
            try trackerStore.updateTracker(tracker, inCategoryName: category.title)
            fetchData()
        } catch {
            print("Ошибка обновления трекера: \(error)")
        }
    }
}

// MARK: - FiltersDelegate
extension TrackersViewController: FiltersDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        
        if filter == .todayTrackers {
            currentDate = Date()
            datePicker.date = currentDate
        }
        
        updateVisibleCategories()
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
