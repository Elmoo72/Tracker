import UIKit

final class FiltersViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FiltersDelegate?
    var currentFilter: TrackerFilter = .allTrackers
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .YPWhite
        table.separatorStyle = .singleLine
        table.separatorColor = .YPGray
        table.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTheme()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Фильтры"
        view.backgroundColor = .YPWhite
        
        navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        updateColorsForCurrentTheme()
    }
    
    private func updateColorsForCurrentTheme() {
        view.backgroundColor = .YPWhite
        tableView.backgroundColor = .YPWhite
        tableView.separatorColor = .YPGray
        
        // Принудительно обновляем layer цвета
        view.layer.backgroundColor = UIColor.YPWhite.cgColor
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = TrackerFilter.allCases[indexPath.row]
        
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .YPBlack
        cell.backgroundColor = .YPBackground
        cell.selectionStyle = .none
        
        // Принудительно обновляем layer цвета
        cell.layer.backgroundColor = UIColor.YPBackground.cgColor
        
        // Показываем галочку только для завершенных и незавершенных фильтров
        if (filter == .completed || filter == .notCompleted) && filter == currentFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = .YPBlue
        } else {
            cell.accessoryType = .none
        }
        
        // Настройка углов для первой и последней ячейки
        if indexPath.row == 0 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == TrackerFilter.allCases.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }
        
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = TrackerFilter.allCases[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}