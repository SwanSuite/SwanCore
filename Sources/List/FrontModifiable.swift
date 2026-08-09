//
//  FrontModifiable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-08.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

// ==========================================
// MARK: - FrontModifiable Composition
// ==========================================

/// A unified capability composition combining front-end data insertion and extraction traits.
public typealias FrontModifiable = FrontAppendable & FrontRemovable


// ==========================================
// MARK: - FrontAppendable Specification
// ==========================================

/// A capability contract layout for collections supporting head-first (front) node insertion.
public protocol FrontAppendable: AnyObject, HasHead {
    associatedtype Element

    /// Prepends a fully initialized structural node to the head of the container.
    ///
    /// - Parameter element: The pre-allocated node instance to link.
    /// - Returns: A reference to the modified container `Self` to drive Fluent API pipelines.
    @discardableResult @inlinable @inline(__always)
    func pushFront(_ element: Element) -> Self
}

public extension FrontAppendable {

    /// An alias for prepending a node to the front of the collection.
    @discardableResult @inlinable @inline(__always)
    func push(_ object: Element) -> Self { pushFront(object) }

    /// Pushes a structural node onto the head of the collection via right-associative syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static func +> (element: Element, list: Self) -> Self { list.pushFront(element) }
}

public extension FrontAppendable where Element: ObjectContainer {

    /// Automatically encapsulates a raw sendable business object into a new node container and prepends it.
    ///
    /// - Parameter object: The non-optional thread-safe business payload item.
    @discardableResult @inlinable @inline(__always)
    func pushFront(_ object: Element.T) -> Self { pushFront(Element(object)) }

    /// An alias for wrapping and prepending a raw business object.
    @discardableResult @inlinable @inline(__always)
    func push(_ object: Element.T) -> Self { pushFront(object) }

    /// Wraps a raw business object and pushes it onto the collection via right-associative syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static func +> (object: Element.T, list: Self) -> Self { list.pushFront(object) }
}

public extension FrontAppendable where Self: HasRWLock & HasTail & HasCount, Element: BidirectionalConnection {

    /// Default blueprint algorithm executing O(1) synchronized bi-directional head insertion.
    ///
    /// Statically bound by the compiler when the container provides full structural metrics and locks.
    @discardableResult @inlinable @inline(__always)
    func pushFront(_ element: Element) -> Self {
        lock.writeLock()
        if tail == nil {
            tail = element
        }
        element.next = head
        head?.prev = element
        head = element
        count += 1
        lock.unlock()
        return self
    }
}


// ==========================================
// MARK: - FrontRemovable Specification
// ==========================================

/// A capability contract layout for collections supporting head-first (front) node extraction.
public protocol FrontRemovable: AnyObject, HasHead where Element: ForwardConnection {

    /// Extracts and unlinks the current head node from the collection topology.
    ///
    /// - Returns: The unlinked node wrapper instance, or `nil` if the container is empty.
    @discardableResult @inlinable @inline(__always)
    func popFront() -> Element?
}

public extension FrontRemovable {

    /// An alias for extracting the first node from the collection.
    @discardableResult @inlinable @inline(__always)
    func pop() -> Element? { popFront() }

    /// Unlinks the head node and returns it directy via prefix syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static prefix func ^ (list: Self) -> Element? { list.popFront() }
}

public extension FrontRemovable where Element: ObjectContainer {

    /// Extracts the head node and unwraps its inner business object payload.
    ///
    /// - Returns: The sendable business object payload item, or `nil` if the container is empty.
    @discardableResult @inlinable @inline(__always)
    func popFront() -> Element.T? { popFront()?.object }

    /// An alias for extracting and unwrapping the head node payload.
    @discardableResult @inlinable @inline(__always)
    func pop() -> Element.T? { popFront() }

    /// Unlinks the head node and unwraps its business payload via prefix syntax sugar.
    @discardableResult @inlinable @inline(__always)
    static prefix func ^ (list: Self) -> Element.T? { list.popFront() }
}

public extension FrontRemovable where Self: HasRWLock & HasTail & HasCount, Element: BidirectionalConnection {

    /// Default blueprint algorithm executing O(1) synchronized bi-directional head extraction.
    ///
    /// Safely breaks adjacent node pointer linkages under execution protection to block memory leak vectors.
    @discardableResult @inlinable @inline(__always)
    func popFront() -> Element? {
        lock.writeLock()
        defer { lock.unlock() }
        guard let element = head else { return nil }
        head = element.next
        if head == nil { tail = nil }
        head?.prev = nil
        element.next = nil
        assert(count > 0)
        count -= 1
        return element
    }
}
