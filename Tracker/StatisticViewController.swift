import UIKit

final class StatisticViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteYP
        
        navigationItem.title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
