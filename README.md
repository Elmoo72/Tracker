# Tracker

iOS-приложение для формирования и отслеживания полезных привычек.

## Описание

Tracker помогает пользователю организовать ежедневные привычки: создавать трекеры с расписанием, группировать их по категориям, отмечать выполнение и просматривать статистику. Каждый трекер можно настроить — выбрать эмодзи и цвет. Данные хранятся локально с помощью Core Data.

## Функциональность

- Создание привычек с именем, категорией, цветом и эмодзи
- Выбор расписания: любые дни недели
- Категоризация трекеров
- Отметка выполнения за конкретную дату через календарь
- Фильтрация и поиск трекеров
- Экран статистики: общий счёт, процент выполнения
- Онбординг при первом запуске
- Аналитика действий пользователя (AppMetrica)
- Локализация (поддержка нескольких языков)

## Технологии

- **Язык:** Swift
- **UI:** UIKit (программная вёрстка + Collection/Table Views)
- **Архитектура:** MVVM + Custom Stores
- **Хранение:** Core Data
- **Аналитика:** AppMetrica (YandexMobileMetrica)
- **Минимальная версия iOS:** 13.0

## Структура проекта

```
Tracker/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Presentation/
│   ├── Onboarding/
│   │   ├── OnboardingViewController.swift
│   │   └── OnboardingPageViewController.swift
│   ├── Trackers/
│   │   ├── TrackersViewController.swift
│   │   └── TrackerCollectionViewCell.swift
│   ├── Create/
│   │   ├── CreateHabitViewController.swift
│   │   └── ScheduleViewController.swift
│   ├── Category/
│   │   ├── CategoryViewController.swift
│   │   ├── CategoryViewModel.swift
│   │   └── AddCategoryViewController.swift
│   ├── Filters/
│   │   └── FiltersViewController.swift
│   ├── Statistics/
│   │   └── StatisticViewController.swift
│   └── TabBar/
│       └── TabBarController.swift
├── Models/
│   ├── Tracker.swift
│   ├── TrackerCategory.swift
│   ├── TrackerRecord.swift
│   └── WeekDay.swift
├── Store/
│   ├── TrackerStore.swift
│   ├── TrackerCategoryStore.swift
│   ├── TrackerRecordStore.swift
│   └── PersistentContainer.swift
├── Services/
│   ├── StatisticsService.swift
│   ├── AnalyticsService.swift
│   ├── AnalyticsReporter.swift
│   └── AnalyticsEvent.swift
└── Extensions/
    ├── UIColor+Extensions.swift
    └── String+Localization.swift
```

## Установка зависимостей

Проект использует **CocoaPods**. Перед запуском выполните:

```bash
pod install
```

Затем откройте `Tracker.xcworkspace`.

## Зависимости

- **AppMetricaCore** — аналитика пользовательских событий

## Запуск

1. Клонируйте репозиторий
2. Выполните `pod install` в директории проекта
3. Откройте `Tracker.xcworkspace` в Xcode
4. Выберите симулятор или устройство с iOS 13.0+
5. Нажмите **Run** (⌘R)

## Требования

- Xcode 14+
- iOS 13.0+
- CocoaPods
