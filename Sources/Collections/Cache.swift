//
//  Cache.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A protocol for objects that can express their mathematical resource cost weight within a cache environment.
public protocol Costable {

    /// The specific resource cost weight units (e.g., total bytes, image pixels count) allocated by this instance.
    var cost: Int { get }
}

/// A thread-safe, strongly typed in-memory caching wrapper built around the native system `NSCache`.
///
/// `Cache` provides automatic eviction behaviors when low memory pressure signals occur on the OS level,
/// while maintaining clear generic boundaries `<Key, Value>` for type-safe subscript access loops.
///
/// ### Swift 6 Concurrency Semantics
/// Fully conforms to native `Sendable` requirements. Leverages an immutable state structure combined
/// with thread-safe atomic underlying locks provided by the native `NSCache` engine.
///
/// ### Example Usage:
/// ```swift
/// let tokenCache = Cache<String, NSString>(onWillEvictObject: { evictedToken in
///     print("Token was dropped from memory: \(evictedToken)")
/// })
/// tokenCache.countLimit = 100
///
/// tokenCache["user_id_42"] = "auth_token_string"
/// if let token = tokenCache["user_id_42"] {
///     print("Extracted cached token payload: \(token)")
/// }
/// ```
public final class Cache<Key: Hashable, Value: AnyObject>: Sendable {

    /// A thread-safe closure block signature invoked when an object is about to be evicted from the store.
    public typealias ValueHandler = @Sendable (Value) -> Void

    // MARK: - Private Core Configurations

    private let cache = NSCache<KeyAdapter<Key>, Value>()
    private let delegateProxy: DelegateHandler?

    /// Instantiates a clean, thread-safe in-memory cache registry container with an eviction interceptor closure.
    /// - Parameter onWillEvictObject: A `@Sendable` closure triggered before an object is discarded by the system.
    public init(onWillEvictObject: ValueHandler? = nil) {
        delegateProxy = DelegateHandler(onWillEvictObject)
        cache.delegate = delegateProxy
    }

    /// Accesses or modifies the strongly typed cache value payload associated with the specified key.
    ///
    /// Setting a value to `nil` immediately isolates and discards the element node from the receiver store.
    ///
    /// - Parameter key: A unique hashable structures identifier key sequence.
    /// - Returns: The cached element object of type `Value`, or `nil` if the entry is missing or was evicted.
    public subscript(key: Key) -> Value? {
        get {
            cache.object(forKey: KeyAdapter(key))
        }
        set {
            if let newValue {
                cache.setObject(newValue, forKey: KeyAdapter(key))
            } else {
                cache.removeObject(forKey: KeyAdapter(key))
            }
        }
    }

    /// Flushes and purges all active stored elements from the memory registry layer instantly.
    public func clear() {
        cache.removeAllObjects()
    }

    /// The maximum total number of items the cache store is allowed to retain before triggering automatic eviction loops.
    public var countLimit: Int {
        get { cache.countLimit }
        set { cache.countLimit = newValue }
    }
}

// MARK: - Specialized Costable Boundaries Extensions

extension Cache where Value: Costable {

    /// The maximum integrated cost total weight the cache container is allowed to hold before initiating item purging.
    public var totalCostLimit: Int {
        get { cache.totalCostLimit }
        set { cache.totalCostLimit = newValue }
    }

    /// Accesses or modifies the cost-aware cache value payload associated with the specified key identifier.
    ///
    /// This specialized overload automatically reads the item's metric properties to enforce exact cost constraint bounds.
    ///
    /// - Parameter key: A unique hashable structures identifier key sequence.
    /// - Returns: The costable cached element object of type `Value`, or `nil` if not present.
    public subscript(key: Key) -> Value? {
        get {
            cache.object(forKey: KeyAdapter(key))
        }
        set {
            if let newValue {
                if totalCostLimit != 0 {
                    cache.setObject(newValue, forKey: KeyAdapter(key), cost: newValue.cost)
                } else {
                    cache.setObject(newValue, forKey: KeyAdapter(key))
                }
            } else {
                cache.removeObject(forKey: KeyAdapter(key))
            }
        }
    }
}

// Retroactively inject strict compiler-level concurrency approval flags onto the legacy system collection class
extension NSCache: @unchecked @retroactive Sendable {}


// MARK: - Private Interceptor Framework Layer

/// An internal type-eraser object hash adapter bridging native Swift `Hashable` structures into Objective-C `NSObject` pointers.
private final class KeyAdapter<T: Hashable>: NSObject {
    let value: T

    init(_ value: T) {
        self.value = value
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? KeyAdapter<T> else { return false }
        return self.value == other.value
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(value)
        return hasher.finalize()
    }
}

private extension Cache {

    /// A private, localized interceptor proxy translating native `NSCacheDelegate` target messages into modern thread-safe execution handlers.
    final class DelegateHandler: NSObject, NSCacheDelegate, Sendable {
        private let handler: ValueHandler

        init?(_ handler: ValueHandler?) {
            guard let handler else { return nil }
            self.handler = handler
        }

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let value = obj as? Value else { return }
            handler(value)
        }
    }
}
