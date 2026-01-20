import UIKit

protocol ScheduleDelegate: AnyObject {
    func didUpdateSchedule(_ selectedDays: Set<WeekDay>)
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleDelegate?
    private var selectedDays: Set<WeekDay> = []
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
        tv.dataSource = self
        tv.layer.cornerRadius = 16
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        title = "Расписание"
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        let doneButton = UIButton()
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .ypBlack
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneTap), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 7 * 75),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneTap() {
        delegate?.didUpdateSchedule(selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 7 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        let day = WeekDay.allCases[indexPath.row]
        cell.textLabel?.text = day.localizedName
        cell.backgroundColor = .ypBackground
        
        let switchView = UISwitch()
        switchView.onTintColor = .ypBlue
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        return cell
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        if sender.isOn { selectedDays.insert(day) }
        else { selectedDays.remove(day) }
    }
}
