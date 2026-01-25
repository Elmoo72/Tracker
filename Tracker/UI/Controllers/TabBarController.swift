import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
        
        // Подписываемся на изменения локализации
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localizationDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func localizationDidChange() {
        updateTabBarTitles()
    }
    
    private func updateTabBarTitles() {
        tabBar.items?[0].title = "trackers_tab".localized
        tabBar.items?[1].title = "statistics_tab".localized
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateTabBarColors()
        }
    }
    
    private func setupTabs() {
        let trackersVC = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: "trackers_tab".localized,
            image: UIImage(named: "trackers"),
            tag: 0
        )
        
        let statsVC = StatisticViewController()
        statsVC.tabBarItem = UITabBarItem(
            title: "statistics_tab".localized, 
            image: UIImage(named: "statistic"),
            tag: 1
        )
        
        viewControllers = [trackersNav, statsVC]
    }
    
    private func setupTabBarAppearance() {
        // Настройка внешнего вида TabBar
        updateTabBarColors()
        
        // Настройка шрифта для заголовков
        let appearance = UITabBarItem.appearance()
        appearance.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ], for: .normal)
        appearance.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ], for: .selected)
    }
    
    private func updateTabBarColors() {
        tabBar.backgroundColor = .YPWhite
        tabBar.tintColor = .YPBlue
        tabBar.unselectedItemTintColor = .YPGray
        
        // Линия-разделитель сверху с адаптивным цветом
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.separator.cgColor
    }
}
