import Foundation

final class CategoryViewModel {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    
    // MARK: - Bindings
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Public Methods
    func loadCategories() {
        // Временные данные для демонстрации
        categories = [
            TrackerCategory(title: "Важное", trackers: []),
            TrackerCategory(title: "Радостные мелочи", trackers: []),
            TrackerCategory(title: "Самочувствие", trackers: []),
            TrackerCategory(title: "Привычки", trackers: []),
            TrackerCategory(title: "Внимательность", trackers: []),
            TrackerCategory(title: "Спорт", trackers: [])
        ]
        
        onCategoriesUpdated?(categories)
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
        let newCategory = TrackerCategory(title: title, trackers: [])
        categories.append(newCategory)
        onCategoriesUpdated?(categories)
    }
    
    func getCategoriesCount() -> Int {
        return categories.count
    }
    
    func getCategory(at index: Int) -> TrackerCategory? {
        guard index < categories.count else { return nil }
        return categories[index]
    }
}