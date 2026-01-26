# Инструкция по подключению AppMetrica

## Проблема
Модуль `AppMetricaCore` не найден, хотя пакет добавлен через SPM.

## Решение

### 1. Проверьте подключение в Xcode:
- Откройте проект в Xcode
- Перейдите в Project Navigator → Tracker (корневая папка)
- Выберите target "Tracker"
- Перейдите на вкладку "General"
- В разделе "Frameworks, Libraries, and Embedded Content" должен быть `AppMetricaCore`

### 2. Если пакет не отображается:
- Перейдите в File → Add Package Dependencies
- Введите URL: `https://github.com/appmetrica/appmetrica-sdk-ios`
- Выберите версию 5.0.0 или новее
- Убедитесь, что выбран target "Tracker"
- Добавьте библиотеку `AppMetricaCore`

### 3. Альтернативные имена модулей:
Попробуйте один из этих импортов вместо `AppMetricaCore`:
```swift
import AppMetrica
import YandexMobileMetrica
```

### 4. После успешного подключения раскомментируйте код:

**В Tracker/AppDelegate.swift:**
```swift
import AppMetricaCore // или другое правильное имя

// В методе application(_:didFinishLaunchingWithOptions:)
if let configuration = AppMetricaConfiguration(apiKey: "4c7c1062-4c1f-494c-aa85-05555623ce28") {
    AppMetrica.activate(with: configuration)
}
```

**В Tracker/Services/AnalyticsService.swift:**
```swift
import AppMetricaCore // или другое правильное имя

// В методе report(event:params:)
AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
    print("AppMetrica report error: \(error.localizedDescription)")
})
```

## Текущее состояние
Сейчас аналитика работает только в режиме логирования в консоль. События отправляются, но не передаются в AppMetrica до правильного подключения библиотеки.