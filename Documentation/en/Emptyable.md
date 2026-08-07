# Emptyable Protocol & Safe Unwrapping Operators

A lightweight utility extension that unifies state validation and optional unwrapping for standard types, numeric scalars, and CoreGraphics structures to eliminate boilerplate code (`if-else`, `guard`).

The `Emptyable` protocol establishes a clean contract for types containing a distinct, logical "empty" baseline. It provides elegant operator alternatives to standard forced unwrapping mechanisms.

## ✨ Key Features

* **Safety Over Crashes:** The postfix `~!` operator replaces the risky native forced unwrap (`!`), returning a default empty value instead of triggering a runtime crash.
* **Strict Concurrency:** The protocol explicitly inherits from `Sendable`, guaranteeing thread-safe transfers across concurrency isolation boundaries in Swift 6.
* **Universal Automation:** Protocol conformance scales efficiently to whole groups of types via extensions on the native `BinaryInteger` and `FloatingPoint` protocols.

---

## 🚀 Operator Usage

### 1. Dynamic Coalescing Operator `~?`
The infix `~?` operator evaluates the left operand. If the left operand's `isEmpty` property returns `true`, execution routes onto the right fallback operand. It inherits `NilCoalescingPrecedence`, allowing you to seamlessly chain multiple fallbacks.

```swift
import SwanCore

let cachedName = ""
let legacyName = "Old Profile"

// Since cachedName is empty, the pipeline switches to legacyName
let finalName = cachedName ~? legacyName ~? "Guest" 
print(finalName) // Outputs: "Old Profile"
```

### 2. Safe Unwrap Operator `~!`
The postfix `~! ` operator safely unwraps an optional `Emptyable` instance. If the container holds `nil`, it returns the canonical static empty state of that type (`.empty`), preventing runtime crashes.

The standard fluent `.orEmpty` computed property is also available as a non-operator alternative.

```swift
// Working with Strings
let remoteTitle: String? = nil
print(remoteTitle~!) // Outputs an empty string: ""

// Working with FloatingPoint scalars
let velocity: Double? = nil
let currentSpeed = velocity~! // Returns 0.0 instead of crashing

// Working with Collections
let optionalUsers: [String]? = nil
for user in optionalUsers~! {
    // Safe loop execution that safely skips execution if nil
}

// Working with CoreGraphics geometric structures
let customFrame: CGRect? = nil
let view = UIView(frame: customFrame~!) // Initializes with CGRect.zero
```

---

## 🛠 Supported Type Matrix

SwanCore provides out-of-the-box `Emptyable` conformance for the following data structures:

| Category | Supported Types | `isEmpty` Criteria | `.empty` Identity |
| :--- | :--- | :--- | :--- |
| **Collections** | `String`, `Array`, `Dictionary`, `Set`, `Data` | Element count equals `0` | `""`, `[]`, `[:]`, `Data()` |
| **Integers** | Any `BinaryInteger` (`Int`, `UInt`, `Int8`, `UInt64`, as well as `Int128` / `UInt128` on iOS 18+) | Value equals `.zero` (`0`) | `0` |
| **Floats** | Any `FloatingPoint` (`Float`, `Double`, `CGFloat`) | Value equals `.zero` (`0.0`) | `0.0` |
| **CoreGraphics** | `CGPoint`, `CGSize`, `CGRect` | Matches the native `.zero` boundaries | `.zero` |

> 💡 **CGRect Specifics:** For `CGRect` geometric boundaries, SwanCore respects the native `CoreGraphics` structural rules. A rectangle is recognized as empty if either its `width` or `height` is less than or equal to zero.

---

## 🏗 Implementing for Custom Types

You can easily conform your own custom structures or classes to `Emptyable` by implementing a validation property and a static default identity variable:

```swift
import SwanCore

struct UserProfile: Emptyable {
    let id: UUID?
    let username: String
    
    // Profile emptiness criteria
    var isEmpty: Bool { id == nil }
    
    // Canonical static empty identity
    static var empty: UserProfile { 
        UserProfile(id: nil, username: "") 
    }
}

// Custom operators now support your domain data type flawlessly:
let optionalProfile: UserProfile? = nil
let profile = optionalProfile~! // Safely returns an empty profile instance
```
