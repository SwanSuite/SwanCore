# Bundle+Metadata Extension

A collection of metadata short-hand computed properties for the system `Bundle` class within the `Foundation` framework, providing streamlined access to application configuration metrics embedded inside the `Info.plist` file.

## 📋 Overview

The component encapsulates structural data queries executed against the raw `infoDictionary` payload and Core Foundation system keys. It introduces static short-hand accessors targeted directly at the main application bundle (`Bundle.main`) as well as instance-level properties applicable to localized submodule boundaries, plug-ins, or dynamic frameworks.

## ✨ Key Features

* **Safe Non-Optional Fallbacks:** By leveraging the custom `~!` postfix operator (defined within the `Blankable` subsystem), the static application layout properties guarantee a concrete `String` return value, transforming absent plist definitions into safe empty string sequences (`""`).
* **Cascading Name Resolution:** The dynamic `displayName` property implements an out-of-the-box fallback sequence, checking for localized user-facing naming tokens (`CFBundleDisplayName`) before automatically routing down to the baseline bundle naming identifier (`CFBundleName`).
* **Inlinable Optimization Constraints:** All computed evaluation points declare explicit `@inlinable` boundaries, enabling the Swift compiler to optimize cross-module execution contexts during application compilation.

---

## 📝 Key Mapping Layout Configuration

The extension bridges native Swift code properties directly into Core Foundation configuration layout identifiers:

| Property | Core Foundation Info.plist Identifier Key | Description |
| :--- | :--- | :--- |
| `executable` | `kCFBundleExecutableKey` (`"CFBundleExecutable"`) | The filename of the bundle's primary binary executable. |
| `name` | `kCFBundleNameKey` (`"CFBundleName"`) | The basic operational bundle identifier name string. |
| `displayName` | `"CFBundleDisplayName"` *(falls back onto `name`)* | The localized, user-visible layout name of the module. |
| `shortVersion`| `"CFBundleShortVersionString"` | The explicit public marketing or release version string. |
| `buildNumber` | `kCFBundleVersionKey` (`"CFBundleVersion"`) | The low-level internal technical compilation sequence number. |

---

## 🚀 Usage Examples

### 1. Extracting Main Application Metadata (Static Interface)
```swift
import SwanCore
import Foundation

// Fetching target application attributes for UI presentation layers
let visibleName = Bundle.appDisplayName   // e.g., "SwanKit Framework"
let currentVersion = Bundle.appVersion   // e.g., "1.0.3"
let currentBuild = Bundle.appBuild       // e.g., "42"

print("Active executable: \(Bundle.appExecutable)")
print("Running: \(visibleName) version \(currentVersion) (Build \(currentBuild))")
```

### 2. Inspecting Isolated Module Targets (Instance Interface)
```swift
// Resolving the bundle scope hosting a specific framework controller class
let frameworkBundle = Bundle(for: DetailViewController.self)

if let internalName = frameworkBundle.name {
    print("Inspecting underlying framework bundle target: \(internalName)") // e.g., "SwanCore"
}

if let binaryExecutable = frameworkBundle.executable {
    print("Framework binary target name: \(binaryExecutable)")
}
```
