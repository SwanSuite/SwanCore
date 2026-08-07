//
//  Emptyable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation
import CoreGraphics

// MARK: - Operator Definition

infix operator ~?: NilCoalescingPrecedence
postfix operator ~!

/// A protocol for types that have a distinct, well-defined "empty" state.
///
/// Types conforming to `Emptyable` provide a uniform way to check if an instance is empty
/// and define a standard static default instance representing emptiness.
///
/// ### Swift 6 Concurrency
/// Inherits from `Sendable` to guarantee thread-safe transfers across concurrent task boundaries.
public protocol Emptyable: Sendable {

    /// A Boolean value indicating whether the instance is empty.
    var isEmpty: Bool { get }

    /// The canonical static identity representing the empty state of this type.
    static var empty: Self { get }
}

public extension Emptyable {

    /// A Boolean value indicating whether the instance contains content (is not empty).
    var isNotEmpty: Bool { !isEmpty }

    /// A dynamic nil-coalescing equivalent fallback operator for empty types.
    ///
    /// Evaluates the left operand, returning it directly if it contains content (`isNotEmpty`),
    /// otherwise routes execution flow onto the right fallback operand. Inherits `NilCoalescingPrecedence`
    /// to support left-associative multi-operand chaining pipelines flawlessly.
    ///
    /// ```swift
    /// let name = cachedName ~? legacyName ~? "Default Identity"
    /// ```
    @inlinable
    static func ~? (left: Self, right: Self) -> Self {
        left.isEmpty ? right : left
    }
}

// MARK: - Optional Extension

public extension Optional where Wrapped: Emptyable {

    /// Unwraps the optional value, returning its content if present, or the type's static default `empty` state if `nil`.
    ///
    /// ```swift
    /// let title: String? = nil
    /// print(title.orEmpty) // Outputs: ""
    /// ```
    @inlinable
    var orEmpty: Wrapped {
        self ?? Wrapped.empty
    }

    /// A safe postfix unwrap operator that unwraps an optional type into its non-optional empty fallback layout.
    ///
    /// Acts as a non-crashing, elegant alternative to the native forced unwrap operator (`!`).
    /// ```swift
    /// let name: String? = nil
    /// print(name~!) // Outputs: ""
    /// ```
    @inlinable
    static postfix func ~! (value: Wrapped?) -> Wrapped {
        value.orEmpty
    }
}

// MARK: - Standard Types Conformance

extension String: Emptyable {
    /// Returns an empty string instance `""`.
    public static var empty: Self { "" }
}

extension Array: Emptyable {
    /// Returns an empty array collection instance `[]`.
    public static var empty: Self { [] }
}

extension Dictionary: Emptyable {
    /// Returns an empty dictionary collection instance `[:]`.
    public static var empty: Self { [:] }
}

extension Set: Emptyable {
    /// Returns an empty set collection instance `[]`.
    public static var empty: Self { [] }
}

extension Data: Emptyable {
    /// Returns an empty binary data stream buffer container.
    public static var empty: Self { Data() }
}

// MARK: - BinaryInteger Universal Automation

public extension BinaryInteger where Self: Emptyable {

    /// Evaluates whether the current integer instance value is equal to zero.
    @inlinable
    var isEmpty: Bool { self == .zero }

    /// Returns the standard default fallback numeric identity `.zero` (0).
    @inlinable
    static var empty: Self { .zero }
}

// MARK: - Explicit Integer Registrations

extension UInt: Emptyable {}
extension UInt32: Emptyable {}
extension UInt64: Emptyable {}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, *)
extension UInt128: Emptyable {}

extension Int: Emptyable {}
extension Int32: Emptyable {}
extension Int64: Emptyable {}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, *)
extension Int128: Emptyable {}

// MARK: - FloatingPoint Universal Automation

public extension FloatingPoint where Self: Emptyable {

    /// Evaluates whether the current floating-point instance value is equal to zero.
    @inlinable
    var isEmpty: Bool { self == .zero }

    /// Returns the standard default fallback floating-point identity `.zero` (0.0).
    @inlinable
    static var empty: Self { .zero }
}

// MARK: - Explicit FloatingPoint Registrations

extension Float: Emptyable {}
extension Double: Emptyable {}
extension CGFloat: Emptyable {}

// MARK: - Core Graphics Structures

extension CGPoint: Emptyable {
    /// Evaluates whether the current physical point matches the absolute logical coordinate origin `.zero`.
    @inlinable public var isEmpty: Bool { self == .zero }
    /// Returns a standardized coordinate location sequence set exactly onto `.zero` coordinates.
    @inlinable public static var empty: Self { .zero }
}

extension CGSize: Emptyable {
    /// Evaluates whether the current dimension vector metrics are equal to zero.
    @inlinable public var isEmpty: Bool { self == .zero }
    /// Returns a standard physical layout sizing object set directly onto `.zero` constants boundaries.
    @inlinable public static var empty: Self { .zero }
}

extension CGRect: Emptyable {
    /// Returns a standard flat rectangular framing canvas box positioned securely onto `.zero` constants origins.
    ///
    /// Note: The custom layout protocol explicitly defers its dynamic `isEmpty` evaluations down to the
    /// native CoreGraphics system framework implementation rules to prevent method shadowing collisions.
    @inlinable public static var empty: Self { .zero }
}
