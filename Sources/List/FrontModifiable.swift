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

public typealias FrontModifiable = FrontAppendable & FrontRemovable

// ==========================================
// MARK: - FrontAppendable Specification
// ==========================================

public protocol FrontAppendable: AnyObject, HasHead {
    associatedtype Element

    @discardableResult @inlinable @inline(__always)
    func pushFront(_ element: Element) -> Self
}

public extension FrontAppendable {

    @discardableResult @inlinable @inline(__always)
    func push(_ object: Element) -> Self { pushFront(object) }

    @discardableResult @inlinable @inline(__always)
    static func +> (element: Element, list: Self) -> Self { list.pushFront(element) }
}

public extension FrontAppendable where Element: ObjectContainer {

    @discardableResult @inlinable @inline(__always)
    func pushFront(_ object: Element.T) -> Self { pushFront(Element(object)) }

    @discardableResult @inlinable @inline(__always)
    func push(_ object: Element.T) -> Self { pushFront(object) }

    @discardableResult @inlinable @inline(__always)
    static func +> (object: Element.T, list: Self) -> Self { list.pushFront(object) }
}

public extension FrontAppendable where Self: HasRWLock & HasTail & HasCount {

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

public extension FrontAppendable where Self: HasRWLock & HasCount {

    @discardableResult @inlinable @inline(__always)
    func pushFront(_ element: Element) -> Self {
        lock.writeLock()
        element.next = head
        head = element
        count += 1
        lock.unlock()
        return self
    }
}

public extension FrontAppendable where Self: HasCount {

    @discardableResult @inlinable @inline(__always)
    func pushFront(_ element: Element) -> Self {
        element.next = head
        head = element
        count += 1
        return self
    }
}

public extension FrontAppendable {

    @discardableResult @inlinable @inline(__always)
    func pushFront(_ element: Element) -> Self {
        element.next = head
        head = element
        return self
    }
}

// ==========================================
// MARK: - FrontRemovable Specification
// ==========================================

public protocol FrontRemovable: AnyObject, HasHead where Element: ForwardConnection {

    @discardableResult @inlinable @inline(__always)
    func popFront() -> Element?
}

public extension FrontRemovable {

    @discardableResult @inlinable @inline(__always)
    func pop() -> Element? { popFront() }

    @discardableResult @inlinable @inline(__always)
    static prefix func ^ (list: Self) -> Element? { list.popFront() }
}

public extension FrontRemovable where Element: ObjectContainer {

    @discardableResult @inlinable @inline(__always)
    func popFront() -> Element.T? { popFront()?.object }

    @discardableResult @inlinable @inline(__always)
    func pop() -> Element.T? { popFront() }

    @discardableResult @inlinable @inline(__always)
    static prefix func ^ (list: Self) -> Element.T? { list.popFront() }
}

public extension FrontRemovable where Self: HasRWLock & HasTail & HasCount, Element: BidirectionalConnection {

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
