import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Получение или создание категории (например, для первой привычки)
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
}
