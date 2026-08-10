//
//  Emptiable+Conformances.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation
import CoreGraphics

// MARK: - Standard Types Conformance

extension String: Blankable {
    /// Returns an empty string instance `""`.
    public static var empty: Self { "" }
}

extension Array: Blankable {
    /// Returns an empty array collection instance `[]`.
    public static var empty: Self { [] }
}

extension Dictionary: Blankable {
    /// Returns an empty dictionary collection instance `[:]`.
    public static var empty: Self { [:] }
}

extension Set: Blankable {
    /// Returns an empty set collection instance `[]`.
    public static var empty: Self { [] }
}

extension Data: Blankable {
    /// Returns an empty binary data stream buffer container.
    public static var empty: Self { Data() }
}

// MARK: - BinaryInteger Universal Automation

public extension BinaryInteger where Self: Blankable {

    /// Evaluates whether the current integer instance value is equal to zero.
    @inlinable
    var isEmpty: Bool { self == .zero }

    /// Returns the standard default fallback numeric identity `.zero` (0).
    @inlinable
    static var empty: Self { .zero }
}

// MARK: - Explicit Integer Registrations

extension UInt: Blankable {}
extension UInt32: Blankable {}
extension UInt64: Blankable {}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, *)
extension UInt128: Blankable {}

extension Int: Blankable {}
extension Int32: Blankable {}
extension Int64: Blankable {}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, *)
extension Int128: Blankable {}

// MARK: - FloatingPoint Universal Automation

public extension FloatingPoint where Self: Blankable {

    /// Evaluates whether the current floating-point instance value is equal to zero.
    @inlinable
    var isEmpty: Bool { self == .zero }

    /// Returns the standard default fallback floating-point identity `.zero` (0.0).
    @inlinable
    static var empty: Self { .zero }
}

// MARK: - Explicit FloatingPoint Registrations

extension Float: Blankable {}
extension Double: Blankable {}
extension CGFloat: Blankable {}

// MARK: - Core Graphics Structures

extension CGPoint: Blankable {
    /// Evaluates whether the current physical point matches the absolute logical coordinate origin `.zero`.
    @inlinable public var isEmpty: Bool { self == .zero }
    /// Returns a standardized coordinate location sequence set exactly onto `.zero` coordinates.
    @inlinable public static var empty: Self { .zero }
}

extension CGSize: Blankable {
    /// Evaluates whether the current dimension vector metrics are equal to zero.
    @inlinable public var isEmpty: Bool { self == .zero }
    /// Returns a standard physical layout sizing object set directly onto `.zero` constants boundaries.
    @inlinable public static var empty: Self { .zero }
}

extension CGRect: Blankable {
    /// Returns a standard flat rectangular framing canvas box positioned securely onto `.zero` constants origins.
    ///
    /// Note: The custom layout protocol explicitly defers its dynamic `isEmpty` evaluations down to the
    /// native CoreGraphics system framework implementation rules to prevent method shadowing collisions.
    @inlinable public static var empty: Self { .zero }
}
