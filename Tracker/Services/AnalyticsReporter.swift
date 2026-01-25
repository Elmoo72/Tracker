import Foundation

final class AnalyticsReporter {
    private let service: AnalyticsServiceProtocol
    
    init(service: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.service = service
    }
    
    func report(event: AnalyticsEvent) {
        service.report(event: event.name, params: event.params)
    }
}