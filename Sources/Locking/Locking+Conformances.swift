//
//  Locking+Conformances.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-07.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation
import os


// ==========================================
// MARK: - OSAllocatedUnfairLock Conformance
// ==========================================

extension OSAllocatedUnfairLock: Locking where State == Void {}


// ==========================================
// MARK: - NSLock Conformance
// ==========================================

extension NSLock: Locking {

    /// Tries to acquire the standard lock instantly.
    @inlinable @inline(__always)
    public func lockIfAvailable() -> Bool {
        self.lock(before: Date())
    }
}


// ==========================================
// MARK: - PosixMutex
// ==========================================

/// A low-level cross-platform mutual exclusion primitive built on `pthread_mutex_t`.
///
/// This delivers a true C++ `std::mutex` style locking mechanism under strict reference semantics.
/// As a `final class`, it guarantees a perfectly stable memory address for the underlying raw C primitive,
/// allowing direct pointer binding inside standard non-mutating protocol requirements.
public final class PosixMutex: Locking, @unchecked Sendable {

    // Raw C-primitive held safely within the class instance memory block
    @usableFromInline internal var mutex = pthread_mutex_t()

    /// Initializes a new instance of `PosixMutex` and registers it with the underlying OS thread scheduler.
    @inlinable public init() { pthread_mutex_init(&mutex, nil) }

    /// Cleans up the native OS resource upon lock destruction.
    @inlinable deinit { pthread_mutex_destroy(&mutex) }

    @inlinable @inline(__always)
    public func lock() { pthread_mutex_lock(&mutex) }

    @inlinable @inline(__always)
    public func unlock() { pthread_mutex_unlock(&mutex) }

    @inlinable @inline(__always)
    public func lockIfAvailable() -> Bool { pthread_mutex_trylock(&mutex) == 0 }
}


// ==========================================
// MARK: - VoidLock
// ==========================================

/// A zero-cost, non-copyable dummy lock structure designed for single-threaded benchmarks.
@frozen public struct VoidLock: Locking, ~Copyable {

    @inlinable @inline(__always) public init() {}
    @inlinable @inline(__always) public func lock() {}
    @inlinable @inline(__always) public func unlock() {}
    @inlinable @inline(__always) public func lockIfAvailable() -> Bool { true }
}
