import Foundation

enum AnalyticsEvent {
    case open(screen: AnalyticsScreen)
    case close(screen: AnalyticsScreen)
    case click(screen: AnalyticsScreen, item: AnalyticsItem)
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

extension AnalyticsEvent {
    var name: String {
        switch self {
        case .open:
            return "open"
        case .close:
            return "close"
        case .click:
            return "click"
        }
    }
    
    var params: [String: Any] {
        switch self {
        case .open(let screen):
            return [
                "event": "open",
                "screen": screen.rawValue
            ]
        case .close(let screen):
            return [
                "event": "close",
                "screen": screen.rawValue
            ]
        case .click(let screen, let item):
            return [
                "event": "click",
                "screen": screen.rawValue,
                "item": item.rawValue
            ]
        }
    }
}