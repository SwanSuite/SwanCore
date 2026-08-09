//
//  AdaptiveSpinLock.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-07.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation
import os

/// An ultra-fast, non-copyable stack-allocated structural lock with OS backward compatibility.
///
/// Automatically scales based on the host OS capability:
/// - On iOS 18.0+ / macOS 15.0+: Leverages native hardware-assisted adaptive spinning.
/// - On older OS targets: Uses a hybrid "Spin-then-Block" algorithm. It performs a limited number
///   of active spin attempts before safely suspending the thread via `underlying.lock()`,
///   preventing priority inversion and zero-benefit CPU burning.
///
/// Being a non-copyable structure (`~Copyable`), it incurs zero heap allocation overhead
/// while explicitly restricting any bitwise memory replication attempts at compile time.
@frozen
public struct AdaptiveSpinLock: Locking, ~Copyable {

    @usableFromInline internal let underlying: OSAllocatedUnfairLock<Void>

    /// The maximum number of spin attempts allowed on fallback OS targets before suspending the thread.
    /// Ignored completely on modern OS targets supporting native adaptive spinning.
    @usableFromInline internal let attemptsMax: Int

    /// Initializes a new unique instance of `AdaptiveSpinLock` with standard default settings.
    ///
    /// Available on all OS deployment targets. Automatically applies native hardware adaptive spinning
    /// on newer platforms, and falls back to a safe 100-cycle software spinning threshold on older ones.
    @inlinable
    public init() {
        self.underlying = OSAllocatedUnfairLock()
        self.attemptsMax = 100
    }

    /// Initializes a new unique instance of `AdaptiveSpinLock` with a customizable software spinning threshold.
    ///
    /// Available as a fallback configuration or explicit override for older operating system targets.
    /// Deprecated on modern deployment targets where hardware adaptive spinning renders manual adjustments obsolete.
    /// - Parameter attemptsMax: The limit of active CPU spin loop cycles before forcing thread suspension. Defaults to 100.
    @available(macOS, deprecated: 15.0, message: "Manual spinning thresholds are ignored on macOS 15.0+; use the parameterless init() instead.")
    @available(iOS, deprecated: 18.0, message: "Manual spinning thresholds are ignored on iOS 18.0+; use the parameterless init() instead.")
    @available(tvOS, deprecated: 18.0, message: "Manual spinning thresholds are ignored on tvOS 18.0+; use the parameterless init() instead.")
    @available(watchOS, deprecated: 11.0, message: "Manual spinning thresholds are ignored on watchOS 11.0+; use the parameterless init() instead.")
    @available(visionOS, deprecated: 2.0, message: "Manual spinning thresholds are ignored on visionOS 2.0+; use the parameterless init() instead.")
    @inlinable
    public init(attemptsMax: Int) {
        self.underlying = OSAllocatedUnfairLock()
        self.attemptsMax = attemptsMax
    }

    @inlinable @inline(__always)
    public func lock() {
        if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            underlying.lock(flags: .adaptiveSpin)
        } else {
            // Software simulated "Spin-then-Block" strategy
            let maxThreshold = attemptsMax
            for _ in 0..<maxThreshold {
                if underlying.lockIfAvailable() {
                    return // Lock acquired successfully during the spin phase
                }
            }

            // Fallback to absolute thread suspension if the spin phase timed out
            underlying.lock()
        }
    }

    @inlinable @inline(__always)
    public func unlock() {
        underlying.unlock()
    }

    @inlinable @inline(__always)
    public func lockIfAvailable() -> Bool {
        underlying.lockIfAvailable()
    }

    /// Executes a closure within an exclusive critical section driven by adaptive spinning.
    @discardableResult @inlinable @inline(__always)
    public func withLock<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R {
        if #available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            return try underlying.withLock(flags: .adaptiveSpin, body)
        } else {
            self.lock()
            defer { self.unlock() }
            return try body()
        }
    }
}
