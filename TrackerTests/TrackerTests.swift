import XCTest
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackersViewControllerInitialization() {
        let viewController = TrackersViewController()
        
        viewController.loadViewIfNeeded()
        
        XCTAssertNotNil(viewController.view, "View должен быть инициализирован")
        XCTAssertEqual(viewController.view.backgroundColor, .YPWhite, "Фон должен быть YPWhite")
    }
    
    func testStatisticViewControllerInitialization() {
        let viewController = StatisticViewController()
        
        viewController.loadViewIfNeeded()
        
        XCTAssertNotNil(viewController.view, "View должен быть инициализирован")
        XCTAssertEqual(viewController.navigationItem.title, "statistics_tab".localized, "Заголовок должен быть установлен")
    }
    
    func testAnalyticsServiceSingleton() {
        let service1 = AnalyticsService.shared
        let service2 = AnalyticsService.shared
        
        XCTAssertTrue(service1 === service2, "AnalyticsService должен быть синглтоном")
    }
    
    func testStatisticsServiceSingleton() {
        let service1 = StatisticsService.shared
        let service2 = StatisticsService.shared
        
        XCTAssertTrue(service1 === service2, "StatisticsService должен быть синглтоном")
    }
    
    func testAnalyticsEventStructure() {
        let openEvent = AnalyticsEvent.open(screen: .main)
        let clickEvent = AnalyticsEvent.click(screen: .main, item: .addTrack)
        
        XCTAssertEqual(openEvent.name, "open", "Событие открытия должно иметь правильное имя")
        XCTAssertEqual(clickEvent.name, "click", "Событие клика должно иметь правильное имя")
        
        XCTAssertEqual(openEvent.params["event"] as? String, "open", "Параметр event должен быть правильным")
        XCTAssertEqual(openEvent.params["screen"] as? String, "Main", "Параметр screen должен быть правильным")
        
        XCTAssertEqual(clickEvent.params["item"] as? String, "add_track", "Параметр item должен быть правильным")
    }
    
    func testTrackersViewControllerHasNavigationItems() {
        let viewController = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        viewController.loadViewIfNeeded()
        
        XCTAssertNotNil(viewController.navigationItem.leftBarButtonItem, "Должна быть кнопка слева (плюс)")
        XCTAssertNotNil(viewController.navigationItem.rightBarButtonItem, "Должна быть кнопка справа (дата)")
        
        let addButton = viewController.navigationItem.leftBarButtonItem?.customView as? UIButton
        XCTAssertNotNil(addButton, "Левая кнопка должна быть UIButton")
        XCTAssertNotNil(addButton?.currentImage, "У кнопки должно быть изображение")
    }
}
