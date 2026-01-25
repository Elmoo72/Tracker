import UIKit
import CoreData

final class CategoryViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .YPBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .YPWhite
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.YPWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .YPBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            message: "Привычки и события можно\nобъединить по смыслу",
            image: UIImage(named: "trackers")
        )
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private let viewModel: CategoryViewModel
    private var selectedCategory: TrackerCategory?
    
    // MARK: - Callbacks
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    // MARK: - Initialization
    init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trackerCategoryStore = TrackerCategoryStore(context: context)
        let categoryModel = CategoryModel(trackerCategoryStore: trackerCategoryStore)
        self.viewModel = CategoryViewModel(categoryModel: categoryModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категория"
        setupUI()
        bindViewModel()
        viewModel.loadCategories()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTheme()
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .YPWhite
        
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        updateColorsForCurrentTheme()
    }
    
    private func updateColorsForCurrentTheme() {
        view.backgroundColor = .YPWhite
        tableView.backgroundColor = .YPWhite
        titleLabel.textColor = .YPBlack
        addCategoryButton.backgroundColor = .YPBlack
        addCategoryButton.setTitleColor(.YPWhite, for: .normal)
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            DispatchQueue.main.async {
                self?.updateUI(with: categories)
            }
        }
        
        viewModel.onCategorySelected = { [weak self] category in
            self?.selectedCategory = category
            self?.onCategorySelected?(category)
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showError(errorMessage)
            }
        }
    }
    
    private func updateUI(with categories: [TrackerCategory]) {
        let isEmpty = viewModel.isEmpty()
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        if !isEmpty {
            tableView.reloadData()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func addCategoryButtonTapped() {
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.onCategoryAdded = { [weak self] categoryTitle in
            self?.viewModel.addCategory(title: categoryTitle)
        }
        
        navigationController?.pushViewController(addCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let isSelected = selectedCategory?.title == viewModel.categoryTitle(at: indexPath.row)
        
        if let cellData = viewModel.configureCellData(at: indexPath.row, isSelected: isSelected) {
            cell.configure(with: cellData.title, isSelected: cellData.isSelected)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}