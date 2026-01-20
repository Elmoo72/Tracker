import UIKit

extension UIColor {
    static var YPBlack: UIColor { UIColor(named: "Black [YP]") ?? .black }
    static var YPWhite: UIColor { UIColor(named: "White [YP]") ?? .white }
    static var YPBlue: UIColor { UIColor(named: "Blue [YP]") ?? .systemBlue }
    static var YPRed: UIColor { UIColor(named: "Red [YP]") ?? .systemRed }
    static var YPBackground: UIColor { UIColor(named: "Background [YP]") ?? .systemBackground }
    static var YPGray: UIColor { UIColor.systemGray }

    // Метод для TrackerStore
    var toHexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02x%02x%02x", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    static func fromHex(_ hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
