import CoreData
import UIKit // Обязательно для UIColor и работы с UI-моделями

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init() // Добавляем вызов супер-инициализатора NSObject
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let categoriesCoreData = try context.fetch(request)
        
        return categoriesCoreData.compactMap { (coreDataCategory) -> TrackerCategory? in
            guard let title = coreDataCategory.title else {
                return nil
            }
            
            // Получаем трекеры, но не исключаем категории без трекеров
            let trackersRaw = coreDataCategory.trackers?.allObjects as? [TrackerCoreData] ?? []
            
            let trackers: [Tracker] = trackersRaw.compactMap { (coreDataTracker) -> Tracker? in
                guard let id = coreDataTracker.id,
                      let name = coreDataTracker.name,
                      let emoji = coreDataTracker.emoji,
                      let colorHex = coreDataTracker.color,
                      let scheduleRaw = coreDataTracker.schedule as? String else {
                    return nil
                }
                
                // Используем твой инициализатор из extension UIColor
                guard let color = UIColor(hex: colorHex) else { 
                    return nil 
                }
                
                return Tracker(
                    id: id,
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: WeekDay.from(scheduleRaw)
                )
            }
            
            // Возвращаем категорию даже если в ней нет трекеров
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    func categoryCoreData(with title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        
        if let category = try context.fetch(request).first {
            return category
        } else {
            let category = TrackerCategoryCoreData(context: context)
            category.title = title
            try context.save()
            return category
        }
    }
    
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // Временный метод для исправления неправильных названий категорий
    func fixIncorrectCategoryNames() throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        let categories = try context.fetch(request)
        
        for category in categories {
            if category.title == "Вниательность" {
                category.title = "Внимательность"
            }
        }
        
        try saveContext()
    }
}
