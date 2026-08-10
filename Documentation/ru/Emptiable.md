# Emptiable & Blankable

`Emptiable` и `Blankable` — это легковесные структурные протоколы, предназначенные для унификации сущностей, имеющих явное базовое состояние «пустоты». Данная архитектура разделяет зоны ответственности согласно принципу разделения интерфейсов: проверка на пустоту (`Emptiable`) и генерация статического дефолтного пустого значения (`Blankable`).

В сочетании с оптимизированными операторами (`@inlinable`), протоколы избавляют кодовую базу от громоздких ветвлений `if/else`, многоуровневых развертываний опционалов и шаблонного кода.

---

## Ключевые компоненты и операторы

* **Протокол `Emptiable`**: Декларирует требование нативного свойства проверки `isEmpty`.
* **Протокол `Blankable`**: Наследует от `Emptiable`. Декларирует требование генерации базового состояния `static var empty`.
* **`isNotEmpty`**: Унифицированное свойство, повышающее читаемость кода и избавляющее от знаков логического отрицания (`!isEmpty`).
* **`~?` (Оператор слияния пустых состояний)**: Оценивает левый операнд типа `Emptiable`. Возвращает его, если он заполнен (`isNotEmpty`), иначе переключает исполнение на правый операнд. Использует приоритет `NilCoalescingPrecedence` для выстраивания цепочек.
* **`orEmpty`**: Разворачивает опционал, возвращая его значение, либо статическую пустышку `Blankable.empty` (если значение равно `nil`).
* **`~!` (Безопасный постфиксный оператор)**: Не падающая альтернатива системному принудительному извлечению (`!`). Является коротким синтаксическим аналогом `.orEmpty`.

---

## Реальные примеры использования в коде

### 1. Семантическое версионирование и каскадные сравнения
Использование `~!` при сравнении структур избавляет код от нагромождения конструкций `?? 0`, автоматически приводя отсутствующие компоненты версий к нулевым индексам.

```swift
public struct Version: Comparable {
    public var major: UInt
    public var minor: UInt?
    public var patch: UInt?

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor~! < rhs.minor~! }
        if lhs.patch != rhs.patch { return lhs.patch~! < rhs.patch~! }
        return false
    }
}
```

### 2. Чтение метаданных приложения и предотвращение крэшей
Извлечение данных из динамических словарей всегда возвращает опциональные значения. Оператор `~!` гарантирует безопасность приложения, возвращая дефолтную пустую строку вместо падения.

```swift
public extension Bundle {
    var name: String? { ... }
    static var appName: String {
        main.name~!
    }
    
    var displayName: String? { ... }
    static var appDisplayName: String {
        main.displayName~!
    }
}
```

### 3. Графический контекст и геометрические вычисления
Использование `~?` напрямую для базовых структур (`CGFloat`, `CGSize`) позволяет передавать нулевые параметры в качестве триггера для подстановки дефолтных размеров.

```swift
public extension UIImage {
    func resized(_ target: CGSize = .zero, scale: CGFloat = .zero) -> UIImage {
        let target = target ~? size
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale ~? self.scale
        return renderer.image { _ in /* Рендеринг */ }
    }

    func withSolidBackground(color: UIColor, canvasSize: CGSize = .zero) -> UIImage {
        let canvasSize = canvasSize ~? size
        return backgroundClippedImage
    }
}
```

### 4. Управление памятью и валидация состояния ARC
Подписка на протокол `Emptiable` позволяет абстрагировать логику проверки жизненного цикла объектов. Прокси-узел становится «пустым» в тот момент, когда удерживаемый объект удаляется из памяти, при этом структуре не требуется искусственно генерировать статический экземпляр `.empty`.

```swift
extension WeakListElement: Emptiable {

    /// Возвращает `true`, если целевой бизнес-объект был удален подсистемой управления памятью ARC.
    public var isEmpty: Bool { object == nil }
}

// Применение в коде:
let updatedNode = activeNode ~? fallbackNode
```
