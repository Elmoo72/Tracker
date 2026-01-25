import Foundation
import CoreData

final class StatisticsService {
    static let shared = StatisticsService()
    
    private let trackerRecordStore: TrackerRecordStore
    
    private init() {
        let context = PersistentContainer.shared.context
        self.trackerRecordStore = TrackerRecordStore(context: context)
    }
    
    func getCompletedTrackersCount() -> Int {
        let records = trackerRecordStore.fetchRecords()
        return records.count
    }
}