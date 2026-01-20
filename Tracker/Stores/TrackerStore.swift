import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    func addNewTracker(_ tracker: Tracker, to categoryName: String) {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", categoryName)
        
        let categoryEntity: TrackerCategoryCoreData
        if let existingCategory = try? context.fetch(request).first {
            categoryEntity = existingCategory
        } else {
            categoryEntity = TrackerCategoryCoreData(context: context)
            categoryEntity.title = categoryName
        }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHexString
        trackerCoreData.schedule = tracker.schedule.map { Int16($0.rawValue) } as NSObject
        
        categoryEntity.addToTrackers(trackerCoreData)
        
        do {
            try context.save()
        } catch {
            print("Failed to save tracker: \(error)")
        }
    }
}
