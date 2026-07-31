//
//  Codable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

public extension JSONDecoder {

    /// Decodes a type from the given data, inferring the target type from the call site context.
    ///
    /// This helper eliminates the need to explicitly pass `T.self` when the compiler can already deduce the type.
    ///
    /// - Parameter data: The raw JSON data sequence buffer.
    /// - Returns: A decoded object of the inferred type `T`.
    /// - Throws: An error if the data is not valid JSON or type matching fails.
    @inlinable
    func decode<T: Decodable>(_ data: Data) throws -> T {
        try decode(T.self, from: data)
    }
}

public extension Encodable {

    /// Encodes the instance into binary data utilizing a specified or default JSON encoder configuration.
    ///
    /// - Parameter encoder: The pre-configured encoder registry instance to employ. Defaults to a fresh `JSONEncoder()`.
    /// - Returns: A `Data` container holding the serialized JSON representation.
    /// - Throws: An encoding error if any value throws an error during serialization.
    @inlinable
    func encode(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
}

public extension Decodable {

    /// Initializes an instance by decoding binary data using a specified or default JSON decoder instance.
    ///
    /// - Parameters:
    ///   - data: The raw serialized JSON representation payload.
    ///   - decoder: The decoder engine instance to employ. Defaults to a fresh `JSONDecoder()`.
    /// - Returns: An initialized instance of `Self`.
    /// - Throws: A decoding error if data properties do not match the expected type schema layout.
    @inlinable
    static func decode(data: Data, decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        try decoder.decode(Self.self, from: data)
    }
}

public extension Data {

    /// Decodes the binary data contents into a structural type inferred from the call site context.
    ///
    /// ```swift
    /// let user: User = try rawData.decode()
    /// ```
    ///
    /// - Parameter decoder: The decoder engine instance to employ. Defaults to a fresh `JSONDecoder()`.
    /// - Returns: A decoded object of the inferred type `T`.
    /// - Throws: An error if decoding fails due to structural or data type corruption.
    @inlinable
    func decode<T: Decodable>(decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}

// MARK: - CustomizableCodingKeyMapping

/// A protocol designed for coding keys that support dynamic redirection or naming translations.
///
/// Types conforming to `CustomizableCodingKeyMapping` enable customized data schemas by providing
/// a calculated mapping rule target property for seamless transformation layers during encoding or decoding steps.
///
/// ### Swift 6 Concurrency
/// Inherits from `Sendable` via `CodingKey` to guarantee thread-safe transfers across asynchronous execution contexts.
public protocol CustomizableCodingKeyMapping: CodingKey, Sendable {

    /// The mapped target `CodingKey` token representation used for substitution.
    var mapped: CodingKey { get }
}

public extension CustomizableCodingKeyMapping {

    /// Provides a default identity mapping fallback returning the active self instance state.
    @inlinable
    var mapped: CodingKey { self }
}
