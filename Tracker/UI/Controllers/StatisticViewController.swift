import UIKit

final class StatisticViewController: UIViewController {
    
    private let statisticsService = StatisticsService.shared
    private var emptyStateView: EmptyStateView?
    private var statisticView: StatisticView?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "statistics_tab".localized
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .YPBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTheme()
        }
    }
    
    private func setupUI() {
        navigationItem.title = "statistics_tab".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Добавляем лейбл на экран
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        updateColorsForCurrentTheme()
        
        // Подписываемся на изменения локализации
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(localizationDidChange),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
        
        // Подписываемся на изменения в трекерах для обновления статистики
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatistics),
            name: NSNotification.Name("TrackerRecordChanged"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func localizationDidChange() {
        navigationItem.title = "statistics_tab".localized
        titleLabel.text = "statistics_tab".localized
        updateStatistics()
    }
    
    @objc private func updateStatistics() {
        let completedCount = statisticsService.getCompletedTrackersCount()
        
        if completedCount == 0 {
            showEmptyState()
        } else {
            showStatistics(completedCount: completedCount)
        }
    }
    
    private func showEmptyState() {
        statisticView?.removeFromSuperview()
        statisticView = nil
        
        if emptyStateView == nil {
            emptyStateView = EmptyStateView(
                message: "statistics_empty_message".localized,
                image: UIImage(named: "3")
            )
            emptyStateView?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(emptyStateView!)
            
            NSLayoutConstraint.activate([
                emptyStateView!.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                emptyStateView!.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                emptyStateView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                emptyStateView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            ])
        }
        
        emptyStateView?.isHidden = false
    }
    
    private func showStatistics(completedCount: Int) {
        emptyStateView?.isHidden = true
        
        if statisticView == nil {
            statisticView = StatisticView()
            statisticView?.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(statisticView!)
            
            NSLayoutConstraint.activate([
                statisticView!.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
                statisticView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                statisticView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                statisticView!.heightAnchor.constraint(equalToConstant: 90)
            ])
        }
        
        statisticView?.configure(
            value: completedCount,
            title: "completed_trackers".localized
        )
        statisticView?.isHidden = false
    }
    
    private func updateColorsForCurrentTheme() {
        view.backgroundColor = .YPWhite
        titleLabel.textColor = .YPBlack
    }
}
