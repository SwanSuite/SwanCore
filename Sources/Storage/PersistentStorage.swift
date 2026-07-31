//
//  PersistentStorage.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A thread-safe abstraction representing a key-value based persistent storage backend.
///
/// `PersistentStorage` defines a uniform interface for storing and retrieving raw `Data`,
/// standard `Codable` models, and specialized ``Storable`` entities across various underlying
/// mechanisms (such as the local file system or `UserDefaults`).
///
/// ### Thread Safety
/// Conforms to `Sendable`. Conforming implementations must guarantee thread safety
/// under Swift 6 Strict Concurrency constraints, ensuring safe cross-isolation access.
public protocol PersistentStorage: Sendable {

    /// Retrieves a `Decodable` object associated with the specified key.
    /// - Parameter key: A unique string identifying the object entry.
    /// - Returns: The decoded object of type `T`, or `nil` if no data exists for the key.
    /// - Throws: An error if data retrieval succeeds but serialization / decoding fails.
    func retrieveObject<T: Decodable>(forKey key: String) throws -> T?

    /// Stores an `Encodable` object and associates it with the specified key.
    /// - Parameters:
    ///   - object: The encodable entity instance to persist.
    ///   - key: A unique string identifying the storage location.
    /// - Throws: An error if serialization or writing to the persistent store fails.
    func store<T: Encodable>(_ object: T, forKey key: String) throws

    /// Retrieves a specialized ``Storable`` entity associated with the specified key.
    /// - Parameter key: The entity's identification token.
    /// - Returns: An initialized instance of `T`, or `nil` if no data is found.
    /// - Throws: An error if initialization or data parsing fails.
    func retrieveObject<T: Storable>(forKey key: String) throws -> T?

    /// Stores a specialized ``Storable`` entity using its structural type metadata.
    /// - Parameter object: The domain entity conforming to ``Storable``.
    /// - Throws: An error if persistence operations fail.
    func store<T: Storable>(_ object: T) throws

    /// Removes an object or data block associated with the specified key.
    /// - Parameter key: The unique target storage key.
    func removeObject(forKey key: String) throws

    /// Retrieves raw binary data associated with the specified key.
    /// - Parameter key: The unique storage key.
    /// - Returns: The associated `Data` buffer, or `nil` if the key does not exist.
    func data(forKey key: String) -> Data?

    /// Saves raw binary data under the specified key identifier.
    /// - Parameters:
    ///   - data: The binary payload representation to persist.
    ///   - key: A unique storage key.
    /// - Throws: An error if the atomic write operation fails.
    func save(_ data: Data, forKey key: String) throws
}

// MARK: - Default Implementations

public extension PersistentStorage {

    func retrieveObject<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func store<T: Encodable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        try save(data, forKey: key)
    }

    func retrieveObject<T: Storable>(forKey key: String) throws -> T? {
        guard let data = data(forKey: T.compositeKey(key)) else { return nil }
        return try T(id: key, data: data)
    }

    func store<T: Storable>(_ object: T) throws {
        try save(object.data, forKey: object.compositeKey)
    }
}

// MARK: - Fluent API Extensions

public extension Encodable {

    /// Conveniently saves an `Encodable` object into a specified storage target.
    /// - Parameters:
    ///   - id: The unique key for the storage entry.
    ///   - storage: The target ``PersistentStorage`` provider.
    /// - Throws: An execution error if encoding or disk operation fails.
    @inlinable
    func save(for id: String, to storage: PersistentStorage) throws {
        try storage.store(self, forKey: id)
    }
}

public extension Decodable {

    /// Conveniently loads a `Decodable` object from a specified storage target.
    /// - Parameters:
    ///   - id: The unique key of the storage entry.
    ///   - storage: The target ``PersistentStorage`` provider.
    /// - Returns: An instance of `Self`, or `nil` if not present.
    /// - Throws: An error if decoding fails.
    @inlinable
    static func load(id: String, from storage: PersistentStorage) throws -> Self? {
        try storage.retrieveObject(forKey: id)
    }
}
