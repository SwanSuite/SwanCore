//
//  List+Sugar.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-08.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

// ==========================================
// MARK: - Precedence Groups & Operators
// ==========================================

precedencegroup TailAppendPrecedence {
    /// Configures left-associative data flow to support horizontal linear pipelining.
    ///
    /// This precedence alignment allows items to be progressively appended to the tail
    /// of a collection using a continuous left-to-right syntax chain: `list <+ 1 <+ 2`.
    associativity: left
    higherThan: AssignmentPrecedence
}

/// The tail-append infix operator driving fluent horizontal collection pipelines.
infix operator <+: TailAppendPrecedence

precedencegroup HeadPushPrecedence {
    /// Configures right-associative data flow to support vertical stacked pipelining.
    ///
    /// This precedence alignment allows items to be progressively prepended to the head
    /// of a collection using a right-to-left evaluation order: `2 +> 1 +> list`.
    associativity: right
    higherThan: AssignmentPrecedence
}

/// The head-push infix operator driving fluent vertical stacked pipelines.
infix operator +>: HeadPushPrecedence

/// The postfix boundary extraction operator optimized for tail-end slicing routines.
postfix operator ^

/// The prefix boundary extraction operator optimized for head-first popping routines.
prefix operator ^


// ==========================================
// MARK: - Dynamic Targeting Extensions
// ==========================================

public extension FrontAppendable where Self: BackAppendable {

    /// Pushes a pre-allocated structural node into the collection at the designated boundary target axis.
    ///
    /// Dynamically routes execution paths based on the runtime state of the provided `ModifyTarget`.
    ///
    /// - Parameters:
    ///   - element: The pre-allocated structural node instance to link into the topology.
    ///   - target: The explicit operational axis boundary layout (`.front` or `.back`).
    /// - Returns: A reference to the modified container `Self` to drive Fluent API pipelines.
    @discardableResult @inlinable @inline(__always)
    func push(_ element: Element, target: ModifyTarget) -> Self {
        switch target {
        case .front: pushFront(element)
        case .back: pushBack(element)
        }
    }
}

public extension FrontAppendable where Self: BackAppendable, Element: ObjectContainer {

    /// Automatically encapsulates a raw sendable business object into a container node and inserts it at the specified boundary axis.
    ///
    /// - Parameters:
    ///   - object: The non-optional thread-safe business payload item to encapsulate.
    ///   - target: The explicit operational axis boundary layout (`.front` or `.back`).
    /// - Returns: A reference to the modified container `Self` to drive Fluent API pipelines.
    @discardableResult @inlinable @inline(__always)
    func push(_ object: Element.T, target: ModifyTarget) -> Self {
        switch target {
        case .front: pushFront(object)
        case .back: pushBack(object)
        }
    }
}

public extension FrontRemovable where Self: BackRemovable {

    /// Extracts and unlinks a raw structural element container wrapper from the targeted collection boundary axis.
    ///
    /// - Parameter target: The explicit operational axis boundary layout (`.front` or `.back`).
    /// - Returns: The completely unlinked node instance wrapper, or `nil` if the targeted collection boundary axis is empty.
    @discardableResult @inlinable @inline(__always)
    func pop(_ target: ModifyTarget) -> Element? {
        switch target {
        case .front: popFront()
        case .back: popBack()
        }
    }
}

public extension FrontRemovable where Self: BackRemovable, Element: ObjectContainer {

    /// Extracts a structural element container wrapper from the targeted axis boundary and safely unwraps its internal business payload.
    ///
    /// - Parameter target: The explicit operational axis boundary layout (`.front` or `.back`).
    /// - Returns: The detached sendable business object payload item, or `nil` if the targeted collection boundary axis is empty.
    @discardableResult @inlinable @inline(__always)
    func pop(_ target: ModifyTarget) -> Element.T? {
        switch target {
        case .front: popFront()
        case .back: popBack()
        }
    }
}
