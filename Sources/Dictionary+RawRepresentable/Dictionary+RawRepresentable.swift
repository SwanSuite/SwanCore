//
//  Dictionary+RawRepresentable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

public extension Dictionary where Key: RawRepresentable {
    /// Converts a dictionary with `RawRepresentable` keys into a dictionary indexed by their raw values.
    ///
    /// Goes from `[EnumKey: Value]` to `[RawKey: Value]`.
    @inlinable
    func resolveRepresentation<K: Hashable>() -> [K: Value]
    where Key.RawValue == K {
        mapKeys { $0.rawValue }
    }

    /// Maps a dictionary with `RawRepresentable` keys into a dictionary indexed by raw keys, while simultaneously reconstructing values into a targeted `RawRepresentable` type.
    ///
    /// Goes from `[EnumKey: RawValue]` to `[RawKey: TargetedEnumValue]`.
    @inlinable
    func resolveRepresentation<K: Hashable, V>() -> [K: V]
    where Key.RawValue == K, V: RawRepresentable, V.RawValue == Value {
        compactMapToDictionary { key, value in
            guard
                let value = V(rawValue: value)
            else { return nil }
            return (key.rawValue, value)
        }
    }

    // MARK: Optional Value

    /// Converts a dictionary with `RawRepresentable` keys and optional values into a non-optional dictionary indexed by raw keys.
    ///
    /// Goes from `[EnumKey: Value?]` to `[RawKey: Value]`.
    @inlinable
    func resolveRepresentation<K, V>() -> [K: V]
    where Key.RawValue == K, Value == Optional<V> {
        compactMapKeys { $0.rawValue }
    }

    /// Maps a dictionary with `RawRepresentable` keys and optional `RawRepresentable` values into a non-optional dictionary containing raw keys and raw values.
    ///
    /// Goes from `[EnumKey: EnumValue?]` to `[RawKey: RawValue]`.
    @inlinable
    func resolveRepresentation<K, V, W>() -> [K: V]
    where Key.RawValue == K, Value == Optional<W>, W: RawRepresentable, V == W.RawValue {
        compactMapToDictionary { key, value in
            guard let value else { return nil }
            return (key.rawValue, value.rawValue)
        }
    }

    /// Maps a dictionary with `RawRepresentable` keys and optional raw values into a non-optional dictionary containing raw keys and reconstructed targeted `RawRepresentable` values.
    ///
    /// Goes from `[EnumKey: RawValue?]` to `[RawKey: TargetedEnumValue]`.
    @inlinable
    func resolveRepresentation<K, V, W>() -> [K: V]
    where Key.RawValue == K, Value == Optional<W>, V: RawRepresentable, V.RawValue == W {
        compactMapToDictionary { key, value in
            guard
                let value,
                let value = V(rawValue: value)
            else { return nil }
            return (key.rawValue, value)
        }
    }
}

// MARK: - Value: RawRepresentable

public extension Dictionary where Value: RawRepresentable {
    /// Replaces `RawRepresentable` values with their underlying raw values.
    ///
    /// Goes from `[Key: EnumValue]` to `[Key: RawValue]`.
    @inlinable
    func resolveRepresentation<V>() -> [Key: V] where Value.RawValue == V {
        mapValues { $0.rawValue }
    }

    /// Replaces raw keys with their reconstructed `RawRepresentable` type, while simultaneously mapping values to their underlying raw representation.
    ///
    /// Goes from `[RawKey: EnumValue]` to `[TargetedEnumKey: RawValue]`.
    @inlinable
    func resolveRepresentation<K, V>() -> [K: V]
    where K: RawRepresentable, K.RawValue == Key, Value.RawValue == V {
        compactMapToDictionary { key, value in
            guard
                let key = K(rawValue: key)
            else { return nil }
            return (key, value.rawValue)
        }
    }
}

// MARK: - Key: RawRepresentable, Value: RawRepresentable

public extension Dictionary where Key: RawRepresentable, Value: RawRepresentable {
    /// Converts a dictionary where both keys and values are `RawRepresentable` into a representation made entirely of their raw equivalents.
    ///
    /// Goes from `[EnumKey: EnumValue]` to `[RawKey: RawValue]`.
    @inlinable
    func resolveRepresentation<K: Hashable, V>() -> [K: V] where Key.RawValue == K, Value.RawValue == V {
        mapToDictionary { key, value in
            return (key.rawValue, value.rawValue)
        }
    }
}

// MARK: - K: RawRepresentable / V: RawRepresentable

public extension Dictionary {
    /// Reconstructs raw dictionary keys into a targeted `RawRepresentable` type, removing pairs that fail initialization.
    ///
    /// Goes from `[RawKey: Value]` to `[TargetedEnumKey: Value]`.
    @inlinable
    func resolveRepresentation<K: Hashable>() -> [K: Value]
    where K: RawRepresentable, K.RawValue == Key {
        compactMapKeys { K(rawValue: $0) }
    }

    /// Reconstructs raw dictionary values into a targeted `RawRepresentable` type, removing pairs that fail initialization.
    ///
    /// Goes from `[Key: RawValue]` to `[Key: TargetedEnumValue]`.
    @inlinable
    func resolveRepresentation<V>() -> [Key: V]
    where V: RawRepresentable, V.RawValue == Value {
        compactMapValues { V(rawValue: $0) }
    }

    /// Reconstructs both keys and values from their raw representations into targeted `RawRepresentable` types.
    ///
    /// Goes from `[RawKey: RawValue]` to `[TargetedEnumKey: TargetedEnumValue]`.
    @inlinable
    func resolveRepresentation<K: Hashable, V>() -> [K: V]
    where K: RawRepresentable, K.RawValue == Key, V: RawRepresentable, V.RawValue == Value {
        compactMapToDictionary { key, value in
            guard
                let key = K(rawValue: key),
                let value = V(rawValue: value)
            else { return nil }
            return (key, value)
        }
    }
}
