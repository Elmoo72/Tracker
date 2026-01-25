import UIKit

final class EmojiCell: UICollectionViewCell {
    private let emojiLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        emojiLabel.font = .systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) { fatalError() }

    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? .YPGray.withAlphaComponent(0.3) : .clear
    }
}
