//
//  Emptiable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

// MARK: - Operator Definition

infix operator ~?: NilCoalescingPrecedence
postfix operator ~!

/// A protocol for types that can evaluate whether they are in an empty state.
public protocol Emptiable {

    /// A Boolean value indicating whether the instance is empty.
    var isEmpty: Bool { get }
}

/// A protocol for types that provide a canonical static instance representing absolute emptiness.
public protocol Blankable: Emptiable {

    /// The canonical static identity representing the empty state of this type.
    static var empty: Self { get }
}

// MARK: - Emptiable Extension

public extension Emptiable {

    /// A Boolean value indicating whether the instance contains content (is not empty).
    @inlinable
    var isNotEmpty: Bool { !isEmpty }

    /// A dynamic fallback operator for empty types.
    ///
    /// Evaluates the left operand, returning it directly if it contains content (`isNotEmpty`),
    /// otherwise routes execution flow onto the right fallback operand.
    @inlinable
    static func ~? (left: Self, right: Self) -> Self {
        left.isEmpty ? right : left
    }
}

// MARK: - Optional Extension

public extension Optional where Wrapped: Blankable {

    /// Unwraps the optional value, returning its content if present, or the type's static default `empty` state if `nil`.
    @inlinable
    var orEmpty: Wrapped {
        self ?? Wrapped.empty
    }

    /// A safe postfix unwrap operator that unwraps an optional type into its non-optional empty fallback layout.
    @inlinable
    static postfix func ~! (value: Wrapped?) -> Wrapped {
        value.orEmpty
    }
}
