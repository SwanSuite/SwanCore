# Localization Helpers

A lightweight, expressive infrastructure extending `Bundle` and `String` to streamline localization pipelines. By wrapping native Foundation localization methods, it provides a clean syntax with zero performance overhead.

---

## Core Components & API

### 1. Bundle Localization Context Extensions
* **`localized(_:value:table:)`**: A lightweight shorthand over the native `localizedString(forKey:...)` method.
* **`localized(_:value:table:locale:with:)`**: Localization lookup supporting target `Locale` rules and formatting injection via `CVarArg` sequences.
* **`fetchLocalizableStrings()`**: Synchronously deserializes and extracts all raw elements inside a `Localizable.strings` file into a dictionary profile. Provides a comprehensive dictionary view of compiled translations, facilitating localization audits or reverse-engineering of system keys within framework bundles.
* **`Bundle.UIKit`**: A static short-hand property referencing the native system `UIKit` framework resource container using class-based `UIApplication` reflection. Available on `iOS` and `tvOS`.

### 2. Expressive String Key Lookups
* **`localized`**: A property shortcut referencing `Bundle.main` layout contents.
* **`localized(_:value:table:)`**: A context lookup targeted at a concrete bundle instance.

---

## Architecture Integration Examples

### 1. Clean Modular Key Localization
Explicitly declaring and injecting module bundles guarantees asset isolation, strict dependency resolution, and predictable execution across multi-module targets.

```swift
public enum FeatureStrings {
    // Standard explicit target bundle definition for a submodule
    private static let moduleBundle = Bundle(for: CurrentModuleMarker.self)

    public static var moduleTitle: String {
        "feature_dashboard_title".localized(moduleBundle)
    }
    
    public static func welcomeAlert(user: String) -> String {
        "welcome_user_format".localized(moduleBundle, with: user)
    }
}
```

### 2. Utilizing Native System Framework Translations (UIKit)
Instead of hardcoding custom localized strings for standard OS labels, reuse the official Apple localization resources directly using the `.UIKit` bundle anchor.

```swift
// Automatically extracts the official system translation for "Cancel" or "Done" matching user device language
let systemCancelLabel = "Cancel".localized(.UIKit)
let systemDoneLabel = "Done".localized(.UIKit)
```

### 3. Inspection of System Framework Translations
You can leverage `fetchLocalizableStrings()` on `.UIKit` to dump compiled system strings, analyze available localizations, or discover native keys during diagnostics sessions.

```swift
#if os(iOS) || os(tvOS)
if let nativeTranslations = try? Bundle.UIKit.fetchLocalizableStrings() {
    for (key, translation) in nativeTranslations.prefix(10) {
        print("UIKit Key: \(key) -> [\(translation)]")
    }
}
#endif
```
