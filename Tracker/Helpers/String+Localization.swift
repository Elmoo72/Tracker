import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Days formatting
extension Int {
    func daysString() -> String {
        let remainder10 = self % 10
        let remainder100 = self % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(self) " + "day".localized
        }
        if [2, 3, 4].contains(remainder10) && ![12, 13, 14].contains(remainder100) {
            return "\(self) " + "days_2_4".localized
        }
        return "\(self) " + "days_many".localized
    }
}