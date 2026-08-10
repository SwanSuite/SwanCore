# Declarative Storage & Persistence Architecture

The `SwanCore` framework provides a thread-safe, extensible abstraction layer (Repository Pattern) for data persistence. It unifies operations over raw binary buffers (`Data`), standard `Codable` models, and specialized domain entities complying with the `Storable` protocol. The module includes built-in high-performance backends for `UserDefaults` and the local file system (`FileStorage`).

## Core Characteristics

* **Low-Level Interface Isolation**: To implement a custom persistence provider, a backend only needs to implement three primitive data operations: `data(forKey:)`, `save(_:forKey:)`, and `removeObject(forKey:)`. Protocol extensions automatically handle generic encoding, decoding, and type assembly.
* **State Invalidation Protection**: Caching logic within the storage pipeline is anchored directly to the global `data` evaluation property. The `serialize()` operation generates fresh binary representation transitions dynamically, protecting mutable models against memory-to-disk state desynchronization.
* **Namespace Isolation via Composite Keys**: The `compositeKey` resolution engine uses metatype reflection (`String(reflecting:)`) and discards runtime Swift compiler artifacts. This guarantees deterministic identifiers formatted as `Module.Model.ID` to prevent naming collisions across distinct types sharing identical identifier values.
* **Process Termination Resiliency**: The `FileStorage` backend enforces atomic file writes (`options: .atomic`). This mechanism ensures data integrity by preventing file system corruption during abrupt process termination, unexpected application crashes, or sudden device battery depletion.
* **Type-Anchored Fluent Shorthands**: Protocol extensions for `Encodable` and `Decodable` enable fluent call chains executed directly on type instances or static metatypes.

---

## Baseline Execution & Fluent API

The declarative API decouples the invoking caller infrastructure from concrete storage subsystem implementations:

```swift
import SwanCore
import Foundation

struct UserProfile: Codable {
    let name: String
}

// 1. Instantiate an atomic file-system storage container within the Caches directory
let diskStorage = try FileStorage(.cachesDirectory, path: "UserCache")
let user = UserProfile(name: "Stanislav")

// 2. Persist the model instance using the fluent shorthand method
try user.save(for: "current_user", to: diskStorage)

// 3. Retrieve the model instance directly using the static metatype interface
if let loadedUser = try UserProfile.load(id: "current_user", from: diskStorage) {
    print("User retrieved successfully: \(loadedUser.name)")
}
```

---

## Domain Persistence via Storable Protocol

The `Storable` protocol declares an entity-centric state persistence interface based on identity mapping. It provides a standardized data synchronization pipeline while isolating the invoking call site from explicit knowledge of the persistent layer.

### Architecture Characteristics

* **Data Lifecycle Cache Processing**: The underlying data extraction sequence checks the optional `dataCache` property before executing a complete `serialize()` pass. For immutable objects, allocating a pre-computed data buffer inside `dataCache` bypasses repetitive serialization overhead.
* **Compiler Artifact Filtering**: The static `compositeKey(_:)` resolution algorithm evaluates the type hierarchy using metatype reflection (`String(reflecting:)`). It actively strips unexpected context runtime signatures—such as `(unknown context at $` prefixes produced during execution inside dynamic scopes—ensuring predictable dot-separated identifiers.

### Codable Integration Synthesis

For types that already comply with `Codable`, `SwanCore` synthesizes default serialization routines to prevent semantic boilerplate:

```swift
struct OrderRecord: Storable, Codable {
    let id: String
    let amount: Double
    
    // Payload data cache (returning nil forces active serialization)
    var dataCache: Data? { nil }
}

let storage = try FileStorage()
let order = OrderRecord(id: "order_42", amount: 2500.0)

// The infrastructure automatically resolves the deterministic composite key:
// "SwanCore.OrderRecord.order_42"
try storage.store(order)
```

---

## Preferences Optimization via UserDefaults Backend

The standard system `UserDefaults` infrastructure natively conforms to the `PersistentStorage` protocol interface. Because the underlying system defaults framework is intrinsically thread-safe, it naturally aligns with the strict isolation requirements under Swift 6 Concurrency.

### Flat Layout Hierarchy Execution

When processing `Storable` domain entities, this backend explicitly overrides the default protocol storage sequence:

* **Namespace Flattening**: The implementation routes data writes through the entity's primitive `object.id` token instead of its fully qualified `compositeKey`. 
* **Preferences Schema Cleanliness**: This design prevents key-value namespace pollution inside the application's preference `.plist` layout, keeping configuration records clean and highly readable for debugging utilities.

```swift
let defaultsStorage = UserDefaults.standard

// Records the payload using the clean identifier "order_42" instead of a composite path
try defaultsStorage.store(order)
```

---

## File System Backend (FileStorage)

`FileStorage` implements disk-bound persistence targeting isolated sandbox paths (e.g., `.documentDirectory` or `.cachesDirectory`). 

### Concurrency Profile

The structure is marked as `@unchecked Sendable`. Thread safety under strict Swift 6 Concurrency boundaries is guaranteed by the absolute immutability of its core properties (`url` and `fileManager`) combined with the atomic isolation properties of low-level POSIX file operations managed by the OS kernel.

### Operational Verification

* **Upfront Directory Validation**: The initializer verifies path availability immediately upon allocation by forcing intermediate folder hierarchy creation via `fileManager.createDirectory`. This sequence guarantees subfolder infrastructure existence prior to any read or write execution passes.
* **Zero-Overhead Path Evaluation**: The private internal routing utility mapping keys to concrete file URL destinations is annotated with `@inline(__always)` to eliminate function call stack frame construction over frequent input/output boundaries.
