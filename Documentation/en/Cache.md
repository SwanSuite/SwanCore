# Costable Protocol & Cache Class

A versatile, strongly typed, and thread-safe wrapper around `NSCache` that supports any Swift `Sendable` type as a value and features automatic resource cost calculations.

## 📋 Overview

The `Cache` class provides a modern Swift interface for efficient in-memory data storage. Powered by an internal `ValueWrapper` container, it entirely bypasses the constraints of the legacy underlying `NSCache`. It allows any standard Swift `Hashable` type to be used as a key and any `Sendable` type to be used as a value—including pure structures (`String`, `Array`, `Dictionary`), enums, and reference classes.

## ✨ Key Features

* **Value Types Support:** No more manual boilerplate boxing for structs or collections. The wrapper infrastructure is fully encapsulated within the private implementation layer.
* **Memory Pressure Eviction:** Automatically discards internal entries when the operating system triggers low-memory warnings.
* **Swift 6 Concurrency Ready:** Fully conforms to `Sendable`. Thread safety for concurrent read/write access loops is enforced by the native atomic constraints of the system engine.
* **Eviction Interception:** Allows you to supply a thread-safe `@Sendable` closure executed immediately before an element is discarded by the OS.

## 🛠 Cost-Aware Caching

When a cached value conforms to the `Costable` protocol, the sub-system automatically extracts its `cost` weight during assignment. This allows you to restrict the container using cumulative metrics (`totalCostLimit`), such as raw byte sizes, leveraging out-of-the-box extensions for `String`, `Array`, `Dictionary`, `Data`, and `NSData`.

## 🚀 Usage Example

```swift
import SwanCore
import Foundation

// 1. Setup a cache for pure Swift structures (Key: String, Value: String)
// String: Costable conformance ensures the total cost tracks the exact UTF-8 byte count.
let searchCache = Cache<String, String> { evictedQuery in
    print("Evicted search query string with character length: \(evictedQuery.count)")
}

// Restrict the memory footprint pool size (e.g., maximum 50,000 bytes/characters)
searchCache.totalCostLimit = 50_000

// 2. Write and Read operations with no reference-type boilerplate
searchCache["last_query"] = "Heavy database execution search results payload string..."

if let cachedPayload = searchCache["last_query"] {
    print("Extracted cached value: \(cachedPayload)")
}
```
