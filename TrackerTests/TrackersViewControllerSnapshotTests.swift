import XCTest
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    
    var sut: TrackersViewController!
    
    override func setUp() {
        super.setUp()
        sut = TrackersViewController()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Main Screen Snapshot Tests
    
    func testMainScreenEmptyState() {
        // Given - создаем главный экран в пустом состоянии
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812)) // iPhone X size
        let navigationController = UINavigationController(rootViewController: sut)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // When - загружаем view и ждем завершения layout
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()
        
        // Ждем немного для завершения анимаций
        let expectation = XCTestExpectation(description: "Layout completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then - делаем скриншот
        let snapshot = takeSnapshot(of: navigationController.view)
        XCTAssertNotNil(snapshot, "Скриншот должен быть создан")
        
        // Сохраняем эталонный скриншот (при первом запуске)
        saveReferenceSnapshot(snapshot, testName: "testMainScreenEmptyState")
        
        // Сравниваем с эталоном
        compareWithReference(snapshot, testName: "testMainScreenEmptyState")
    }
    
    func testMainScreenWithLightMode() {
        // Given - принудительно устанавливаем светлую тему
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        let navigationController = UINavigationController(rootViewController: sut)
        window.rootViewController = navigationController
        
        // Принудительно устанавливаем светлую тему
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .light
        }
        
        window.makeKeyAndVisible()
        
        // When
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()
        
        let expectation = XCTestExpectation(description: "Layout completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let snapshot = takeSnapshot(of: navigationController.view)
        XCTAssertNotNil(snapshot, "Скриншот должен быть создан")
        
        saveReferenceSnapshot(snapshot, testName: "testMainScreenWithLightMode")
        compareWithReference(snapshot, testName: "testMainScreenWithLightMode")
    }
    
    func testMainScreenWithDarkMode() {
        // Given - принудительно устанавливаем темную тему
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        let navigationController = UINavigationController(rootViewController: sut)
        window.rootViewController = navigationController
        
        // Принудительно устанавливаем темную тему
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .dark
        }
        
        window.makeKeyAndVisible()
        
        // When
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()
        
        let expectation = XCTestExpectation(description: "Layout completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let snapshot = takeSnapshot(of: navigationController.view)
        XCTAssertNotNil(snapshot, "Скриншот должен быть создан")
        
        saveReferenceSnapshot(snapshot, testName: "testMainScreenWithDarkMode")
        compareWithReference(snapshot, testName: "testMainScreenWithDarkMode")
    }
    
    func testMainScreenPortraitOrientation() {
        // Given - тестируем портретную ориентацию
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        let navigationController = UINavigationController(rootViewController: sut)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // When
        sut.loadViewIfNeeded()
        sut.view.layoutIfNeeded()
        
        let expectation = XCTestExpectation(description: "Layout completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let snapshot = takeSnapshot(of: navigationController.view)
        XCTAssertNotNil(snapshot, "Скриншот должен быть создан")
        
        saveReferenceSnapshot(snapshot, testName: "testMainScreenPortraitOrientation")
        compareWithReference(snapshot, testName: "testMainScreenPortraitOrientation")
    }
}

// MARK: - Snapshot Helper Methods
extension TrackersViewControllerSnapshotTests {
    
    private func takeSnapshot(of view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
    
    private func saveReferenceSnapshot(_ image: UIImage?, testName: String) {
        guard let image = image else { return }
        
        let snapshotDirectory = getSnapshotDirectory()
        let snapshotURL = snapshotDirectory.appendingPathComponent("\(testName).png")
        
        // Создаем директорию если её нет
        try? FileManager.default.createDirectory(at: snapshotDirectory, withIntermediateDirectories: true)
        
        // Сохраняем только если файла еще нет (эталонный скриншот)
        if !FileManager.default.fileExists(atPath: snapshotURL.path) {
            if let data = image.pngData() {
                try? data.write(to: snapshotURL)
                print("✅ Сохранен эталонный скриншот: \(snapshotURL.path)")
            }
        }
    }
    
    private func compareWithReference(_ image: UIImage?, testName: String) {
        guard let image = image else {
            XCTFail("Не удалось создать скриншот для сравнения")
            return
        }
        
        let snapshotDirectory = getSnapshotDirectory()
        let referenceURL = snapshotDirectory.appendingPathComponent("\(testName).png")
        
        // Проверяем существование эталонного скриншота
        guard FileManager.default.fileExists(atPath: referenceURL.path) else {
            XCTFail("Эталонный скриншот не найден: \(referenceURL.path). Запустите тест еще раз для создания эталона.")
            return
        }
        
        // Загружаем эталонный скриншот
        guard let referenceData = try? Data(contentsOf: referenceURL),
              let referenceImage = UIImage(data: referenceData) else {
            XCTFail("Не удалось загрузить эталонный скриншот")
            return
        }
        
        // Сравниваем изображения
        guard let currentData = image.pngData(),
              let referenceImageData = referenceImage.pngData() else {
            XCTFail("Не удалось получить данные изображений для сравнения")
            return
        }
        
        if currentData != referenceImageData {
            // Сохраняем текущий скриншот для анализа различий
            let failedURL = snapshotDirectory.appendingPathComponent("\(testName)_FAILED.png")
            try? currentData.write(to: failedURL)
            
            XCTFail("❌ Скриншот не соответствует эталону! Текущий скриншот сохранен как: \(failedURL.path)")
        } else {
            print("✅ Скриншот соответствует эталону: \(testName)")
        }
    }
    
    private func getSnapshotDirectory() -> URL {
        let testBundle = Bundle(for: type(of: self))
        let testDirectory = testBundle.bundleURL.deletingLastPathComponent()
        return testDirectory
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent("\(type(of: self))")
    }
}

// MARK: - Test for Background Color Change Verification
extension TrackersViewControllerSnapshotTests {
    
    func testMainScreenWithChangedBackgroundColor() {
        // Given - создаем контроллер с измененным цветом фона для проверки
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        let navigationController = UINavigationController(rootViewController: sut)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        // When - загружаем view и меняем цвет фона
        sut.loadViewIfNeeded()
        
        // ВАЖНО: Этот тест должен провалиться, если изменить цвет фона
        // Раскомментируйте следующую строку для проверки работы скриншот-тестов:
        // sut.view.backgroundColor = .systemRed
        
        sut.view.layoutIfNeeded()
        
        let expectation = XCTestExpectation(description: "Layout completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let snapshot = takeSnapshot(of: navigationController.view)
        XCTAssertNotNil(snapshot, "Скриншот должен быть создан")
        
        saveReferenceSnapshot(snapshot, testName: "testMainScreenWithChangedBackgroundColor")
        compareWithReference(snapshot, testName: "testMainScreenWithChangedBackgroundColor")
    }
}
