# WeakDictionary

The `WeakDictionary` component provides a thread-safe data structure that stores its values using weak references. If a value object is deallocated from memory in the calling code, the dictionary automatically releases the reference, preventing memory leaks (retain cycles).

## ✨ Key Features
* **Retain Cycle Prevention**: Designed for storing lists of delegates, observers, or caching resource-intensive objects whose lifecycle is managed by the external application.
* **Lazy Memory Cleanup**: If an object inside the dictionary is deallocated by the operating system, `WeakDictionary` automatically removes the empty node (key) during the next `subscript` access to that key, maintaining the correct state of the hash table.
* **Thread Safety**: Protected by the system primitive `OSAllocatedUnfairLock`, guaranteeing safe read and write operations in a multithreaded environment.
* **Swift 6 Compatibility**: The structure fully satisfies `Sendable` protocol requirements.

## 🚀 Usage

```swift
import SwanCore
import UIKit

// Subclass representing a screen, excluding strong retention in the dictionary
class DetailViewController: UIViewController {}

struct ScreenManager {
    // The key must conform to Hashable & Sendable; the value must conform to AnyObject
    private var activeScreens = WeakDictionary<String, DetailViewController>()

    mutating func register(_ controller: DetailViewController, for id: String) {
        activeScreens[id] = controller // Storing a weak reference
    }

    mutating func getController(for id: String) -> DetailViewController? {
        return activeScreens[id]
    }
}

// Example execution:
var manager = ScreenManager()
var vc: DetailViewController? = DetailViewController()

manager.register(vc!, for: "profile_screen")

print(manager.getController(for: "profile_screen") != nil) // Outputs: true

vc = nil // Deallocating the object in the calling code

// Upon the next read, the dictionary detects the absence of the object,
// returns nil, and removes the "profile_screen" key from memory.
print(manager.getController(for: "profile_screen") != nil) // Outputs: false
```
