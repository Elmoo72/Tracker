import UIKit

extension UIColor {
    static var YPBlack: UIColor { UIColor(named: "YPBlack") ?? .label }
    static var YPWhite: UIColor { UIColor(named: "YPWhite") ?? .systemBackground }
    static var YPBlue: UIColor { UIColor(named: "YPBlue") ?? .systemBlue }
    static var YPRed: UIColor { UIColor(named: "YPRed") ?? .systemRed }
    static var YPGreen: UIColor { UIColor(named: "YPGreen") ?? .systemGreen }
    static var YPBackground: UIColor { UIColor(named: "YPBackground") ?? .systemBackground }
    static var YPGray: UIColor { UIColor(named: "YPGray") ?? .systemGray }
    static var YPLightGray: UIColor { UIColor(named: "LightGrayStatic") ?? .systemGray4 }
    
    static var adaptiveBackground: UIColor {
        return UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return .systemBackground
            } else {
                return .systemBackground
            }
        }
    }
    
    static var adaptiveLabel: UIColor {
        return UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return .label
            } else {
                return .label
            }
        }
    }
   
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02x%02x%02x", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
