# Валидация данных и текстовые стратегии (DataValidation)

Модуль `SwanCore` предоставляет высокопроизводительные инструменты для строгой валидации текстовых данных (Email, номера телефонов, ссылки) на основе системного механизма `NSDataDetector`, адаптированные под модель многопоточности Swift 6 Strict Concurrency.

## ✨ Ключевые особенности
* **Проверка жестких границ (Full-Boundary Matching)**: В отличие от стандартного `NSDataDetector`, который ищет подстроки внутри текста (из-за чего мусорная строка с номером телефона считается валидной), метод `matchesFullBoundary` требует, чтобы найденный диапазон совпадал со всей длиной строки (`result.range == range`).
* **Единый контракт стратегий**: Протокол `StringValidator` вводит унифицированный интерфейс для любых валидаторов, автоматически реализуя протоколы `Hashable` и `Equatable` на основе уникального строкового идентификатора `id`.
* **Быстродействие и безопасность**: Компоненты работают на порядок быстрее регулярных выражений, корректно обрабатывают сложные международные Unicode-домены и нативно поддерживают `Sendable` для безопасного использования в асинхронных контекстах.

---

## 🚀 Использование готовых стратегий

Модуль содержит три готовые атомарные стратегии валидации, закрывающие 90% повседневных задач приложения:

```swift
import SwanCore
import Foundation

do {
    // 1. Валидация Email (использует схему mailto под капотом)
    let emailValidator = try EmailValidator()
    print(emailValidator.validate("developer@swankit.io")) // true
    print(emailValidator.validate("developer@swankit.io мусор")) // false

    // 2. Валидация номеров телефонов
    let phoneValidator = try PhoneNumberValidator()
    print(phoneValidator.validate("+1234567890")) // true
    print(phoneValidator.validate("Позвони мне на +1234567890")) // false (нарушена граница)

    // 3. Валидация ссылок с опциональной фильтрацией схемы
    let httpsValidator = try LinkValidator(scheme: "https")
    print(httpsValidator.validate("https://anobisoft.com")) // true
    print(httpsValidator.validate("http://anobisoft.com"))  // false (не совпала схема)
} catch {
    print("Ошибка инициализации системного детектора: \(error)")
}
```

---

## 🏗 Использование в коллекциях и идентификация

Благодаря встроенной реализации `Hashable`, стратегии валидации можно легко группировать, передавать в качестве зависимостей или использовать как ключи словарей для динамического роутинга форм ввода:

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

## 🛠 Создание собственных стратегий валидации

Вы можете легко расширить систему, создав свою структуру и подписав её под `StringValidator`. Например, для валидации строго числовых кодов подтверждения:

```swift
public struct VerificationCodeValidator: StringValidator {
    public let id: String
    
    public init(id: String = UUID().uuidString) {
        self.id = id
    }
    
    public func validate(_ text: String) -> Bool {
        // Проверяем, что строка состоит ровно из 6 цифр
        return text.count == 6 && text.allSatisfy { \$0.isNumber }
    }
}
```

