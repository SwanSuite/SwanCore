# Декларативное хранение и персистенс (Storage Layer)

Модуль `SwanCore` предоставляет потокобезопасную, расширяемую абстракцию для сохранения и извлечения данных (Repository Pattern), объединяющую работу с сырыми байтами `Data`, стандартными `Codable`-моделями и специализированными доменными сущностями `Storable`. Из коробки модуль содержит высокопроизводительные бэкенды для `UserDefaults` и файловой системы `FileStorage`.

## ✨ Ключевые особенности
* **Разделение слоев (Low-Level Isolation)**: Конкретному хранилищу достаточно реализовать три базовых метода работы с байтами (`data`, `save`, `removeObject`). Всю дженерик-работу по кодированию и сборке объектов протокол `PersistentStorage` берет на себя.
* **Защита мутабельного состояния (Anti-Stale Architecture)**: Логика кэширования в `Storable.swift` вынесена на уровень глобального свойства `data`. Метод `serialize()` всегда честно генерирует свежие байты "наживую", защищая мутабельные модели от рассинхронизации данных в памяти и на диске.
* **Изоляция пространств имен (Composite Keys)**: Свойство `compositeKey` использует рефлексию метатипа (`String(reflecting:)`) и автоматически вычищает рантайм-мусор компилятора Swift, гарантируя детерминированные ключи вида `Module.Model.ID` и полностью исключая коллизии имен разных типов с одинаковыми идентификаторами.
* **Промышленная отказоустойчивость**: Бэкенд `FileStorage` использует атомарную запись файлов на диск (`options: .atomic`), гарантируя защиту базы данных от превращения в битый мусор при внезапном выключении устройства или падении приложения (проверено в жестких условиях offline-работы в горнодобывающей отрасли).
* **Fluent API сокращения**: Расширения протоколов `Encodable` и `Decodable` позволяют сохранять и загружать модели элегантными цепочками вызовов прямо на инстансах типов (`try user.save(for: "id", to: storage)`).

---

## 🚀 Базовое использование и Fluent API

Декларативные методы позволяют абстрагировать вызывающий UI-слой от конкретной реализации базы данных:

```swift
import SwanCore
import Foundation

struct UserProfile: Codable {
    let name: String
}

// 1. Инициализируем атомарное дисковое хранилище в папке Caches
let diskStorage = try FileStorage(.cachesDirectory, path: "UserCache")

let user = UserProfile(name: "Stanislav")

// 2. Сохраняем модель изящным цепочечным Fluent-методом
try user.save(for: "current_user", to: diskStorage)

// 3. Загружаем модель напрямую через статический метод типа
if let loadedUser = try UserProfile.load(id: "current_user", from: diskStorage) {
    print("Пользователь успешно извлечен с диска: \(loadedUser.name)")
}
```

---

## ⚙️ Доменный персистенс через протокол `Storable`

Протокол `Storable` реализует паттерн `Active Record`, инкапсулируя логику генерации ключей и жизненного цикла персистенса внутри самой модели.

### 📐 Автоматическая интеграция с Codable:
Если ваша доменная модель уже является `Codable`, `SwanCore` автоматически синтезирует методы сериализации и инициализации:

```swift
struct OrderRecord: Storable, Codable {
    let id: String
    let amount: Double

    // Опциональное свойство кэша полезной нагрузки (для иммутабельных структур)
    var dataCache: Data? { nil }
}

let storage = try FileStorage()
let order = OrderRecord(id: "order_42", amount: 2500.0)

// Хранилище автоматически вычислит compositeKey ("SwanCore.OrderRecord.order_42")
// и запишет сериализованные байты на диск
try storage.store(order)

// Извлечение объекта обратно по его краткому ID токену
let recoveredOrder: OrderRecord? = try storage.retrieveObject(forKey: "order_42")
```

---

## 📦 Плоское хранилище настроек (UserDefaults Backend)

Системный `UserDefaults` нативно расширен под контракт `PersistentStorage`. При работе с `Storable`-объектами он умышленно переопределяет метод `store`, сохраняя данные по плоскому `object.id` вместо длинного составного ключа, поддерживая файл настроек `.plist` в чистоте:

```swift
let defaultsStorage = UserDefaults.standard

// Запишет данные в UserDefaults по чистому ключу "order_42" для удобной отладки
try defaultsStorage.store(order)
```
