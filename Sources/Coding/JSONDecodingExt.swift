//
//  JSONDecodingExt.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

public extension JSONDecoder {

    /// Initializes a decoder pre-configured with a specific key decoding strategy.
    /// - Parameter strategy: The strategy to use for turning JSON keys into coding keys.
    convenience init(strategy: KeyDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = strategy
    }

    /// Initializes a decoder pre-configured with a specific data decoding strategy.
    /// - Parameter strategy: The strategy to use for decoding raw data binary blocks.
    convenience init(strategy: DataDecodingStrategy) {
        self.init()
        self.dataDecodingStrategy = strategy
    }

    /// Initializes a decoder pre-configured with a specific date decoding strategy.
    /// - Parameter strategy: The strategy to use for formatting JSON date representations.
    convenience init(strategy: DateDecodingStrategy) {
        self.init()
        self.dateDecodingStrategy = strategy
    }

    /// Initializes a decoder pre-configured with a specific non-conforming float decoding strategy.
    /// - Parameter strategy: The strategy to use for exceptional numeric float values (e.g., NaN, Infinity).
    convenience init(strategy: NonConformingFloatDecodingStrategy) {
        self.init()
        self.nonConformingFloatDecodingStrategy = strategy
    }
}

// MARK: - Fluent Configuration API (Builder Pattern)

public extension JSONDecoder {

    /// Configures the key decoding strategy using a fluent interface.
    /// - Parameter strategy: The target key decoding strategy.
    /// - Returns: The configured decoder instance (`Self`) for method chaining.
    @discardableResult
    func keyDecodingStrategy(_ strategy: KeyDecodingStrategy) -> Self {
        self.keyDecodingStrategy = strategy
        return self
    }

    /// Configures the date decoding strategy using a fluent interface.
    /// - Parameter strategy: The target date decoding strategy.
    /// - Returns: The configured decoder instance (`Self`) for method chaining.
    @discardableResult
    func dateDecodingStrategy(_ strategy: DateDecodingStrategy) -> Self {
        self.dateDecodingStrategy = strategy
        return self
    }

    /// Configures the data decoding strategy using a fluent interface.
    /// - Parameter strategy: The target data decoding strategy.
    /// - Returns: The configured decoder instance (`Self`) for method chaining.
    @discardableResult
    func dataDecodingStrategy(_ strategy: DataDecodingStrategy) -> Self {
        self.dataDecodingStrategy = strategy
        return self
    }

    /// Configures the non-conforming float decoding strategy using a fluent interface.
    /// - Parameter strategy: The target float decoding strategy.
    /// - Returns: The configured decoder instance (`Self`) for method chaining.
    @discardableResult
    func nonConformingFloatDecodingStrategy(_ strategy: NonConformingFloatDecodingStrategy) -> Self {
        self.nonConformingFloatDecodingStrategy = strategy
        return self
    }
}

// MARK: - Custom Dynamic Coding Key Strategies

public extension JSONDecoder.KeyDecodingStrategy {

    /// Creates a customizable key decoding strategy capable of routing keys dynamically via metadata protocols.
    ///
    /// This strategy inspects incoming keys. If a key conforms to ``CustomizableCodingKeyMapping``,
    /// it triggers its dynamic redirection rules. Otherwise, it instantiates a placeholder key of type `T`.
    ///
    /// - Parameter type: A `CodingKey`-conforming type used as a structural fallback layout framework.
    /// - Returns: A brand new tailored `KeyDecodingStrategy` instance.
    @inlinable
    static func customizable<T: CodingKey>(_ type: T.Type) -> Self {
        .custom { (keys) -> CodingKey in
            let last = keys.last!
            if let customizable = last as? CustomizableCodingKeyMapping {
                return customizable.mapped
            }
            return T(stringValue: last.stringValue) ?? last
        }
    }

    /// An extended snake_case decoding strategy that dynamically bridges properties to camelCase
    /// while retaining compatibility with automated custom key mapping redirections.
    static let convertFromSnakeCaseExtended = customizable(CamelKey.self)
}

// MARK: - Concrete Key Maps

/// A concrete `CodingKey` implementation designed to dynamically convert snake_case JSON strings into camelCase attributes.
public struct CamelKey: CodingKey {

    /// Initializes a key by automatically transforming a snake_case input text into a camelCase layout representation.
    public init?(stringValue: String) {
        self.stringValue = stringValue.camelCasedSnake
    }

    public init?(intValue: Int) {
        stringValue = String(intValue)
    }

    public var stringValue: String
    public var intValue: Int?
}
