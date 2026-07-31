![Logo](SwanCore.png)

**SwanCore** is a low-level, high-performance system toolkit serving as the fundamental backbone of the **SwanSuite** ecosystem. Built entirely in pure Swift, the package is optimized for maximum runtime velocity, deterministic memory footprint, and seamless integration with **Swift 6 Strict Concurrency** guarantees.

The product is heavily tailored for commercial and industrial-grade software engineering where runtime resilience, predictable object graph behavior, and zero heap-allocation overhead are mission-critical requirements.

---

## 🏗 Documentation Localization

The complete setup of granular technical markdown documentation files is fully localized. You can review the localized branches within the repository structure:
* 🇺🇸 **English Version**: `Documentation/en/`
* 🇷🇺 **Russian Version**: `Documentation/ru/`

---

## 🧩 Core Suite Modules Overview

### 1. ⚙️ Base Primitives ([Emptyable.md](Documentation/en/Emptyable.md))
Introduces the formal concept of logical object emptiness via the `Emptyable` protocol and provides highly optimized shorthand operators:
* **`~! `** (postfix unwrap) — provides bulletproof optional extraction by falling back to the type's default empty state identity without crashing the runtime (`nilInt~! == 0`).
* **`~? `** (infix merging) — linear fluent fallback chaining evaluating alternative values if the left-hand operand is empty (`"" ~? "fallback" == "fallback"`). Incorporates tailored vector math optimizations for structural `CGRect` configurations.

### 2. ⚡ Storage Structures & Collections ([Cache.md](Documentation/en/Cache.md) & [Lists.md](Documentation/en/Lists.md))
A robust collection of thread-safe (`Sendable`) memory containers shielded via low-overhead native `OSAllocatedUnfairLock` engines:
* **`Cache`** — a strongly-typed wrapper built over native `NSCache` integrating full cost-aware memory metric allocations (`Costable`) in bytes.
* **`WeakDictionary`** — a hash-table mapping that retains its volatile values using weak references (`weak`), featuring lazy automated dead node purging during subscript lookups.
* **`MapTable`** — a type-safe interface for `NSMapTable` designed to orchestrate complex reference relationship topologies (`weak-to-strong`, `strong-to-weak`).
* **`WeakList` & `RetainList`** — thread-safe double linked lists utilizing streamlined streaming stream operators (`<+`, `+>`, `^`). Implements **Lock-Free Read Operations**, ensuring zero-lock parallel iterations across hundreds of thousands of active objects simultaneously.

### 3. 📝 System Bundle Utilities ([BundleMetadata.md](Documentation/en/BundleMetadata.md) & [BundleLocalization.md](Documentation/en/BundleLocalization.md))
High-speed introspection tools for extracting runtime metadata parameters from the active host application layer:
* Instant typed access to bundle version tags, compilation build identifiers, and executable binary descriptors.
* Dynamic on-the-fly localization string stream mapping featuring internal data-race prevention via atomic execution backtrace caching under `OSAllocatedUnfairLock`.

### 4. 🔗 Registry Case Transformations & Serialization ([Coding.md](Documentation/en/Coding.md))
Syntactic shorthand extensions for the native `Codable` ecosystem built entirely on compiler-level Type Inference loops:
* Eliminates the boilerplate requirement of passing explicit `T.self` sequences during encoding or decoding steps.
* Introduces a declarative Fluent API (Builder pattern) for clean, chained configuration of encoding engines.
* Deploys custom extended registry strategies `.convertFromSnakeCaseExtended` and `.convertToScreamingSnakeCase` via the `CustomizableCodingKeyMapping` protocol layer, protecting custom `CodingKeys` rules from being overridden by default Apple Foundation behaviors.

### 5. 🔬 Strict Data Validation ([DataValidation.md](Documentation/en/DataValidation.md))
An atomic strategy-driven architecture optimizing text sequence checking metrics (Email addresses, International telephone lines, Hyperlinks):
* Built on top of native `NSDataDetector` capabilities.
* Enforces strict full-boundary checking constraints (`matchesFullBoundary`), successfully neutralizing false-positive match flags within polluted or dirty string buffers.
* Inherits cross-isolation thread-safety and implements programmatic `Hashable` capabilities on custom identifier `id` sequences, allowing validators to serve as dictionary keys for dynamic error routing layouts in UI architectures.

### 6. 🔀 Enum Representation Mapping ([DictionaryRawRepresentable.md](Documentation/en/DictionaryRawRepresentable.md))
An advanced generic type resolution abstraction engine (`resolveRepresentation()`) orchestrating automated conversion loops for dictionaries bridging strict domain enums (`enum: RawRepresentable`) with primitive raw backing components. Implements bulletproof initialization sweeping to prune invalid nodes and unwrap optional chains. Includes a hyper-optimized `lazyCompactMapToDictionary` alternative for absolute zero-allocation pipelines.

### 7. 💾 Industrial-Grade Persistence ([Storage.md](Documentation/en/Storage.md))
A unified repository pattern abstraction (`PersistentStorage`) isolating raw data byte storage operations from dynamic entity construction loops:
* Retroactively conforms standard `UserDefaults` registries to cleanly participate in flat configuration storage.
* Implements a robust disk-bound atomic file engine `FileStorage` enforcing `.atomic` writing flags, guaranteeing that database queues remain shielded from file corruption during unexpected power-downs or device crashes in offline fields (battle-tested in mining inspection environments).

### 8. 📌 Semantic Versioning Engine ([Version.md](Documentation/en/Version.md))
A lossless metadata string parser and cascade evaluation mechanism (`Comparable`) prioritizing version layers alongside software pre-production lifecycle weights (`alpha < beta < rc < release`). Integrates a declarative pattern-matching layout compiler `VersionFormatter` built over regular expressions, supporting intelligent bracket block pruning `[...]` for missing fields.

---

## 🛠 Requirements & Integration

The package is a fully standalone distribution layer containing zero external runtime package dependencies.

* **Swift Tools Version**: 6.0+
* **Minimum Platform Footprint**: iOS 16.0+, macOS 13.0+, watchOS 9.0+, tvOS 16.0+

### Integration via Swift Package Manager

Declare the dependency boundary within your structural `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/SwanSuite/SwanCore", from: "0.1.0")
]
```

Securely anchor the library product target to your application module requirements:

```swift
.target(
    name: "MyApplicationModule",
    dependencies: ["SwanCore"]
)
```
