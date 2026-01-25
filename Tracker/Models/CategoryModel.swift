import Foundation
import CoreData

protocol CategoryModelProtocol {
    func fetchCategories() throws -> [TrackerCategory]
    func addCategory(title: String) throws
    func createDefaultCategoriesIfNeeded() throws
    func fixCategoryNames() throws
}

final class CategoryModel: CategoryModelProtocol {
    
    // MARK: - Properties
    private let trackerCategoryStore: TrackerCategoryStore
    
    // MARK: - Initialization
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    // MARK: - CategoryModelProtocol
    func fetchCategories() throws -> [TrackerCategory] {
        return try trackerCategoryStore.fetchCategories()
    }
    
    func addCategory(title: String) throws {
        _ = try trackerCategoryStore.categoryCoreData(with: title)
    }
    
    func createDefaultCategoriesIfNeeded() throws {
        let categories = try fetchCategories()
        
        if categories.isEmpty {
            let defaultCategoryTitles = [
                "Важное",
                "Радостные мелочи", 
                "Самочувствие",
                "Привычки",
                "Внимательность",
                "Спорт"
            ]
            
            for title in defaultCategoryTitles {
                try addCategory(title: title)
            }
            
            // Принудительно сохраняем контекст
            try trackerCategoryStore.saveContext()
        }
    }
    
    // Временный метод для исправления категорий с ошибками
    func fixCategoryNames() throws {
        try trackerCategoryStore.fixIncorrectCategoryNames()
    }
}