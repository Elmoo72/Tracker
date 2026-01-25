import Foundation

enum TrackerFilter: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case todayTrackers = "Трекеры на сегодня"
    case completed = "Завершённые"
    case notCompleted = "Незавершённые"
    
    var title: String {
        return self.rawValue
    }
}