import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapCompleteButton(of cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    
    private let cardView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let daysLabel = UILabel()
    private let completeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        cardView.layer.cornerRadius = 16
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .YPBlack
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        completeButton.layer.cornerRadius = 17
        completeButton.tintColor = .white
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cardView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func didTapComplete() {
        delegate?.didTapCompleteButton(of: self)
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysLabel.text = formatDaysString(completedDays)
        
        let imageName = isCompleted ? "checkmark" : "plus"
        completeButton.setImage(UIImage(systemName: imageName), for: .normal)
        completeButton.backgroundColor = tracker.color
        completeButton.alpha = isCompleted ? 0.3 : 1.0
    }
    
    private func formatDaysString(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder10 == 1 && remainder100 != 11 { return "\(count) день" }
        if [2, 3, 4].contains(remainder10) && ![12, 13, 14].contains(remainder100) { return "\(count) дня" }
        return "\(count) дней"
    }
}
