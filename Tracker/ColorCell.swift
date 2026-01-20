import UIKit

final class ColorCell: UICollectionViewCell {
    private let colorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        colorView.layer.cornerRadius = 8
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        contentView.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) { fatalError() }

    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
        }
    }
}
