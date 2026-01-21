import UIKit

protocol CreateHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class CreateHabitViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CreateHabitDelegate?
    private let trackerStore = TrackerStore(context: PersistentContainer.shared.context)
    
    private var trackerName: String = ""
    private var selectedCategory: String? = "Важное"
    private var selectedSchedule: Set<WeekDay> = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "✨"]
    private let colors: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple, .systemPink, .systemTeal, .systemIndigo, .systemGray, .brown, .magenta, .orange, .blue, .red, .green, .purple, .cyan]
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .onDrag
        return scroll
    }()
    
    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.delegate = self
        tf.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return tf
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.layer.cornerRadius = 16
        tv.backgroundColor = .systemGray6
        tv.isScrollEnabled = false
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        cv.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.isScrollEnabled = false
        return cv
    }()

    private lazy var cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Отменить", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemRed.cgColor
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(cancelTap), for: .touchUpInside)
        return btn
    }()
    
    private lazy var createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Создать", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemGray
        btn.layer.cornerRadius = 16
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(saveTracker), for: .touchUpInside)
        return btn
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Новая привычка"
        setupLayout()
        setupKeyboardHiding()
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        [textField, tableView, collectionView, buttonStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 450),
            
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupKeyboardHiding() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textChanged() {
        trackerName = textField.text ?? ""
        checkValidation()
    }
    
    @objc private func cancelTap() { dismiss(animated: true) }
    
    private func checkValidation() {
        let isReady = !trackerName.isEmpty && selectedEmoji != nil && selectedColor != nil && !selectedSchedule.isEmpty
        createButton.isEnabled = isReady
        createButton.backgroundColor = isReady ? .black : .systemGray
    }
    
    @objc private func saveTracker() {
        guard let emoji = selectedEmoji, let color = selectedColor else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: color,
            emoji: emoji,
            schedule: Array(selectedSchedule)
        )
        
        trackerStore.addNewTracker(newTracker, to: selectedCategory ?? "Важное")
        delegate?.didCreateTracker(newTracker)
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Скрывает клавиатуру при нажатии "Enter"
        return true
    }
}

// MARK: - UITableView
extension CreateHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategory
        } else {
            cell.textLabel?.text = "Расписание"
            let sortedDays = selectedSchedule.sorted { $0.rawValue < $1.rawValue }
            let scheduleText = sortedDays.isEmpty ? "" : sortedDays.map { $0.shortName }.joined(separator: ", ")
            cell.detailTextLabel?.text = scheduleText
        }
        cell.detailTextLabel?.textColor = .systemGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = ScheduleViewController()
            vc.delegate = self
            vc.setupCurrentSchedule(selectedSchedule)
            present(UINavigationController(rootViewController: vc), animated: true)
        }
    }
}

// MARK: - UICollectionView
extension CreateHabitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 18 }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: emojis[indexPath.row], isSelected: emojis[indexPath.row] == selectedEmoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: colors[indexPath.row], isSelected: colors[indexPath.row] == selectedColor)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 36) / 6
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 { selectedEmoji = emojis[indexPath.row] }
        else { selectedColor = colors[indexPath.row] }
        collectionView.reloadSections(IndexSet(integer: indexPath.section))
        checkValidation()
    }
}

// MARK: - ScheduleDelegate
extension CreateHabitViewController: ScheduleDelegate {
    func didUpdateSchedule(_ selectedDays: Set<WeekDay>) {
        self.selectedSchedule = selectedDays
        tableView.reloadData()
        checkValidation()
    }
}
