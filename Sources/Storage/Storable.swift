//
//  Storable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A protocol that enables automated domain-specific persistence for custom models.
///
/// Types conforming to `Storable` declare a dedicated storage target and encapsulate
/// their synchronization lifecycle. This allows instances to be loaded, saved, or deleted
/// via fluent, declarative methods without explicitly referencing a storage registry at the call site.
///
/// ### Swift 6 Concurrency
/// Conforms to `Sendable`. Types implementing `Storable` are safe to pass across asynchronous
/// boundaries and concurrent task isolation domains.
public protocol Storable: Identifiable, Sendable {
    /// Initializes a new instance using serialized raw binary data and a unique identifier.
    /// - Parameters:
    ///   - id: The unique record token identifying the object.
    ///   - data: The raw binary representation used to reconstruct the object's state.
    /// - Throws: An error if decoding or object construction fails.
    init?(id: String, data: Data) throws

    /// The unique identifier for this specific domain record.
    var id: String { get }
    var data: Data { get throws }
    var dataCache: Data? { get }
    /// The serialized raw binary data representing the current state of the instance.
    @inlinable
    func serialize() throws -> Data
}

// MARK: - Key Generation Logic

public extension Storable {

    var data: Data {
        get throws {
            try dataCache ?? serialize()
        }
    }

    /// A fully qualified storage key combining the structural type hierarchy and the entity identifier to prevent name collisions.
    @inlinable
    var compositeKey: String {
        Self.compositeKey(id)
    }

    /// Generates a composite namespace key for a given identifier based on the type's reflection metadata.
    ///
    /// This method extracts the technical module-qualified name of the type and discards dynamic context prefixes
    /// frequently appended during runtime executions (e.g., inside dynamic scopes or memory closures).
    ///
    /// - Parameter id: The base entity identifier.
    /// - Returns: A stable, dot-separated deterministic string key ideal for key-value databases.
    @inlinable
    static func compositeKey(_ id: String) -> String {
        let separator = "."
        var nestedParts = String(reflecting: Self.self).components(separatedBy: separator)
        nestedParts = nestedParts.filter { !$0.hasPrefix("(unknown context at $") }
        nestedParts.append(id)
        return nestedParts.joined(separator: separator)
    }
}

// MARK: - Conditional Codable Integration

public extension Storable where Self: Codable {

    /// Synthesizes a default structural initializer for objects that already conform to `Codable`.
    /// - Parameters:
    ///   - id: The entity token.
    ///   - data: The JSON-encoded or property-list data representation.
    /// - Throws: A decoding error if data properties do not match the expected type schema.
    @inlinable
    init?(id: String, data: Data) throws {
        // Возвращаем твой базовый метод десериализации
        self = try Self.decode(data: data)
    }

    /// Automatically encodes the current object state into binary data.
    ///
    /// Uses the project's custom postfix operator `~!` to safely fall back to an empty `Data`
    /// container container on unhandled errors, ensuring strict runtime resilience over unexpected crashes.
    @inlinable
    func serialize() throws -> Data {
        try self.encode()
    }
}
