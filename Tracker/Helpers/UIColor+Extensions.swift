import UIKit

extension UIColor {
    static var YPBlack: UIColor { UIColor(named: "YP Black") ?? .black }
    static var YPWhite: UIColor { UIColor(named: "YP White") ?? .white }
    static var YPBlue: UIColor { UIColor(named: "YP Blue") ?? .systemBlue }
    static var YPRed: UIColor { UIColor(named: "YP Red") ?? .systemRed }
    static var YPBackground: UIColor { UIColor(named: "YP Background") ?? .systemGray6 }
    static var YPGray: UIColor { UIColor(named: "YP Gray") ?? .systemGray }
    static var YPLightGray: UIColor { UIColor(named: "YP Light Gray") ?? .systemGray4 }
   
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
