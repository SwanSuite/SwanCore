//
//  MapTable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A type-safe, high-performance wrapper around the system native `NSMapTable` collection framework.
///
/// `MapTable` models advanced object relationship graphs by allowing granular configuration of memory
/// retention topologies (such as weak-to-strong or strong-to-weak references) for both keys and values.
/// This flexibility seamlessly solves memory leaks and circular retain cycles inherent to standard Swift `Dictionary` containers.
///
/// ### Example Usage:
/// ```swift
/// // Construct a delegate registry that does not retain its listener keys in memory
/// let registry = MapTable<AnyObject, UIViewController>.weakToStrongObjects()
///
/// registry[listenerToken] = currentController
/// ```
public final class MapTable<Key: AnyObject, Value: AnyObject> {

    /// Instantiates a new map table instance that strongly retains both its structural keys and value elements.
    ///
    /// Behaves dynamically analogous to a standard `Dictionary` mapped via reference type constraints.
    ///
    /// - Returns: A tailored `MapTable` instance utilizing strong-to-strong memory semantics.
    public static func strongToStrongObjects() -> MapTable<Key, Value> {
        self.init(mapTable: NSMapTable<Key, Value>.strongToStrongObjects())
    }

    /// Instantiates a new map table instance that weakly references its keys while strongly retaining its value elements.
    ///
    /// When an external key reference falls out of scope, the system runtime automatically garbage-collects
    /// the entry from the table map during subsequent allocations.
    ///
    /// - Returns: A tailored `MapTable` instance utilizing weak-to-strong memory semantics.
    public static func weakToStrongObjects() -> MapTable<Key, Value> {
        self.init(mapTable: NSMapTable<Key, Value>.weakToStrongObjects())
    }

    /// Instantiates a new map table instance that strongly retains its keys while weakly referencing its value elements.
    ///
    /// Ideal for establishing back-pointer topologies or cache registries where value nodes must evaporate once un-referenced elsewhere.
    ///
    /// - Returns: A tailored `MapTable` instance utilizing strong-to-weak memory semantics.
    public static func strongToWeakObjects() -> MapTable<Key, Value> {
        self.init(mapTable: NSMapTable<Key, Value>.strongToWeakObjects())
    }

    /// Instantiates a new map table instance that maintains zero-cost weak references for both its keys and value elements.
    ///
    /// - Returns: A tailored `MapTable` instance utilizing weak-to-weak memory semantics.
    public static func weakToWeakObjects() -> MapTable<Key, Value> {
        self.init(mapTable: NSMapTable<Key, Value>.weakToWeakObjects())
    }

    /// Accesses or modifies the strongly typed value payload associated with the specified object reference key.
    ///
    /// Assigning a value element to `nil` immediately isolates and discards the key-value junction entry from the receiver table.
    ///
    /// - Parameter key: A unique object identifier reference key matching the constraints configuration profile.
    /// - Returns: The mapped element object of type `Value`, or `nil` if the entry is missing or was swept by the runtime.
    public subscript(key: Key) -> Value? {
        get {
            mapTable.object(forKey: key)
        }
        set {
            if let newValue {
                mapTable.setObject(newValue, forKey: key)
            } else {
                mapTable.removeObject(forKey: key)
            }
        }
    }

    /// Flushes and purges all active reference objects from the internal storage matrix layout instantly.
    public func clear() {
        mapTable.removeAllObjects()
    }

    // MARK: - Private Core Configurations

    private let mapTable: NSMapTable<Key, Value>

    private init(mapTable: NSMapTable<Key, Value>) {
        self.mapTable = mapTable
    }
}
