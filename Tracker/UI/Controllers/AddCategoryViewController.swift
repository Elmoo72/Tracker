import UIKit

final class AddCategoryViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .YPBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .YPBackground
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = .YPBlack
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.YPWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .YPGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    var onCategoryAdded: ((String) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTheme()
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .YPWhite
        
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        updateColorsForCurrentTheme()
    }
    
    private func setupNavigationBar() {
        title = "Новая категория"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .YPRed
    }
    
    private func updateColorsForCurrentTheme() {
        view.backgroundColor = .YPWhite
        textField.backgroundColor = .YPBackground
        textField.textColor = .YPBlack
        titleLabel.textColor = .YPBlack
        
        // Принудительно обновляем layer цвета
        textField.layer.backgroundColor = UIColor.YPBackground.cgColor
        
        // Обновляем placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название категории",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.YPGray]
        )
        
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText ? .YPBlack : .YPGray
    }
    
    @objc private func textFieldDidChange() {
        updateDoneButtonState()
    }
    
    @objc private func doneButtonTapped() {
        guard let categoryTitle = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !categoryTitle.isEmpty else { return }
        
        onCategoryAdded?(categoryTitle)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}