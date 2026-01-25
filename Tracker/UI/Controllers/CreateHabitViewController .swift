import UIKit

// MARK: - Delegate Protocol
protocol CreateHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory category: TrackerCategory)
}

final class CreateHabitViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: CreateHabitDelegate?
    
    // MARK: - Private Properties
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "✨"]
    
    private let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple,
        .systemPink, .systemTeal, .systemIndigo, .systemGray, .brown, .magenta,
        .orange, .blue, .red, .green, .purple, .cyan
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedWeekdays = Set<WeekDay>()
    private var categorySubtitle: String? = nil
    private var selectedCategory: TrackerCategory? = nil
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()
    
    private lazy var contentView = UIView()
    
    private lazy var textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .YPBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.textColor = .YPBlack
        tf.font = .systemFont(ofSize: 17)
        tf.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .YPRed
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        return label
    }()
    
    private lazy var tableViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .YPBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        cv.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        cv.register(TrackerSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return cv
    }()
    
    private lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Отменить", for: .normal)
        btn.setTitleColor(.YPRed, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.borderColor = UIColor.YPRed.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var createButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Создать", for: .normal)
        btn.setTitleColor(.YPWhite, for: .normal)
        btn.backgroundColor = .YPGray
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = 16
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTheme()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .YPWhite
        title = "Новая привычка"
        
        view.addSubview(scrollView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        scrollView.addSubview(contentView)
        
        [textFieldContainer, limitLabel, tableViewContainer, collectionView].forEach {
            contentView.addSubview($0)
        }
        textFieldContainer.addSubview(textField)
        tableViewContainer.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        textField.delegate = self
        
        updateColorsForCurrentTheme()
    }
    
    private func updateColorsForCurrentTheme() {
        view.backgroundColor = .YPWhite
        textFieldContainer.backgroundColor = .YPBackground
        textField.textColor = .YPBlack
        tableViewContainer.backgroundColor = .YPBackground
        tableView.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        
        // Принудительно обновляем layer цвета
        textFieldContainer.layer.backgroundColor = UIColor.YPBackground.cgColor
        tableViewContainer.layer.backgroundColor = UIColor.YPBackground.cgColor
        
        // Обновляем placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.YPGray]
        )
        
        // Обновляем состояние кнопки создания
        updateCreateButtonState()
        
        // Перезагружаем таблицу для обновления цветов ячеек
        tableView.reloadData()
    }

    private func setupConstraints() {
        [scrollView, contentView, textField, textFieldContainer, limitLabel,
         cancelButton, createButton, tableView, tableViewContainer, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            textFieldContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textFieldContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 75),

            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: textFieldContainer.centerYAnchor),

            limitLabel.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 8),
            limitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tableViewContainer.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 24),
            tableViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableViewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableViewContainer.heightAnchor.constraint(equalToConstant: 150),

            tableView.topAnchor.constraint(equalTo: tableViewContainer.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableViewContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableViewContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableViewContainer.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: tableViewContainer.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 450),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let text = textField.text ?? ""
        let isTextValid = !text.isEmpty && text.count <= 38
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isScheduleSelected = !selectedWeekdays.isEmpty
        let isCategorySelected = categorySubtitle != nil
        
        limitLabel.isHidden = text.count <= 38
        
        let isFormValid = isTextValid && isEmojiSelected && isColorSelected && isScheduleSelected && isCategorySelected
        
        createButton.isEnabled = isFormValid
        createButton.backgroundColor = isFormValid ? .YPBlack : .YPGray
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        print("Нажата кнопка Создать") // Для отладки
        guard let name = textField.text,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let category = selectedCategory else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: Array(selectedWeekdays)
        )
        
        delegate?.didCreateTracker(newTracker, inCategory: category)
        print("Делегат вызван, закрываем экран")
        dismiss(animated: true)
    }
}

// MARK: - UITableView Logic
extension CreateHabitViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        // Устанавливаем цвета для темной темы
        cell.textLabel?.textColor = .YPBlack
        cell.textLabel?.font = .systemFont(ofSize: 17)
        
        cell.detailTextLabel?.textColor = .YPGray
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = categorySubtitle
        } else {
            cell.textLabel?.text = "Расписание"
            if !selectedWeekdays.isEmpty {
                let sortedDays = selectedWeekdays.sorted { day1, day2 in
                    guard let index1 = WeekDay.weekOrder.firstIndex(of: day1),
                          let index2 = WeekDay.weekOrder.firstIndex(of: day2) else {
                        return day1.rawValue < day2.rawValue
                    }
                    return index1 < index2
                }
                cell.detailTextLabel?.text = sortedDays.count == 7 ? "Каждый день" : sortedDays.map { $0.shortTitle }.joined(separator: ", ")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // Открываем экран выбора категории
            let categoryVC = CategoryViewController()
            categoryVC.onCategorySelected = { [weak self] category in
                self?.selectedCategory = category
                self?.categorySubtitle = category.title
                self?.tableView.reloadData()
                self?.updateCreateButtonState()
            }
            navigationController?.pushViewController(categoryVC, animated: true)
        } else if indexPath.row == 1 {
            let vc = ScheduleViewController()
            vc.onScheduleSelected = { [weak self] days in
                self?.selectedWeekdays = days
                self?.tableView.reloadData() // Полная перезагрузка для обновления шрифтов
                self?.updateCreateButtonState()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UICollectionView Logic
extension CreateHabitViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 18 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 5 }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            let color = colors[indexPath.item]
            cell.configure(with: color, isSelected: color == selectedColor)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 { selectedEmoji = emojis[indexPath.item] }
        else { selectedColor = colors[indexPath.item] }
        collectionView.reloadData() // Перерисовываем всё, чтобы подсветить выбор
        updateCreateButtonState()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = indexPath.section == 0 ? "Emoji" : "Цвет"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 34)
    }
}

extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
