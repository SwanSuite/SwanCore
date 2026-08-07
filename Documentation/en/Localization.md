# Localization Utilities

An elegant, low-overhead localization sub-framework designed for modular architecture. 

It provides swift, type-safe access to standard localization workflows via `Bundle` and `String` extensions, alongside an advanced, zero-configuration dynamic proxy mechanism for shared infrastructure.

## Architectural Overview

Localization within a modular ecosystem usually requires manually passing the target module's `Bundle` instance down to core utilities. SwanCore eliminates this cognitive load by separating localization tasks into two tiers:

1. **Explicit Static Routings (Highly Optimized):** Standard localization methods extended directly on `Bundle` and `String`, designed for high-frequency runtime operations.
2. **Context-Aware Dynamic Routing (Zero Configuration):** A fallback mechanism that inspects the calling thread stack at runtime to isolate the exact framework target requesting localized content.

---

## Core Localization APIs

### Extending String Interoperability

The simplest way to extract localized content is to trigger the explicit extension methods on any standard `String` instance.

#### Standard Application Bundle Lookup
For strings located within your primary application target (`Bundle.main`), use the fast computed shorthand property:

```swift
let greeting = "welcome_title".localized
```

#### Custom Bundle and Table Overrides
If you need to query alternative feature bundles, customized localization tables, or provide explicit runtime fallback values:

```swift
let errorMessage = "network_timeout_error".localized(
    .module, 
    value: "A connection timeout occurred.", 
    table: "LocalizableErrors"
)
```

#### String Formatting with Arguments
SwanCore supports type-safe string formatting using variadic arguments (`CVarArg`). It automatically applies `Locale.current` to guarantee proper regional formatting for numbers, dates, and currency symbols:

```swift
// In Localizable.strings: "speed_format" = "Current speed is %.1f km/h";
let speedLabel = "speed_format".localized(with: 120.5) // Outputs "120.5 km/h" or "120,5 km/h" depending on region
```

### Direct Bundle Extractions

SwanCore extends `Bundle` with clean API facades, formatting support, and a raw string-mapping extraction tool designed for diagnostic pipelines, remote configuration validation, or layout testing engines.

```swift
// Direct clean lookup with formatted arguments
let message = Bundle.main.localized("items_count_key", value: nil, table: nil, 42, "Folder")

// Synchronous full localization matrix extraction
do {
    if let localizedDictionary = try Bundle.main.fetchLocalizableStrings() {
        print("Discovered translations count: \(localizedDictionary.count)")
    }
} catch {
    print("Failed to serialize localization asset mapping: \(error)")
}
```

---

## Context-Aware Dynamic Localization

When writing shared code—such as custom UI components, foundational wrapper kits, or common routing managers—hardcoding `.main` or passing explicit bundles introduces heavy boilerplate. 

SwanCore introduces the computed `.localizedDynamic` property and its parameterized methods to solve this.

```swift
// Inside a shared multi-module feature toolkit framework
public final class CustomHeaderView: UIView {
    private let titleLabel = UILabel()

    public func setupView() {
        // Automatically resolves to the asset catalog of the framework containing CustomHeaderView
        titleLabel.text = "shared_component_header_title".localizedDynamic
    }
}
```

### Formatting with Dynamic Arguments

The dynamic lookup engine seamlessly supports variadic arguments. It detects the calling target at runtime and applies the active user's system locale for placeholder injections:

```swift
// In Localizable.strings within the shared framework: "items_count_label" = "Found %d items in %@";
let statusText = "items_count_label".localizedDynamic(with: 42, "Storage")
```

### Underlying Engine Implementation

The dynamic lookup completely bypasses the traditional `Bundle` subclassing models to prevent cyclical reference lockups during critical bootstrap phases. Instead, it interacts with low-level execution architecture:

1. It samples the calling thread backtrace context using `Thread.callStackReturnAddresses`.
2. It translates the instruction pointer sequence to an isolated dynamic shared object base header (`Dl_info.dli_fbase`).
3. It utilizes an internal `OSAllocatedUnfairLock` to securely memoize the instruction-to-bundle tracking structure without re-triggering heavy file system iterations or complex metadata traversals.

---

## Engineering Guidelines & Performance Matrix

When deciding between static and dynamic endpoints, adhere to the following architecture rules:

| API | Performance Footprint | Concurrency Profile | Recommended Environment |
| :--- | :--- | :--- | :--- |
| `String.localized`<br>`String.localized(with:)` | **Extremely Low** <br> Direct inline compilation pointer maps | `Sendable` lock-free thread safety | High-frequency rendering paths (`cellForRowAt:`, custom canvas loops) |
| `String.localizedDynamic`<br>`String.localizedDynamic(with:)` | **Medium** <br> Thread trace overhead on miss; O(1) lock-checked memory map lookups on hit | Safe for modern Swift 6 Concurrency isolated runtime loops | Structural initialization setups, design systems, boilerplate-free core targets |

> ⚠️ **Critical Warning:** Never use `.localizedDynamic` or `.localizedDynamic(with:)` directly inside highly iterative rendering sequences, table/collection view data source loops, or layout pipelines. For performance-critical subviews, resolve the target `Bundle` ahead of time or cache the string outputs on instance level.

