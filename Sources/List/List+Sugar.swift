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
    /// Left-associativity enables horizontal data pipelining from left to right: `list <+ 1 <+ 2`
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator <+: TailAppendPrecedence

precedencegroup HeadPushPrecedence {
    /// Right-associativity enables vertical data pipelining from right to left: `2 +> 1 +> list`
    associativity: right
    higherThan: AssignmentPrecedence
}

infix operator +>: HeadPushPrecedence

postfix operator ^
prefix operator ^


// ==========================================
// MARK: - Dynamic Targeting Extensions
// ==========================================

public extension FrontAppendable where Self: BackAppendable {

    /// Pushes a fully structural node into the collection at the specified boundary axis.
    ///
    /// - Parameters:
    ///   - element: The pre-allocated node instance to insert.
    ///   - target: The target structural axis boundary (`.front` or `.back`).
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

    /// Automatically encapsulates a raw sendable business object and pushes it at the specified boundary axis.
    ///
    /// - Parameters:
    ///   - object: The non-optional thread-safe business payload item.
    ///   - target: The target structural axis boundary (`.front` or `.back`).
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

    /// Extracts and unlinks a structural node from the specified collection boundary axis.
    ///
    /// - Parameter target: The target structural axis boundary (`.front` or `.back`).
    /// - Returns: The unlinked node wrapper instance, or `nil` if the targeted boundary is empty.
    @discardableResult @inlinable @inline(__always)
    func pop(_ target: ModifyTarget) -> Element? {
        switch target {
        case .front: popFront()
        case .back: popBack()
        }
    }
}

public extension FrontRemovable where Self: BackRemovable, Element: ObjectContainer {

    /// Extracts a structural node from the specified boundary axis and unwraps its inner business payload.
    ///
    /// - Parameter target: The target structural axis boundary (`.front` or `.back`).
    /// - Returns: The sendable business object payload item, or `nil` if the targeted boundary is empty.
    @discardableResult @inlinable @inline(__always)
    func pop(_ target: ModifyTarget) -> Element.T? {
        switch target {
        case .front: popFront()
        case .back: popBack()
        }
    }
}
