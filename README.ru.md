![Logo](SwanCore.png)

[![Swift 6 Concurrency](https://img.shields.io/badge/Swift_6-Concurrency_Ready-52B1F4.svg)](https://developer.apple.com/documentation/swift/adoptingswift6)
[![SPM Compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-52B1F4.svg)](https://swift.org/package-manager/)
![Platforms](https://img.shields.io/badge/platforms-macOS_%7C_iOS_%7C_tvOS_%7C_watchOS-lightgrey.svg)
![Repository Size](https://img.shields.io/github/repo-size/SwanSuite/SwanCore-lightgrey.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwanSuite/SwanCore?color=52B1F4)

[![Language](https://img.shields.io/badge/Language-English-EBAC73.svg)](README.md)

Низкоуровневый пакет вспомогательных инструментов, легковесных моделей данных и расширений для языка Swift, оптимизированный для обеспечения высокой производительности, минимального выделения памяти и строгой потокобезопасности в модели многопоточности Swift 6 Strict Concurrency.

Пакет не содержит внешних зависимостей и предназначен для решения рутинных инфраструктурных задач без накладных расходов на динамическую диспетчеризацию времени выполнения.

---

## 💻 Системные требования и среда
* **Язык**: Swift 6.0+ (Strict Concurrency Ready)
* **Минимальные платформы**: iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
* **Менеджер зависимостей**: Swift Package Manager (SPM)
* **Внешние зависимости**: Отсутствуют (Zero-Dependency Profile)

---

## 🗺 Архитектурная карта модулей и навигация

Полная техническая документация по каждому компоненту распределена по изолированным файлам в директории `Documentation/ru/`. Ниже приведена таблица соответствия модулей и зон их ответственности со ссылками на проектную спецификацию:

| Компонент / Файл документации | Системный токен / Типы данных | Краткое техническое описание и зона ответственности |
| :--- | :--- | :--- |
| 🛡 [Locking.md](Documentation/ru/Locking.md) | `Locking`, `RWLocking` | Унифицированный интерфейсный слой для абстрагирования примитивов потокобезопасности и системных блокировок. |
| ⛓ [Lists.md](Documentation/ru/Lists.md) | `List<T, Lock>`, `+>`, `<+`, `^` | Двусвязный список с константными мутациями границ **O(1)**, итератором со сбросом блокировок (Lock Dropping) и мнемоникой L-Shape. |
| 📦 [Cache.md](Documentation/ru/Cache.md) | `Cache<K, V>`, `Costable` | Потокобезопасная объектная обертка над `NSCache` для поддержки Value-типов, перехвата выселения данных и лимита стоимости. |
| 📝 [Version.md](Documentation/ru/Version.md) | `Version<Stage>`, `VersionFormatter` | Модель версионирования программного обеспечения на базе компиляции синтаческого шаблона в абстрактное дерево (AST). |
| 💾 [Storage.md](Documentation/ru/Storage.md) | `PersistentStorage`, `FileStorage` | Слой абстракции сохранения данных (Repository Pattern) с бэкендами `UserDefaults` (плоские ключи) и `FileStorage` (атомарная запись). |
| ⚙️ [Coding.md](Documentation/ru/Coding.md) | `CustomizableCodingKeyMapping` | Вспомогательные расширения `Codable` для автовывода типов без `T.self`, Fluent API и сквозной трансформации регистров ключей. |
| 📊 [DictionaryRawRepresentable.md](Documentation/ru/DictionaryRawRepresentable.md) | `resolveRepresentation` | Функциональные трансформации словарей, безалокационные ленивые стримы и типобезопасный мост для перечислений. |
| 🔍 [DataValidation.md](Documentation/ru/DataValidation.md) | `StringValidator`, `EmailValidator` | Строгая валидация текстовых данных на базе `NSDataDetector` с проверкой полного совпадения границ (`matchesFullBoundary`). |
| 🕸 [WeakDictionary.md](Documentation/ru/WeakDictionary.md) | `WeakDictionary<K, V>` | Потокобезопасная коллекция со слабыми ссылками (`weak`) на элементы и ленивой очисткой удаленных ARC-подсистемой узлов. |
| 🌐 [Localization.md](Documentation/ru/Localization.md) | `Bundle.UIKit`, `localized()` | Инвертированный синтаксис локализации строк, интеграция с нативными переводами `UIKit` и инструмент экспорта таблиц. |
| 📑 [BundleMetadata.md](Documentation/ru/BundleMetadata.md) | `Bundle.appVersion`, `Info.plist` | Вычисляемые инлайновые свойства-хелперы для атомарного извлечения параметров конфигурационного манифеста приложения. |
| 💠 [Emptiable.md](Documentation/ru/Emptiable.md) | `Emptiable`, `Blankable`, `~?`, `~!` | Базовые протоколы для детерминации пустого состояния типа и операторы безопасного разворачивания опционалов без рантайм-ветвлений. |

---

## 🛠 Быстрый старт (Установка)

Интеграция пакета осуществляется через Swift Package Manager. Добавьте зависимость в ваш файл `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SwanSuite/SwanCore", from: "1.0.0")
]
```

И подключите целевой таргет в блок конфигурации модуля:

```swift
targets: [
    .target(
        name: "MyApplicationModule",
        dependencies: ["SwanCore"]
    )
]
```
