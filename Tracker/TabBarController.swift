import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
    }
    
    private func setupTabs() {
        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackers"),
            tag: 0
        )
        
        let statsVC = StatisticViewController()
        statsVC.tabBarItem = UITabBarItem(
            title: "Статистика", 
            image: UIImage(named: "statistic"),
            tag: 1
        )
        
        viewControllers = [trackersNav, statsVC]
    }
    
    private func setupTabBarAppearance() {
        // Настройка внешнего вида TabBar
        tabBar.backgroundColor = .white
        tabBar.tintColor = UIColor(named: "YPBlue") ?? .systemBlue
        tabBar.unselectedItemTintColor = UIColor(named: "YPGray") ?? .systemGray
        
        // Линия-разделитель сверху
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.separator.cgColor
        
        // Настройка шрифта для заголовков
        let appearance = UITabBarItem.appearance()
        appearance.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ], for: .normal)
        appearance.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ], for: .selected)
    }
}
