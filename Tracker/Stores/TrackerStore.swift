import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let trackerCategoryStore: TrackerCategoryStore

    init(context: NSManagedObjectContext) {
        self.context = context
        // Создаем экземпляр стора категорий для связи
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        super.init()
    }

    func addNewTracker(_ tracker: Tracker, toCategoryName categoryName: String) throws {
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: categoryName)
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        // Используем твой extension hexString для UIColor
        trackerCoreData.color = tracker.color.hexString
        // Используем твой WeekDay.encode
        trackerCoreData.schedule = WeekDay.encode(tracker.schedule) as NSObject
        
        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, inCategoryName categoryName: String) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        guard let trackerCoreData = try context.fetch(request).first else {
            throw NSError(domain: "TrackerStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }
        
        let categoryCoreData = try trackerCategoryStore.categoryCoreData(with: categoryName)
        
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.schedule = WeekDay.encode(tracker.schedule) as NSObject
        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        let trackers = try context.fetch(request)
        
        for trackerCoreData in trackers {
            context.delete(trackerCoreData)
        }
        
        try context.save()
    }
}
