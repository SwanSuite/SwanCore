//
//  RWLocking+Conformances.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-08.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation
import os

// ==========================================
// MARK: - OSAllocatedUnfairLock Conformance
// ==========================================

// High-performance Exclusive Fallback for Apple's native lock under RWLocking requirements.
extension OSAllocatedUnfairLock: RWLocking where State == Void {

    /// Maps shared read access directly to the native exclusive lock path.
    @inlinable @inline(__always)
    public borrowing func readLock() { lock() }

    /// Maps exclusive write access directly to the native exclusive lock path.
    @inlinable @inline(__always)
    public borrowing func writeLock() { lock() }

    /// Tries to acquire a shared read lock exclusively without blocking.
    @inlinable @inline(__always)
    public borrowing func tryReadLock() -> Bool { lockIfAvailable() }

    /// Tries to acquire an exclusive write lock without blocking.
    @inlinable @inline(__always)
    public borrowing func tryWriteLock() -> Bool { lockIfAvailable() }
}

// ==========================================
// MARK: - PosixRWLock Conformance
// ==========================================

/// A low-level cross-platform shared-exclusive lock built directly on `pthread_rwlock_t`.
///
/// Fully utilizes separate kernel paths for maximum parallel reading performance.
/// As a `final class`, it guarantees a perfectly stable memory address for the underlying raw C primitive,
/// allowing direct pointer binding inside standard non-mutating protocol requirements.
public final class PosixRWLock: RWLocking, @unchecked Sendable {

    /// The raw POSIX read-write lock structure.
    @usableFromInline internal var rwlock = pthread_rwlock_t()

    /// Initializes a new POSIX Read-Write lock with default attributes.
    @inlinable
    public init() { pthread_rwlock_init(&rwlock, nil) }

    /// Cleans up the native OS resource upon lock destruction.
    deinit { pthread_rwlock_destroy(&rwlock) }

    @inlinable @inline(__always) public borrowing func readLock() { pthread_rwlock_rdlock(&rwlock) }
    @inlinable @inline(__always) public borrowing func writeLock() { pthread_rwlock_wrlock(&rwlock) }
    @inlinable @inline(__always) public borrowing func unlock() { pthread_rwlock_unlock(&rwlock) }
    @inlinable @inline(__always) public borrowing func tryReadLock() -> Bool { pthread_rwlock_tryrdlock(&rwlock) == 0 }
    @inlinable @inline(__always) public borrowing func tryWriteLock() -> Bool { pthread_rwlock_trywrlock(&rwlock) == 0 }
}


// ==========================================
// MARK: - VoidRWLock Conformance
// ==========================================

/// A zero-cost dummy shared lock structure performing no actual synchronization operations.
///
/// **Warning:** This implementation is completely thread-unsafe.
/// Designed for deterministic single-threaded benchmarks to completely factor out lock overhead.
@frozen
public struct VoidRWLock: RWLocking {

    /// Initializes a new instance of `VoidRWLock`.
    @inlinable
    public init() {}

    @inlinable @inline(__always) public borrowing func readLock() {}
    @inlinable @inline(__always) public borrowing func writeLock() {}
    @inlinable @inline(__always) public borrowing func unlock() {}
    @inlinable @inline(__always) public borrowing func tryReadLock() -> Bool { true }
    @inlinable @inline(__always) public borrowing func tryWriteLock() -> Bool { true }
}
