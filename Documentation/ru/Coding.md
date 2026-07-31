# Утилиты сериализации и кастомизации ключей (Coding)

Модуль `SwanCore` предоставляет набор расширений для нативного механизма `Codable` (`JSONDecoder`, `JSONEncoder`, `Data`, `Encodable`, `Decodable`), который вводит декларативный Fluent API для конфигурации кодеров, реализует вывод типов на этапе компиляции и добавляет продвинутые стратегии кастомизации ключей (например, `SCREAMING_SNAKE_CASE`) без поломки ручного маппинга `CodingKeys`.

## ✨ Ключевые особенности
* **Вывод типов из контекста (Type Inference)**: Сокращения позволяют декодировать данные напрямую из буфера `Data`, не требуя явного указания `T.self`, если тип переменной уже понятен компилятору.
* **Fluent API (Builder Pattern)**: Декларативные цепочки методов (например, `.keyDecodingStrategy(...).dateDecodingStrategy(...)`) заменяют пошаговую инициализацию свойств кодеров.
* **Расширенные стратегии регистров**: Кастомные обертки `CamelKey` и `ScreamingSnakeKey` автоматически преобразуют ключи на лету (`snake_case` -> `camelCase` и `camelCase` -> `SCREAMING_SNAKE_CASE`).
* **Интерцептор ключей**: Метод `.customizable(T.Type)` умеет перехватывать ключи на этапе сериализации. Если ключ реализует протокол `CustomizableCodingKeyMapping`, кодер применит его персональные динамические правила перенаправления (`mapped`), предотвращая игнорирование ручных правил `CodingKeys` системными конвертерами Foundation.
* **Высокая производительность**: Все критические утилитарные методы и расширения строк снабжены аннотацией `@inlinable` для прямой оптимизации компилятором.

---

## 🚀 Базовое использование (Shorthands)

Вывод типов из контекста и цепочечный синтаксис (Fluent API) позволяют избавиться от лишнего шаблонного кода при сериализации стандартных моделей:

```swift
import SwanCore
import Foundation

struct User: Codable {
    let id: Int
    let name: String
}

let rawJSON = #"{"id": 7, "name": "Stanislav"}"#.data(using: .utf8)!

// 1. Декодирование напрямую из Data с автоматическим выводом типа
let user: User = try rawJSON.decode()

// 2. Кодирование напрямую из инстанса Encodable-модели
let encodedData: Data = try user.encode()

// 3. Декодирование через статический метод протокола Decodable
let alternativeUser = try User.decode(data: rawJSON)
```

---

## 🛠 Декларативная настройка кодеров (Fluent API)

Вместо императивного написания свойств, кодеры и декодеры можно конфигурировать лаконичными цепочками методов прямо во время инициализации:

```swift
// Настройка декодера
let decoder = JSONDecoder()
    .keyDecodingStrategy(.convertFromSnakeCaseExtended)
    .dateDecodingStrategy(.iso8601)
    .dataDecodingStrategy(.base64)

// Настройка кодера
let encoder = JSONEncoder()
    .keyEncodingStrategy(.convertToScreamingSnakeCase)
    .dateEncodingStrategy(.millisecondsSince1970)
```

---

## ⚙️ Продвинутые стратегии кастомизации ключей

Системные стратегии Apple (например, `.convertFromSnakeCase`) имеют фундаментальный недостаток: они полностью игнорируют ручное переопределение ключей внутри перечисления `enum CodingKeys: String, CodingKey`, если в JSON-модели нужно точечно изменить имя хотя бы одного свойства. 

Расширенные стратегии `SwanCore` решают эту проблему через интеграцию протокола `CustomizableCodingKeyMapping`.

### 1. Декодирование: Стратегия `.convertFromSnakeCaseExtended`
Автоматически приводит ключи `snake_case` к стандартному `camelCase` кодовой базы, сохраняя при этом совместимость с динамическими правилами подмены ключей.

```swift
// JSON содержит змеиный регистр
let json = """
{
    "user_id": 101,
    "first_name": "John"
}
"""

let decoder = JSONDecoder(strategy: .convertFromSnakeCaseExtended)
let user = try decoder.decode(User.self, from: json.data(using: .utf8)!)
```

### 2. Кодирование: Стратегия `.convertToScreamingSnakeCase`
Автоматически транслирует переменные `camelCase` из кода Swift в верхний змеиный регистр (`SCREAMING_SNAKE_CASE`), часто требуемый на бэкендах корпоративных систем, сохраняя защиту индексов массивов.

```swift
struct ConfigSetting: Encodable {
    let maxRetryCount: Int        // В JSON превратится в: "MAX_RETRY_COUNT"
    let authTokenExpiration: String // В JSON превратится в: "AUTH_TOKEN_EXPIRATION"
}

let encoder = JSONEncoder().keyEncodingStrategy(.convertToScreamingSnakeCase)
let payload = try encoder.encode(ConfigSetting(maxRetryCount: 5, authTokenExpiration: "3600s"))
```

### 3. Динамический редирект через CustomizableCodingKeyMapping
Если модель подписывает свое перечисление ключей под данный протокол, вы можете на лету перенаправлять маршруты сериализации на кастомные токены:

```swift
struct MockCustomKey: CodingKey, CustomizableCodingKeyMapping {
    var stringValue: String
    var intValue: Int?

    // Перенаправляем логику маппинга на кастомный адаптер CamelKey
    var mapped: CodingKey {
        return CamelKey(stringValue: stringValue)!
    }
}
```

---

## 🔤 Утилиты конвертации строк (Case Converting)

Расширение `String+CaseConverting.swift` содержит низкоуровневые утилитарные свойства для безопасной векторизации и трансформации строк между регистрами `camelCase`, `snake_case`, `PascalCase` и `SCREAMING_SNAKE_CASE`.

```swift
let rawProperty = "maxRetryCount"

print(rawProperty.camelCaseTo_snake_Eating_Train) // "max_Retry_Count"
print(rawProperty.camelCaseTo_SCREAMING_SNAKE)    // "MAX_RETRY_COUNT"

let snakeKey = "auth_token_expiration"
print(snakeKey.pascalCasedSnake) // "AuthTokenExpiration"
print(snakeKey.camelCasedSnake)  // "authTokenExpiration"
```
