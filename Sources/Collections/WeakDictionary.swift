//
//  WeakDictionary.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-17.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation
import os

/// A thread-safe, memory-efficient dictionary that stores its values using weak references.
///
/// Automatically purges dead key-value pairs during subscript lookups when the underlying
/// objects are released by the system.
public struct WeakDictionary<Key: Hashable & Sendable, Value: AnyObject>: @unchecked Sendable {

    private var dict: [Key: WeakWrapper<Value>] = [:]
    private let lock = OSAllocatedUnfairLock()

    public init() {}

    /// Accesses or modifies the weakly-held value associated with the given key.
    ///
    /// Setting a value to `nil` immediately discards the element node from the store.
    /// - Parameter key: A unique hashable structures identifier key sequence.
    /// - Returns: The weakly cached element object of type `Value`, or `nil` if missing or deallocated.
    public subscript(key: Key) -> Value? {
        mutating get {
            lock.lock()
            defer { lock.unlock() }

            guard let wrapper = dict[key] else { return nil }

            if wrapper.wrapped == nil {
                dict.removeValue(forKey: key)
                return nil
            }

            return wrapper.wrapped
        }
        set {
            lock.lock()
            defer { lock.unlock() }

            if let newValue = newValue {
                dict[key] = WeakWrapper(newValue)
            } else {
                dict.removeValue(forKey: key)
            }
        }
    }

    /// Explicitly removes the specified key and its associated weak value from the dictionary.
    /// - Parameter key: The unique key element sequence to remove.
    public mutating func removeValue(forKey key: Key) {
        lock.lock()
        defer { lock.unlock() }
        dict.removeValue(forKey: key)
    }
}

// MARK: - Internal

struct WeakWrapper<T: AnyObject> {
    weak var wrapped: T?
    private let id: ObjectIdentifier

    init(_ object: T) {
        wrapped = object
        id = .init(object)
    }
}

extension WeakWrapper: Hashable {
    static func == (lhs: WeakWrapper<T>, rhs: WeakWrapper<T>) -> Bool {
        return lhs.wrapped === rhs.wrapped
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

extension WeakWrapper where T: Hashable {
    static func == (lhs: WeakWrapper<T>, rhs: WeakWrapper<T>) -> Bool {
        guard let lw = lhs.wrapped, let rw = rhs.wrapped else {
            return lhs.wrapped === rhs.wrapped
        }
        return lw == rw
    }
}
