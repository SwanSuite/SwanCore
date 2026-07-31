//
//  JSONEncodingExt.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

public extension JSONEncoder {

    /// Initializes a `JSONEncoder` instance pre-configured with a specific key encoding strategy.
    ///
    /// - Parameter strategy: The `KeyEncodingStrategy` to use for altering object property names during serialization.
    convenience init(_ strategy: KeyEncodingStrategy) {
        self.init()
        self.keyEncodingStrategy = strategy
    }

    /// Initializes a `JSONEncoder` instance pre-configured with a specific binary data encoding strategy.
    ///
    /// - Parameter strategy: The `DataEncodingStrategy` to use for formatting raw binary payloads.
    convenience init(_ strategy: DataEncodingStrategy) {
        self.init()
        self.dataEncodingStrategy = strategy
    }

    /// Initializes a `JSONEncoder` instance pre-configured with a specific date encoding strategy.
    ///
    /// - Parameter strategy: The `DateEncodingStrategy` to use for formatting temporal types into JSON values.
    convenience init(_ strategy: DateEncodingStrategy) {
        self.init()
        self.dateEncodingStrategy = strategy
    }

    /// Initializes a `JSONEncoder` instance pre-configured with a specific non-conforming floating-point numbers encoding strategy.
    ///
    /// - Parameter strategy: The `NonConformingFloatEncodingStrategy` to apply when serializing exceptional numeric markers (such as NaN or Infinity).
    convenience init(_ strategy: NonConformingFloatEncodingStrategy) {
        self.init()
        self.nonConformingFloatEncodingStrategy = strategy
    }
}

// MARK: - Fluent Configuration API

public extension JSONEncoder {

    /// Establishes the key encoding strategy using a declarative fluent syntax.
    ///
    /// - Parameter strategy: The target key formatting behavior.
    /// - Returns: The modified `JSONEncoder` instance for method chaining configuration.
    func keyEncodingStrategy(_ strategy: KeyEncodingStrategy) -> JSONEncoder {
        self.keyEncodingStrategy = strategy
        return self
    }

    /// Establishes the date encoding strategy using a declarative fluent syntax.
    ///
    /// - Parameter strategy: The target date formatting behavior.
    /// - Returns: The modified `JSONEncoder` instance for method chaining configuration.
    func dateEncodingStrategy(_ strategy: DateEncodingStrategy) -> JSONEncoder {
        self.dateEncodingStrategy = strategy
        return self
    }

    /// Establishes the binary data encoding strategy using a declarative fluent syntax.
    ///
    /// - Parameter strategy: The target payload serialization behavior.
    /// - Returns: The modified `JSONEncoder` instance for method chaining configuration.
    func dataEncodingStrategy(_ strategy: DataEncodingStrategy) -> JSONEncoder {
        self.dataEncodingStrategy = strategy
        return self
    }

    /// Establishes the non-conforming float encoding strategy using a declarative fluent syntax.
    ///
    /// - Parameter strategy: The target float verification behavior.
    /// - Returns: The modified `JSONEncoder` instance for method chaining configuration.
    func nonConformingFloatEncodingStrategy(_ strategy: NonConformingFloatEncodingStrategy) -> JSONEncoder {
        self.nonConformingFloatEncodingStrategy = strategy
        return self
    }
}

// MARK: - Custom Dynamic Coding Key Strategies

public extension JSONEncoder.KeyEncodingStrategy {

    /// Generates a flexible key encoding strategy capable of dynamically routing keys via protocol metadata abstractions.
    ///
    /// This method evaluates the active path tree. Foundation guarantees that the `keys` array passed into the
    /// `.custom` interceptor block is never empty during an active key evaluation loop. Thus, `keys.last!` safely extracts
    /// the node undergoing serialization.
    ///
    /// If the node complies with `CustomizableCodingKeyMapping`, its explicit mapped token properties are invoked.
    /// Otherwise, it maps the naming structure onto a standard fallback descriptor of type `T`.
    ///
    /// - Parameter type: A specific `CodingKey`-conforming schema type utilized for fallback instantiations.
    /// - Returns: A tailored `KeyEncodingStrategy` engine block.
    static func customizable<T: CodingKey>(_ type: T.Type) -> Self {
        .custom { (keys) -> CodingKey in
            let last = keys.last!
            if let customizable = last as? CustomizableCodingKeyMapping {
                return customizable.mapped
            }
            return T(stringValue: last.stringValue) ?? last
        }
    }

    /// An extended serialization strategy that automatically formats camelCase attributes into uppercase `SCREAMING_SNAKE_CASE`
    /// while fully preserving dynamic key redirections matching the `CustomizableCodingKeyMapping` layout rules.
    static let convertToScreamingSnakeCase = customizable(ScreamingSnakeKey.self)
}

// MARK: - Concrete Key Maps

/// A concrete `CodingKey` implementation designed to convert standard camelCase code attributes into `SCREAMING_SNAKE_CASE` keys.
///
/// ### Array Index Safety Semantics
/// This structure is tailored exclusively for serializing structural objects (dictionaries). When working with array elements,
/// the encoder requests index mapping via `init(intValue:)`. Passing integers here indicates a structural mapping irregularity
/// or invalid encoding lifecycle context.
///
/// To preserve encoder stability without introducing silent failures, `stringValue` safely wraps the integer value
/// into a text string representation, whereas the internal `intValue` remains explicitly unassigned (`nil`) to signal
/// that this schema component does not represent a valid array subscript index within the snake-case conversion boundary.
public struct ScreamingSnakeKey: CodingKey {

    /// Initializes a coding key by converting a standard camelCase text sequence into a `SCREAMING_SNAKE_CASE` layout template.
    ///
    /// - Parameter stringValue: The incoming property name.
    public init?(stringValue: String) {
        self.stringValue = stringValue.camelCaseTo_SCREAMING_SNAKE
    }

    /// Handles data schema array structural subscripts during serialization.
    ///
    /// Intercepts accidental array indices by converting them into strings for fallback tracking,
    /// keeping `intValue` unassigned to denote an out-of-scope conversion layout.
    ///
    /// - Parameter intValue: The indexing value provided by the encoding runtime.
    public init?(intValue: Int) {
        stringValue = String(intValue)
    }

    /// The string text identifier assigned to this serialization token.
    public var stringValue: String

    /// The numeric index identifier, intentionally returning `nil` to declare an invalid array subscript context.
    public var intValue: Int?
}
