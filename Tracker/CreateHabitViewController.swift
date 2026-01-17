import UIKit

protocol CreateHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class CreateHabitViewController: UIViewController {
    
    weak var delegate: CreateHabitDelegate?
    private var selectedSchedule: [WeekDay] = []
    
    private let nameTextField = UITextField()
    private let tableView = UITableView()
    private let createButton = UIButton()
    private let cancelButton = UIButton()
    
    private let tableItems = ["Категория", "Расписание"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteYP
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = "Новая привычка"
        
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.backgroundColor = .backgroundYP
        nameTextField.layer.cornerRadius = 16
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .backgroundYP
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.redYP, for: .normal)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.redYP.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.backgroundColor = .grayStatic
        createButton.isEnabled = false
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
        [nameTextField, tableView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4)
        ])
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate() {
        guard let text = nameTextField.text, !text.isEmpty else { return }
        let newTracker = Tracker(
            id: UUID(),
            name: text,
            color: .blueYP,
            emoji: "☀️",
            schedule: selectedSchedule
        )
        delegate?.didCreateTracker(newTracker)
    }
    
    private func validate() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isScheduleValid = !selectedSchedule.isEmpty
        let isValid = isNameValid && isScheduleValid
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .blackYP : .grayStatic
    }
}

extension CreateHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = tableItems[indexPath.row]
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == 1 {
            let scheduleText = selectedSchedule.map { $0.shortName }.joined(separator: ", ")
            cell.detailTextLabel?.text = scheduleText
            cell.detailTextLabel?.textColor = .grayStatic
        }
        
        if indexPath.row == tableItems.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController(selectedDays: selectedSchedule)
            scheduleVC.delegate = self
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validate()
    }
}

extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func didUpdateSchedule(_ selectedDays: [WeekDay]) {
        self.selectedSchedule = selectedDays
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        validate()
    }
}
