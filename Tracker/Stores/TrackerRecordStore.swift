import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func add(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = record.trackerId
        recordCoreData.date = record.date
        // Здесь можно связать с TrackerCoreData через fetchRequest по id
        try context.save()
    }
    
    func remove(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND date == %@",
                                        record.trackerId as CVarArg,
                                        record.date as NSDate)
        
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
        }
    }
}
