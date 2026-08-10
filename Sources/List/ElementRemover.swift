//
//  ElementRemover.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-09.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

/// A capability contract layout specifying explicit, isolated node deletion mechanics.
///
/// Encapsulates structural unlinking algorithms, enforcing strict write-isolation policies
/// to safely manipulate collection boundaries across highly concurrent environments.
public protocol ElementRemover: AnyObject, HasHead, HasTail {

    /// Unlinks a specific structural node from the container topology under execution protection.
    ///
    /// - Parameter element: The targeted node instance to be safely excised from the sequence.
    /// - Complexity: O(1)
    @inlinable @inline(__always)
    func remove(_ element: Element)
}

public extension ElementRemover where Self: HasRWLock & HasCount {

    /// Default blueprint algorithm executing O(1) synchronized exclusive node deletion.
    ///
    /// This implementation enforces absolute write-isolation via `lock.writeLock()`. It guarantees
    /// that any active multi-threaded readers are locked out during topology mutation passes,
    /// preventing memory corruption and reference dangling.
    @inlinable @inline(__always)
    func remove(_ element: Element) {
        lock.writeLock()

        if let prev = element.prev {
            prev.next = element.next
        } else {
            assert(element === head)
            head = element.next
        }

        if let next = element.next {
            next.prev = element.prev
        } else {
            assert(element === tail)
            tail = element.prev
        }

        element.next = nil
        element.prev = nil

        count -= 1
        lock.unlock()
    }
}
