import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didUpdateSchedule(_ selectedDays: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    private let tableView = UITableView()
    private let doneButton = UIButton()
    
    private let days = WeekDay.allCases
    private var selectedDays: Set<WeekDay> = []
    
    init(selectedDays: [WeekDay]) {
        self.selectedDays = Set(selectedDays)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = "Расписание"
        navigationItem.hidesBackButton = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .YPbackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .black
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        [tableView, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didTapDone() {
        let sortedDays = days.filter { selectedDays.contains($0) }
        delegate?.didUpdateSchedule(sortedDays)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { days.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let day = days[indexPath.row]
        cell.textLabel?.text = day.name
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let switchView = UISwitch()
        switchView.onTintColor = .blue
        switchView.isOn = selectedDays.contains(day)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        if indexPath.row == days.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = days[sender.tag]
        if sender.isOn { selectedDays.insert(day) } else { selectedDays.remove(day) }
    }
}
