import Foundation
import CoreData

final class PersistentContainer {
    static let shared = PersistentContainer()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel") 
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    } ()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
