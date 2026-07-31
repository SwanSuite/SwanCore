//
//  UserDefaults+PersistentStorage.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

// MARK: - PersistentStorage Conformance

/// Conforms the system standard `UserDefaults` to ``PersistentStorage`` to seamlessly participate in the SwanKit ecosystem.
///
/// Since `UserDefaults` is intrinsically thread-safe and verified by Apple's core frameworks, it naturally aligns
/// with the `Sendable` requirements under Swift 6's compilation constraints.
extension UserDefaults: PersistentStorage {

    /// Stores a specialized ``Storable`` entity using its root primitive identifier rather than a composite namespace.
    ///
    /// This override allows flat key structures within user preference plists for uncomplicated access.
    ///
    /// - Parameter object: The entity instance to persist.
    /// - Throws: An error if storage synchronization fails.
    public func store<T: Storable>(_ object: T) throws {
        try save(object.data, forKey: object.id)
    }

    /// Saves a raw binary data chunk into user defaults under the given string key.
    /// - Parameters:
    ///   - data: The binary payload data sequence.
    ///   - key: The target key for user preferences.
    /// - Throws: Never throws under standard operational state, but signatures mirror the base protocol requirement.
    public func save(_ data: Data, forKey key: String) throws {
        set(data, forKey: key)
    }
}
