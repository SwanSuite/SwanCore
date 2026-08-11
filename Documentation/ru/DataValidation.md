# Валидация данных и текстовые стратегии (DataValidation)

Модуль `SwanCore` предоставляет инструменты для валидации текстовых данных (Email, номера телефонов, URL-адреса) на основе системного механизма `NSDataDetector`, адаптированные под модель многопоточности Swift 6 Strict Concurrency.

## ✨ Ключевые особенности
* **Проверка полных границ (Full-Boundary Matching)**: В отличие от стандартного `NSDataDetector`, выполняющего поиск подстрок внутри текста (что допускает валидацию строк, содержащих произвольные завершающие символы), метод `matchesFullBoundary` требует, чтобы обнаруженный диапазон точно соответствовал полной длине строки (`result.range == range`).
* **Единый контракт стратегий**: Протокол `StringValidator` вводит унифицированный интерфейс для валидаторов, обеспечивая автоматический синтез соответствия протоколам `Hashable` и `Equatable` на основе уникального строкового идентификатора `id`.
* **Производительность и безопасность**: Компоненты выполняются быстрее стандартных регулярных выражений, корректно обрабатывают международные Unicode-домены и нативно поддерживают протокол `Sendable` для безопасного использования в асинхронных контекстах.

---

## 🚀 Использование встроенных стратегий

Модуль содержит три базовые атомарные стратегии валидации, покрывающие распространенные сценарии использования в приложении:

```swift
import SwanCore
import Foundation

do {
    // 1. Валидация Email (использует схему mailto под капотом)
    let emailValidator = try EmailValidator()
    print(emailValidator.validate("developer@swankit.io")) // true
    print(emailValidator.validate("developer@swankit.io trailing text")) // false

    // 2. Валидация номеров телефонов
    let phoneValidator = try PhoneNumberValidator()
    print(phoneValidator.validate("+1234567890")) // true
    print(phoneValidator.validate("Call me at +1234567890")) // false (нарушена граница)

    // 3. Валидация ссылок с опциональной фильтрацией схемы
    let httpsValidator = try LinkValidator(scheme: "https")
    print(httpsValidator.validate("https://anobisoft.com")) // true
    print(httpsValidator.validate("http://anobisoft.com"))  // false (не совпала схема)
} catch {
    print("Ошибка инициализации системного детектора: \(error)")
}
```

---

## 🏗 Интеграция в коллекции и идентификация

Благодаря встроенной реализации `Hashable`, стратегии валидации могут быть сгруппированы, переданы в качестве зависимостей или использованы как ключи словарей для динамической маршрутизации форм ввода:

```swift
let customID = "profile_email_input"
let validatorA = try EmailValidator(id: customID)
let validatorB = try EmailValidator(id: customID)

// Сравнение по ID
print(validatorA == validatorB) // true

// Использование в качестве ключа хэш-таблицы
var validationRules: [AnyHashable: String] = [:]
validationRules[validatorA] = "Поле должно содержать валидный Email адрес"

print(validationRules[validatorB] ?? "Правило не найдено") 
// Выведет: "Поле должно содержать валидный Email адрес"
```

---

## 🛠 Реализация пользовательских стратегий валидации

Система может быть расширена путем определения пользовательской структуры, соответствующей протоколу `StringValidator`. Пример реализации для проверки 6-значного кода подтверждения:

```swift
public struct VerificationCodeValidator: StringValidator {
    public let id: String
    
    public init(id: String = UUID().uuidString) {
        self.id = id
    }
    
    public func validate(_ text: String) -> Bool {
        // Проверяет, что строка состоит ровно из 6 цифр
        return text.count == 6 && text.allSatisfy { \$0.isNumber }
    }
}
```
