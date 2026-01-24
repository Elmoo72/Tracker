import Foundation

final class CategoryViewModel {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private let categoryModel: CategoryModelProtocol
    
    // MARK: - Bindings
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(categoryModel: CategoryModelProtocol) {
        self.categoryModel = categoryModel
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        do {
            try categoryModel.createDefaultCategoriesIfNeeded()
            categories = try categoryModel.fetchCategories()
            onCategoriesUpdated?(categories)
        } catch {
            onError?("Ошибка загрузки категорий: \(error.localizedDescription)")
        }
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else {
            onError?("Неверный индекс категории")
            return
        }
        
        let selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
    
    func addCategory(title: String) {
        do {
            try categoryModel.addCategory(title: title)
            loadCategories()
        } catch {
            onError?("Ошибка добавления категории: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Table View Data Source Methods
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func categoryTitle(at index: Int) -> String {
        guard index < categories.count else { return "" }
        return categories[index].title
    }
    
    func category(at index: Int) -> TrackerCategory? {
        guard index < categories.count else { return nil }
        return categories[index]
    }
    
    func isEmpty() -> Bool {
        return categories.isEmpty
    }
    
    // MARK: - Cell Configuration Data
    func configureCellData(at index: Int, isSelected: Bool) -> CategoryCellData? {
        guard index < categories.count else { return nil }
        
        return CategoryCellData(
            title: categories[index].title,
            isSelected: isSelected
        )
    }
}

// MARK: - Category Cell Data Model
struct CategoryCellData {
    let title: String
    let isSelected: Bool
}