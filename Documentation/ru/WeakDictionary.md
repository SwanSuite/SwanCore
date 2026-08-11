# WeakDictionary

Компонент `WeakDictionary` предоставляет потокобезопасную структуру данных, хранящую значения по слабой ссылке (`weak`). Если объект-значение деаллоцируется из памяти в вызывающем коде, словарь автоматически освобождает ссылку, предотвращая возникновение циклов сильного удержания (retain cycles).

## ✨ Ключевые особенности
* **Предотвращение циклов удержания**: Предназначен для хранения списков делегатов, наблюдателей (observers) или кэширования ресурсоемких объектов, чьим жизненным циклом управляет внешнее приложение.
* **Отложенная очистка памяти (Lazy Garbage Collection)**: При уничтожении объекта операционной системой `WeakDictionary` удаляет соответствующий пустой узел (ключ) во время следующего обращения к нему через `subscript`, обеспечивая корректное состояние хэш-таблицы.
* **Потокобезопасность**: Защищен системным примитивом `OSAllocatedUnfairLock`, что гарантирует безопасность операций чтения и записи в многопоточной среде.
* **Совместимость со Swift 6**: Структура полностью удовлетворяет требованиям протокола `Sendable`.

## 🚀 Использование

```swift
import SwanCore
import UIKit

// Класс контроллера, исключающий сильное удержание в словаре
class DetailViewController: UIViewController {}

struct ScreenManager {
    // Ключ должен соответствовать протоколам Hashable & Sendable, значение — AnyObject
    private var activeScreens = WeakDictionary<String, DetailViewController>()

    mutating func register(_ controller: DetailViewController, for id: String) {
        activeScreens[id] = controller // Сохранение слабой ссылки
    }

    mutating func getController(for id: String) -> DetailViewController? {
        return activeScreens[id]
    }
}

// Пример выполнения:
var manager = ScreenManager()
var vc: DetailViewController? = DetailViewController()

manager.register(vc!, for: "profile_screen")

print(manager.getController(for: "profile_screen") != nil) // Выведет: true

vc = nil // Деаллокация объекта в вызывающем коде

// При следующем чтении словарь определяет отсутствие объекта,
// возвращает nil и удаляет ключ "profile_screen" из памяти.
print(manager.getController(for: "profile_screen") != nil) // Выведет: false
```
