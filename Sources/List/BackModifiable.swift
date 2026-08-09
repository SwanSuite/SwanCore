//
//  BackModifiable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-08.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

// ==========================================
// MARK: - BackModifiable Composition
// ==========================================

/// A unified capability composition combining back-end (tail) data insertion and extraction traits.
public typealias BackModifiable = BackAppendable & BackRemovable


// ==========================================
// MARK: - BackAppendable Specification
// ==========================================

/// A capability contract layout for collections supporting tail-first (back) node insertion.
public protocol BackAppendable: AnyObject, HasTail {
    associatedtype Element

    /// Appends a fully initialized structural node to the tail of the container.
    ///
    /// - Parameter element: The pre-allocated node instance to link.
    /// - Returns: A reference to the modified container `Self` to drive Fluent API pipelines.
    @discardableResult @inlinable @inline(__always)
    func pushBack(_ element: Element) -> Self
}

public extension BackAppendable {

    /// An alias for appending a node to the tail of the collection.
    @discardableResult @inlinable @inline(__always)
    func pushTail(_ element: Element) -> Self { pushBack(element) }

    /// A generic data-injection alias for tail insertion.
    @discardableResult @inlinable @inline(__always)
    func add(_ element: Element) -> Self { pushBack(element) }

    /// A standard storage-naming alias for appending a node wrapper.
    @discardableResult @inlinable @inline(__always)
    func append(_ element: Element) -> Self { pushBack(element) }

    /// Appends a structural node onto the tail of the collection via left-associative syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static func <+ (list: Self, element: Element) -> Self { list.pushBack(element) }

    /// Appends a structural node onto the tail via the alternative combined syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static func += (list: Self, element: Element) -> Self { list.pushBack(element) }
}

public extension BackAppendable where Element: ObjectContainer {

    /// Automatically encapsulates a raw sendable business object into a new node container and appends it to the tail.
    ///
    /// - Parameter object: The non-optional thread-safe business payload item.
    @discardableResult @inlinable @inline(__always)
    func pushBack(_ object: Element.T) -> Self { pushBack(Element(object)) }

    /// An alias for wrapping and appending a raw business object payload to the tail.
    @discardableResult @inlinable @inline(__always)
    func pushTail(_ object: Element.T) -> Self { pushBack(object) }

    /// Wraps a raw business object and appends it onto the tail via left-associative syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static func <+ (list: Self, object: Element.T) -> Self { list.pushBack(object) }

    /// Wraps a raw business object and appends it onto the tail via the combined syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static func += (list: Self, object: Element.T) -> Self { list.pushBack(object) }
}

public extension BackAppendable where Self: HasRWLock & HasHead & HasCount, Element: BidirectionalConnection {

    /// Default blueprint algorithm executing O(1) synchronized bi-directional tail insertion.
    ///
    /// Statically bound by the compiler when the container provides full structural metrics and locks.
    @discardableResult @inlinable @inline(__always)
    func pushBack(_ element: Element) -> Self {
        lock.writeLock()
        if head == nil {
            head = element
        }
        element.prev = tail
        tail?.next = element
        tail = element
        count += 1
        lock.unlock()
        return self
    }
}


// ==========================================
// MARK: - BackRemovable Specification
// ==========================================

/// A capability contract layout for collections supporting tail-first (back) node extraction.
public protocol BackRemovable: AnyObject, HasTail where Element: ForwardConnection {

    /// Extracts and unlinks the current tail node from the collection topology.
    ///
    /// - Returns: The unlinked node wrapper instance, or `nil` if the container is empty.
    @discardableResult @inlinable @inline(__always)
    func popBack() -> Element?
}

public extension BackRemovable {

    /// An alias for extracting the last node from the collection.
    @discardableResult @inlinable @inline(__always)
    func popTail() -> Element? { popBack() }

    /// Unlinks the tail node and returns it directly via postfix syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static postfix func ^ (list: Self) -> Element? { list.popBack() }
}

public extension BackRemovable where Element: ObjectContainer {

    /// Extracts the tail node and unwraps its inner business object payload.
    ///
    /// - Returns: The sendable business object payload item, or `nil` if the container is empty.
    @discardableResult @inlinable @inline(__always)
    func popBack() -> Element.T? { popBack()?.object }

    /// An alias for extracting and unwrapping the tail node payload.
    @discardableResult @inlinable @inline(__always)
    func popTail() -> Element.T? { popBack() }

    /// Unlinks the tail node and unwraps its business payload via postfix syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static postfix func ^ (list: Self) -> Element.T? { list.popBack() }
}

public extension BackRemovable where Self: HasRWLock & HasHead & HasCount, Element: BidirectionalConnection {

    /// Default blueprint algorithm executing O(1) synchronized bi-directional tail extraction.
    ///
    /// Correctly re-anchors the `head` node if the container becomes entirely depleted.
    @discardableResult @inlinable @inline(__always)
    func popBack() -> Element? {
        lock.writeLock()
        defer { lock.unlock() }
        guard let element = tail else { return nil }
        tail = element.prev
        if tail == nil { head = nil }
        tail?.next = nil
        element.prev = nil
        assert(count > 0)
        count -= 1
        return element
    }
}
