//
//  Dictionary+mapToDictionary.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

public extension Dictionary {
    /// Transforms the dictionary into a new dictionary by applying a closure to all elements.
    ///
    /// - Parameter transform: A closure that takes a key-value pair and returns a new key-value pair.
    /// - Returns: A new dictionary containing the transformed keys and values.
    @inlinable
    func mapToDictionary<K: Hashable, V>(_ transform: (Key, Value) throws -> (K, V)) rethrows -> [K: V] {
        [K: V](uniqueKeysWithValues: try map(transform))
    }

    /// Transforms only the keys of the dictionary using the provided closure while keeping the original values.
    ///
    /// - Parameter transform: A closure that takes a key and returns a new hashable key.
    /// - Returns: A new dictionary with transformed keys and original values.
    @inlinable
    func mapKeys<K: Hashable>(_ transform: (Key) throws -> K) rethrows -> [K: Value] {
        try mapToDictionary { key, value in
            (try transform(key), value)
        }
    }
}
