# Слабый словарь (WeakDictionary)

Компонент `WeakDictionary` предоставляет потокобезопасную структуру данных, которая хранит свои значения по слабой ссылке (`weak`). Если объект-значение удаляется из памяти в вызывающем коде, словарь автоматически отпускает его, предотвращая утечки памяти (retain cycles).

## ✨ Ключевые особенности
* **Предотвращение циклов удержания**: Идеально подходит для хранения списков делегатов, наблюдателей (observers) или кэширования тяжелых объектов, чьим жизненным циклом должно управлять внешнее приложение.
* **Ленивая очистка памяти**: Если объект внутри словаря был уничтожен ОС, `WeakDictionary` автоматически удалит пустую ноду (ключ) во время следующего обращения к этому ключу через `subscript`, поддерживая хэш-таблицу в чистоте.
* **Потокобезопасность**: Защищен быстрым системным примитивом `OSAllocatedUnfairLock`, что гарантирует безопасность операций чтения и записи в многопоточной среде.
* **Совместимость со Swift 6**: Структура полностью удовлетворяет требованиям `Sendable`.

## 🚀 Использование

```swift
import SwanCore
import UIKit

// Допустим, у нас есть класс экрана, который мы не хотим удерживать жестко
class DetailViewController: UIViewController {}

struct ScreenManager {
    // Ключ обязан быть Hashable & Sendable, значение — AnyObject (классом)
    private var activeScreens = WeakDictionary<String, DetailViewController>()

    mutating func register(_ controller: DetailViewController, for id: String) {
        activeScreens[id] = controller // Сохраняется слабая ссылка
    }

    mutating func getController(for id: String) -> DetailViewController? {
        return activeScreens[id]
    }
}

// Пример работы:
var manager = ScreenManager()
var vc: DetailViewController? = DetailViewController()

manager.register(vc!, for: "profile_screen")

print(manager.getController(for: "profile_screen") != nil) // Выведет: true

vc = nil // Уничтожаем объект в вызывающем коде

// При следующем чтении словарь поймет, что объекта больше нет,
// вернет nil и автоматически очистит ключ "profile_screen" из памяти.
print(manager.getController(for: "profile_screen") != nil) // Выведет: false
```
