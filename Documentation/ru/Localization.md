# Вспомогательные инструменты локализации (Localization Helpers)

Легковесный набор расширений для типов `Bundle` и `String`, упрощающий интеграцию и использование подсистемы локализации Foundation. Компонент предоставляет выразительный синтаксис для работы с ресурсами локализации с нулевыми накладными расходами (zero-performance overhead).

---

## Архитектура и основные компоненты

### 1. Расширения контекста Bundle
* **`localized(_:value:table:)`**: Извлечение строки по ключу через нативный метод `localizedString(forKey:...)`.
* **`localized(_:value:table:locale:with:)`**: Локализация строк с поддержкой правил конкретной локали (`Locale`) и динамической инъекцией аргументов через последовательность `CVarArg`.
* **`fetchLocalizableStrings()`**: Синхронный парсинг и десериализация содержимого файла `Localizable.strings` в плоский словарь `[String: String]`. Метод позволяет проводить аудит доступных переводов, осуществлять реверс-инжиниринг или извлекать недокументированные системные ключи внутри сторонних или системных бандлов.
* **`Bundle.UIKit`**: Статическое свойство для быстрого доступа к ресурсам системного фреймворка `UIKit` на базе рефлексии класса `UIApplication`. Доступно для платформ `iOS` и `tvOS`.

### 2. Выразительный интерфейс типа String
* **`localized`**: Свойство-вызов для быстрой локализации ключа с использованием ресурсов главного бандла приложения (`Bundle.main`).
* **`localized(_:value:table:)`**: Метод локализации строки с явным указанием целевого экземпляра `Bundle`.

---

## Примеры использования

### 1. Модульная локализация с явным указанием бандла
Явное объявление и передача бандла модуля гарантирует изоляцию ресурсов, корректное разрешение зависимостей и предсказуемость выполнения в многомодульных проектах.

```swift
public enum FeatureStrings {
    // Явное определение бандла текущего модуля
    private static let moduleBundle = Bundle(for: CurrentModuleMarker.self)

    public static var moduleTitle: String {
        "feature_dashboard_title".localized(moduleBundle)
    }
    
    public static func welcomeAlert(user: String) -> String {
        "welcome_user_format".localized(moduleBundle, with: user)
    }
}
```

### 2. Использование системных переводов Apple (UIKit)
Переиспользование официальных ресурсов локализации Apple через свойство `.UIKit` устраняет необходимость хардкода и дублирования стандартных операционных меток (например, "Назад", "Готово").

```swift
// Автоматически извлекает системный перевод для кнопок "Cancel" или "Done" под язык устройства
let systemCancelLabel = "Cancel".localized(.UIKit)
let systemDoneLabel = "Done".localized(.UIKit)
```

### 3. Инспекция системных локализаций
Метод `fetchLocalizableStrings()` позволяет выгрузить скомпилированные строки фреймворка для проведения диагностики или анализа структуры ключей.

```swift
#if os(iOS) || os(tvOS)
if let nativeTranslations = try? Bundle.UIKit.fetchLocalizableStrings() {
    for (key, translation) in nativeTranslations.prefix(10) {
        print("UIKit Key: \(key) -> [\(translation)]")
    }
}
#endif
```
