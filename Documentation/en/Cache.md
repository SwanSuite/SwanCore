# Costable Protocol & Cache Class

A versatile, strongly typed, and thread-safe wrapper around `NSCache` that supports any Swift `Sendable` type as a value and features automatic resource cost calculations.

## 📋 Overview

The `Cache` class provides a modern Swift interface for efficient in-memory data storage. Powered by an internal `ValueWrapper` container, it entirely bypasses the reference-type constraints of the underlying legacy `NSCache`. It allows any standard Swift `Hashable` type to be used as a key and any `Sendable` type to be used as a value—including pure structures (`String`, `Array`, `Dictionary`), enums, and reference classes.

## ✨ Key Features

* **Value Types Support:** Eliminates manual boilerplate boxing for structures or collections. The wrapper infrastructure is fully encapsulated within the private implementation layer.
* **Memory Pressure Eviction:** Automatically discards internal entries when the operating system triggers low-memory notifications.
* **Swift 6 Concurrency Ready:** Fully conforms to `Sendable`. Thread safety for concurrent read/write access loops is guaranteed by underlying thread-safe platform synchronization.
* **Eviction Interception:** Supports an optional thread-safe `@Sendable` closure executed immediately before an element is evicted from the cache.

## 🛠 Cost-Aware Caching

When a cached value conforms to the `Costable` protocol, the sub-system automatically extracts its `cost` weight during assignment. This allows you to restrict the container footprint using cumulative metrics (`totalCostLimit`), such as raw byte sizes, leveraging out-of-the-box extensions for types like `String`, `Array`, `Dictionary`, `Data`, and `NSData`.

## 🚀 Usage Example

```swift
import SwanCore
import Foundation

// 1. Setup a cache for pure Swift structures (Key: String, Value: String)
// String: Costable conformance ensures the total cost tracks the exact UTF-8 byte count.
let searchCache = Cache<String, String> { evictedQuery in
    print("Evicted search query string with byte length: \(evictedQuery.utf8.count)")
}

// Restrict the memory footprint pool size (e.g., maximum 50,000 bytes)
searchCache.totalCostLimit = 50_000

// 2. Write and Read operations with no reference-type boilerplate
searchCache["last_query"] = "Heavy database execution search results payload string..."

if let cachedPayload = searchCache["last_query"] {
    print("Extracted cached value: \(cachedPayload)")
}
```
