//
//  Dictionary+compactMapToDictionary.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

public extension Dictionary {
    /// Transforms the dictionary by applying a closure that returns an optional key-value pair, omitting any `nil` results.
    ///
    /// - Parameter transform: A closure that takes a key-value pair and returns an optional key-value pair.
    /// - Returns: A new dictionary containing only the non-nil transformed elements.
    @inlinable
    func compactMapToDictionary<K: Hashable, V>(_ transform: (Key, Value) throws -> (K, V)?) rethrows -> [K: V] {
        [K: V](uniqueKeysWithValues: try compactMap(transform))
    }

    /// Transforms only the keys of the dictionary, omitting pairs where the key transformation returns `nil`.
    ///
    /// - Parameter transform: A closure that takes a key and returns an optional hashable key.
    /// - Returns: A new dictionary with successfully transformed keys.
    @inlinable
    func compactMapKeys<K: Hashable>(_ transform: (Key) throws -> K?) rethrows -> [K: Value] {
        try compactMapToDictionary { key, value in
            guard
                let key = try transform(key)
            else { return nil }
            return (key, value)
        }
    }

    /// Transforms only the keys of a dictionary containing optional values, omitting pairs where either the key transformation or the original value is `nil`.
    ///
    /// - Parameter transform: A closure that takes a key and returns an optional hashable key.
    /// - Returns: A new dictionary with unwrapped values and successfully transformed keys.
    @inlinable
    func compactMapKeys<K: Hashable, V>(_ transform: (Key) throws -> K?) rethrows -> [K: V]
    where Value == Optional<V> {
        try compactMapToDictionary { key, value in
            guard
                let value,
                let key = try transform(key)
            else { return nil }
            return (key, value)
        }
    }

    /// Unwraps and filters a dictionary containing optional values, removing any pairs with `nil` values.
    ///
    /// - Returns: A new dictionary containing only the non-nil values.
    @inlinable
    func compactMapValues<V>() -> [Key: V] where Value == Optional<V> {
        compactMapValues { $0 }
    }
}
