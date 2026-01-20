import CoreData
import UIKit

// Протокол для уведомления ViewController об изменениях
protocol TrackerStoreDelegate: AnyObject {
    func storeDidChange(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        
        try? controller.performFetch()
    }
    
    // Метод добавления нового трекера в конкретную категорию
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.toHexString
        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSArray
        trackerCoreData.category = category
        
        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSManagedObject>) {
        delegate?.storeDidChange(self)
    }
}
