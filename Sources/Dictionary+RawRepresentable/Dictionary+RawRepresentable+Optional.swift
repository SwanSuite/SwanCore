//
//  Dictionary+RawRepresentable+Optional.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

public extension Dictionary {
    /// Filters and strips out `nil` values from a dictionary, returning a clean non-optional mapping.
    ///
    /// Goes from `[Key: Value?]` to `[Key: Value]`.
    @inlinable
    func resolveRepresentation<V>() -> [Key: V] where Value == Optional<V> {
        compactMapValues()
    }

    /// Maps optional `RawRepresentable` values into their non-optional raw equivalents, removing any `nil` entries.
    ///
    /// Goes from `[Key: EnumValue?]` to `[Key: RawValue]`.
    @inlinable
    func resolveRepresentation<V, W>() -> [Key: V]
    where Value == Optional<W>, W: RawRepresentable, V == W.RawValue {
        compactMapValues { $0?.rawValue }
    }

    /// Maps optional raw values into their non-optional reconstructed `RawRepresentable` equivalents, removing any `nil` or initialization failures.
    ///
    /// Goes from `[Key: RawValue?]` to `[Key: TargetedEnumValue]`.
    @inlinable
    func resolveRepresentation<V, W>() -> [Key: V]
    where Value == Optional<W>, V: RawRepresentable, V.RawValue == W {
        compactMapValues { value in
            guard let value else { return nil }
            return V(rawValue: value)
        }
    }

    /// Reconstructs raw keys into a targeted `RawRepresentable` type while filtering out any pairs with optional `nil` values.
    ///
    /// Goes from `[RawKey: Value?]` to `[TargetedEnumKey: Value]`.
    @inlinable
    func resolveRepresentation<K, V>() -> [K: V]
    where K: RawRepresentable, K.RawValue == Key, Value == Optional<V> {
        compactMapKeys { K(rawValue: $0) }
    }

    /// Transforms raw keys into a targeted `RawRepresentable` type, and converts optional `RawRepresentable` values into their raw values, eliminating any `nil` occurrences.
    ///
    /// Goes from `[RawKey: EnumValue?]` to `[TargetedEnumKey: RawValue]`.
    @inlinable
    func resolveRepresentation<K, V, W>() -> [K: V]
    where K: RawRepresentable, K.RawValue == Key, Value == Optional<W>, W: RawRepresentable, V == W.RawValue {
        compactMapToDictionary { key, value in
            guard
                let key = K(rawValue: key),
                let value
            else { return nil }
            return (key, value.rawValue)
        }
    }

    /// Transforms raw keys into a targeted `RawRepresentable` type, and reconstructs optional raw values into another targeted `RawRepresentable` type, filtering out any `nil` steps along the way.
    ///
    /// Goes from `[RawKey: RawValue?]` to `[TargetedEnumKey: TargetedEnumValue]`.
    @inlinable
    func resolveRepresentation<K, V, W>() -> [K: V]
    where K: RawRepresentable, K.RawValue == Key, Value == Optional<W>, V: RawRepresentable, V.RawValue == W {
        compactMapToDictionary { key, value in
            guard
                let key = K(rawValue: key),
                let value,
                let value = V(rawValue: value)
            else { return nil }
            return (key, value)
        }
    }
}
