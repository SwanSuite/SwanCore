# Dictionary Transformations & RawRepresentable Mappings

The `SwanCore` framework provides functional extensions for the standard `Dictionary` type to streamline hash-table transformations, key-value mapping, and bidirectional conversion between domain enumerations (`RawRepresentable`) and primitive types.

## Core Characteristics

* **Functional Transformations**: `mapToDictionary` and `compactMapToDictionary` enable complete structure modifications within a single call sequence using optimized native swift initializers.
* **Key-Isolated Mapping**: `mapKeys` and `compactMapKeys` mutate key types or formats without reallocating underlying value payloads.
* **Representation Resolution**: `resolveRepresentation` overloads handle data matrices, converting dictionaries between enumeration keys/values and raw structures.
* **Deterministic Filtering**: During raw data reconstruction, `compactMap` passes discard unidentifiable elements or invalid enumeration states.
* **Compiler Optimization**: All transformation methods are marked `@inlinable` to enable direct compiler optimizations during the build phase.
* **Allocation-Free Sequences**: `lazyCompactMapToDictionary` pipes lazy sequences straight into a pre-allocated destination hash table.

---

## Functional Mapping Shorthands

These extensions replace imperative loop structures and intermediate mutable buffers during baseline data mutations:

```swift
import SwanCore

let source = ["one": 1, "skip_me": 2, "three": 3]

// 1. Dictionary mapping with non-nil filtering
let transformed: [String: String] = source.compactMapToDictionary { key, value in
    guard key != "skip_me" else { return nil }
    return (key.uppercased(), String(value * 10))
}
// Result: ["ONE": "10", "THREE": "30"]

// 2. Key-isolated mutation
let dictWithUpperKeys = source.mapKeys { \$0.uppercased() }
// Result: ["ONE": 1, "SKIP_ME": 2, "THREE": 3]
```

---

## Allocation-Free Lazy Transformations

For performance-critical code paths, `lazyCompactMapToDictionary` minimizes heap allocations by streaming a lazy sequence representation (`lazy.compactMap`) into a destination hash table with reserved capacity.

```swift
let heavySource: [String: Int] = /* Large data dictionary */

let efficientResult: [String: String] = heavySource.lazyCompactMapToDictionary { key, value in
    guard value % 2 == 0 else { return nil }
    return (key.camelCasedSnake, "Value_\(value)")
}
```

---

## Enumeration Management via resolveRepresentation

The `resolveRepresentation` framework infers target types from the execution context to manage representation adjustments.

### 1. Enumeration-to-Raw Value Serialization
Converts strictly typed domain representations into primitive types suitable for data serialization layers:

```swift
enum ResponseKey: String { case id = "id_field", status = "status_field" }
enum UserStatus: Int { case pending = 0, active = 1 }

let domainDict: [ResponseKey: UserStatus] = [.id: .active]

// Mapping: [EnumKey: EnumValue] -> [String: Int]
let apiPayload: [String: Int] = domainDict.resolveRepresentation()
```

### 2. Raw-to-Enumeration Deserialization
Reconstructs domain models from primitive types safely by dropping invalid enumeration instances without causing runtime failure:

```swift
let rawInput: [String: Int] = ["id_field": 1, "status_field": 99] // 99 represents an invalid status

// Mapping: [String: Int] -> [ResponseKey: UserStatus]
let cleanDomainDict: [ResponseKey: UserStatus] = rawInput.resolveRepresentation()
// Result: cleanDomainDict[.id] == .active, cleanDomainDict[.status] == nil
```

### 3. Optional Unwrapping Sequence
Specialized overloads strip optional wrappers while applying key-value type modifications in a single execution pass:

```swift
let rawWithNils: [ResponseKey: String?] = [.id: "123", .status: nil]

// Mapping: [EnumKey: Value?] -> [String: Value]
let cleanPayload: [String: String] = rawWithNils.resolveRepresentation()
// Result: cleanPayload.count == 1 (nil entry dropped)
```

---

## Performance Considerations & Compiler Matrix

The `resolveRepresentation` system should be integrated into architecture layers with an awareness of compilation and runtime impacts:

* **Compilation Overhead**: The underlying architecture relies on a multi-tiered generic overload matrix. Complex type inference patterns may increase project compilation times or encounter evaluation complexity limits.
* **Runtime Allocation**: This method constructs an entirely new hash table, allocating fresh buckets and keys. Avoid invoking representation resolutions inside performance-sensitive layout paths or rapid rendering operations. Perform conversions within dedicated data transfer objects (DTO) layers on background queues.

