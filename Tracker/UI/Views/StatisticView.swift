import UIKit

final class StatisticView: UIView {
    
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTheme()
        }
    }
    
    private func setupUI() {
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        setupGradientBorder()
        
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textAlignment = .left
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .left
        
        [valueLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        updateColorsForCurrentTheme()
    }
    
    private func setupGradientBorder() {
        gradientLayer.colors = [
            UIColor.YPRed.cgColor,
            UIColor.YPGreen.cgColor,
            UIColor.YPBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let borderLayer = CAShapeLayer()
        borderLayer.lineWidth = 1
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = borderLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if let maskLayer = gradientLayer.mask as? CAShapeLayer {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
            maskLayer.path = path.cgPath
        }
    }
    
    private func updateColorsForCurrentTheme() {
        valueLabel.textColor = .YPBlack
        titleLabel.textColor = .YPBlack
        backgroundColor = .YPBackground
    }
    
    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }
}