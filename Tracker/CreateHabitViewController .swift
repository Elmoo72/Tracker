import UIKit


protocol CreateHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class CreateHabitViewController: UIViewController {
    weak var delegate: CreateHabitDelegate?
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "✨"]
    
    // ИСПОЛЬЗУЕМ .YPBlue и .YPGray (через точку)
    private let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen,
        .YPBlue, .systemPurple, .systemPink, .YPGray,
        .systemCyan, .brown, .magenta, .darkGray, .orange, .blue, .red, .green, .purple, .cyan
    ]
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = .YPBackground // ИСПРАВЛЕНО
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .YPWhite // ИСПРАВЛЕНО
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .YPWhite 
        setupUI()
    }
    
    private func setupUI() {
        [textField, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            collectionView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
