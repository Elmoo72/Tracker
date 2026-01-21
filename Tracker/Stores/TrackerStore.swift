import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    func addNewTracker(_ tracker: Tracker, to categoryName: String) {
        // 1. Получаем описание сущности для Категории
        guard let categoryEntity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            print("ОШИБКА: Сущность TrackerCategoryCoreData не найдена")
            return
        }
        
        let categoryRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        
        let categoryCoreData: TrackerCategoryCoreData
        
        if let existingCategory = try? context.fetch(categoryRequest).first {
            categoryCoreData = existingCategory
        } else {
            categoryCoreData = TrackerCategoryCoreData(entity: categoryEntity, insertInto: context)
            categoryCoreData.title = categoryName
        }
        
        // 2. Получаем описание сущности для Трекера
        guard let trackerEntity = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else {
            print("ОШИБКА: Сущность TrackerCoreData не найдена")
            return
        }
        
        let trackerCoreData = TrackerCoreData(entity: trackerEntity, insertInto: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHexString
        trackerCoreData.schedule = tracker.schedule.map { Int16($0.rawValue) } as NSObject
        
        // Устанавливаем связь (Inverse сработает автоматически)
        trackerCoreData.category = categoryCoreData
        
        do {
            try context.save()
            print("✅ Трекер успешно сохранен в базу")
        } catch {
            print("❌ Ошибка сохранения Core Data: \(error)")
        }
    }
}
