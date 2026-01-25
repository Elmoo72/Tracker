import Foundation

enum WeekDay: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var localizedName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    // Порядок дней недели, начиная с понедельника
    static let weekOrder: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    static func from(_ string: String) -> [WeekDay] {
        let components = string.components(separatedBy: ",")
        return components.compactMap { Int($0) }.compactMap { WeekDay(rawValue: $0) }
    }

    static func encode(_ schedule: [WeekDay]) -> String {
        return schedule.map { String($0.rawValue) }.joined(separator: ",")
    }
}
