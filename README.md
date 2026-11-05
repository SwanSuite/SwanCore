![Logo](SwanCore.png)

[![Swift 6 Concurrency](https://img.shields.io/badge/Swift_6-Concurrency_Ready-52B1F4.svg)](https://developer.apple.com/documentation/swift/adoptingswift6)
[![SPM Compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-52B1F4.svg)](https://swift.org/package-manager/)
![Platforms](https://img.shields.io/badge/platforms-macOS_%7C_iOS_%7C_tvOS_%7C_watchOS-lightgrey.svg)
![Repository Size](https://img.shields.io/github/repo-size/SwanSuite/SwanCore-lightgrey.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/SwanSuite/SwanCore?color=52B1F4)

[![Language](https://img.shields.io/badge/Language-%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-52B1F4.svg)](README.ru.md)

A low-overhead, zero-dependency package providing lightweight data structures, types, and foundational extensions for Swift. The entire architecture is optimized for high throughput, minimal heap allocation, and absolute compile-time thread safety under the Swift 6 Strict Concurrency model.

The utilities are engineered to handle repetitive infrastructural routines while completely avoiding the overhead of runtime dynamic dispatch mechanisms.

---

## 💻 Requirements & Environment
* **Language constraints**: Swift 6.0+ (Strict Concurrency Ready)
* **Minimum Platform Alignment**: iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
* **Dependency Orchestration**: Swift Package Manager (SPM)
* **External Dependencies**: None (Zero-Dependency Profile)

---

## 🗺 Module Architectural Blueprint & Navigation

Complete structural documentation and specifications for every individual utility are isolated within dedicated `.md` files inside the `Documentation/en/` directory. Use the index table below to navigate to the core documentation layout branches:

| Utility / Documentation File | Associated Tokens / Structural Types | Functional Responsibility & Technical Scope |
| :--- | :--- | :--- |
| 🛡 [Locking.md](Documentation/en/Locking.md) | `Locking`, `RWLocking` | Unified synchronization interface abstraction layer for native platform locking primitives. |
| ⛓ [Lists.md](Documentation/en/Lists.md) | `List<T, Lock>`, `+>`, `<+`, `^` | Doubly linked list featuring **O(1)** boundary mutations, predictive Lock Dropping iteration algorithms, and L-Shape data-flow mechanics. |
| 📦 [Cache.md](Documentation/en/Cache.md) | `Cache<K, V>`, `Costable` | Thread-safe object wrapper augmenting `NSCache` to support Swift value types, eviction interception callbacks, and cost limits. |
| 📝 [Version.md](Documentation/en/Version.md) | `Version<Stage>`, `VersionFormatter` | Modular software version parsing and serialization engine utilizing Abstract Syntax Tree (AST) pattern compilation and One-Hot selection rules. |
| 💾 [Storage.md](Documentation/en/Storage.md) | `PersistentStorage`, `FileStorage` | Persistence abstraction layer (Repository Pattern) managing structured file-system atomic operations and clean preference mappings. |
| ⚙️ [Coding.md](Documentation/en/Coding.md) | `CustomizableCodingKeyMapping` | Metatype-driven `Codable` extensions enabling call-site type inference without `T.self`, Fluent API configurations, and case conversions. |
| 📊 [DictionaryRawRepresentable.md](Documentation/en/DictionaryRawRepresentable.md) | `resolveRepresentation` | Functional hash-table transformations, allocation-free lazy sequences, and bidirectional primitive-to-enumeration domain mapping. |
| 🔍 [DataValidation.md](Documentation/en/DataValidation.md) | `StringValidator`, `EmailValidator` | Strict text validation architecture wrapping `NSDataDetector` and enforcing complete pattern matching bounds via `matchesFullBoundary`. |
| 🕸 [WeakDictionary.md](Documentation/en/WeakDictionary.md) | `WeakDictionary<K, V>` | Concurrent table infrastructure storing elements via weak relationships (`weak`) paired with automated lazy ARC node purging. |
| 🌐 [Localization.md](Documentation/en/Localization.md) | `Bundle.UIKit`, `localized()` | Inverted string localization patterns, native `UIKit` platform translation recycling, and synchronous dictionary export diagnostics. |
| 📑 [BundleMetadata.md](Documentation/en/BundleMetadata.md) | `Bundle.appVersion`, `Info.plist` | Performance-optimized inlinable short-hands for reading application target attributes directly from internal bundle manifests. |
| 💠 [Emptiable.md](Documentation/en/Emptiable.md) | `Emptiable`, `Blankable`, `~?`, `~!` | Core protocols establishing baseline emptiness characteristics and inline operators eliminating runtime if/else optional unwrapping. |

---

## 🛠 Installation

Integrate the framework into your codebase by appending SwanCore straight into your active `Package.swift` dependency matrix:

```swift
dependencies: [
    .package(url: "https://github.com/SwanSuite/SwanCore", from: "1.0.0")
]
```

Then map the library module into your target execution layer configuration block:

```swift
targets: [
    .target(
        name: "MyApplicationModule",
        dependencies: ["SwanCore"]
    )
]
```
