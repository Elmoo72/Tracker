import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    var onScheduleSelected: ((Set<WeekDay>) -> Void)?
    private var selectedDays: Set<WeekDay> = []
    private let days = WeekDay.weekOrder
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .YPBackground
        tv.layer.cornerRadius = 16
        tv.isScrollEnabled = false
        tv.separatorStyle = .singleLine
        tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "WeekdayCell")
        return tv
    }()
    
    private lazy var doneButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .YPBlack
        btn.setTitle("Готово", for: .normal)
        btn.setTitleColor(.YPWhite, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.layer.cornerRadius = 16
        btn.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
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
        navigationItem.title = "Расписание"
        navigationItem.hidesBackButton = true
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        updateColorsForCurrentTheme()
    }
    
    private func updateColorsForCurrentTheme() {
        view.backgroundColor = .YPWhite
        tableView.backgroundColor = .YPBackground
        doneButton.backgroundColor = .YPBlack
        doneButton.setTitleColor(.YPWhite, for: .normal)
        
        // Принудительно обновляем layer цвета
        tableView.layer.backgroundColor = UIColor.YPBackground.cgColor
    }
    
    private func setupConstraints() {
        [tableView, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(days.count * 75)),
    
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = days[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    @objc private func doneTapped() {
        onScheduleSelected?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let day = days[indexPath.row]
        cell.textLabel?.text = day.localizedName
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .YPBlack
        
        let switchView = UISwitch()
        switchView.onTintColor = .YPBlue
        switchView.isOn = selectedDays.contains(day)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        cell.accessoryView = switchView
      
        if indexPath.row == days.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
