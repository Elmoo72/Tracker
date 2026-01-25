import CoreData
import Foundation

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
 
    func fetchRecords() -> Set<TrackerRecord> {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            let records = results.compactMap { coreDataRecord -> TrackerRecord? in
                guard let id = coreDataRecord.id,
                      let date = coreDataRecord.date else { return nil }
                return TrackerRecord(trackerId: id, date: date)
            }
            return Set(records)
        } catch {
            print("Ошибка при чтении TrackerRecord: \(error)")
            return []
        }
    }
    
    func add(_ record: TrackerRecord) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = record.trackerId
        recordCoreData.date = record.date
        try context.save()
        
        // Уведомляем об изменении статистики
        NotificationCenter.default.post(name: NSNotification.Name("TrackerRecordChanged"), object: nil)
    }
    
    func remove(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND date == %@",
                                        record.trackerId as CVarArg,
                                        record.date as NSDate)
        
        if let result = try context.fetch(request).first {
            context.delete(result)
            try context.save()
            
            // Уведомляем об изменении статистики
            NotificationCenter.default.post(name: NSNotification.Name("TrackerRecordChanged"), object: nil)
        }
    }
}
