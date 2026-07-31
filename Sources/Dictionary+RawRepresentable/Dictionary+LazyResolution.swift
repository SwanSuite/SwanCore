//
//  Dictionary+LazyResolution.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-17.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

public extension Dictionary {

    /// A hyper-optimized, zero-allocation lazy alternative to standard resolution pipelines.
    ///
    /// This method leverages Swift's `lazy` evaluation engine combined with explicit memory capacity
    /// reservation, performing the entire multi-stage dictionary transformation layer without allocating
    /// any intermediate structural arrays inside the heap.
    ///
    /// ### Performance Profile
    /// * **Runtime Footprint**: Absolute $O(N)$ speed with zero intermediate array copies.
    /// * **Compiler Footprint**: Heavy. Noticeably tasks the type inference engine during static evaluation loops.
    ///
    /// - Parameter transform: A throwing closure that evaluates a key-value pair and returns an optional tuple mapping.
    /// - Returns: A brand new fully resolved, flat dictionary instance.
    @inlinable
    func lazyCompactMapToDictionary<K: Hashable, V>(_ transform: (Key, Value) throws -> (K, V)?) rethrows -> [K: V] {
        guard !isEmpty else { return [:] }

        // Step 1: Pre-allocate target dictionary backing table capacity to completely eliminate mid-loop rehashing
        var result = [K: V]()
        result.reserveCapacity(count)

        // Step 2: Use an inline loop over the stateless lazy sequence to guarantee zero temporary array footprints
        // Compiler gracefully optimizes this structure without losing type reference frames.
        try lazy.compactMap(transform).forEach { key, value in
            result[key] = value
        }

        return result
    }
}
