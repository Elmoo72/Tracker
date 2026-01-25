import Foundation
import AppMetricaCore

protocol AnalyticsServiceProtocol {
    func report(event: String, params: [String: Any])
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func report(event: String, params: [String: Any]) {
        print("📊 AppMetrica Analytics Event: \(event)")
        print("📊 Parameters: \(params)")
        
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("AppMetrica report error: \(error.localizedDescription)")
        })
    }
}