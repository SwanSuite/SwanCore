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

public typealias BackModifiable = BackAppendable & BackRemovable

// ==========================================
// MARK: - BackAppendable Specification
// ==========================================

public protocol BackAppendable: AnyObject, HasTail {
    associatedtype Element

    @discardableResult @inlinable @inline(__always)
    func pushBack(_ element: Element) -> Self
}

public extension BackAppendable {

    @discardableResult @inlinable @inline(__always)
    func pushTail(_ element: Element) -> Self { pushBack(element) }

    @discardableResult @inlinable @inline(__always)
    func add(_ element: Element) -> Self { pushBack(element) }

    @discardableResult @inlinable @inline(__always)
    func append(_ element: Element) -> Self { pushBack(element) }

    @discardableResult @inlinable @inline(__always)
    static func <+ (list: Self, element: Element) -> Self { list.pushBack(element) }

    @discardableResult @inlinable @inline(__always)
    static func += (list: Self, element: Element) -> Self { list.pushBack(element) }
}

public extension BackAppendable where Element: ObjectContainer {

    @discardableResult @inlinable @inline(__always)
    func pushBack(_ object: Element.T) -> Self { pushBack(Element(object)) }

    @discardableResult @inlinable @inline(__always)
    func pushTail(_ object: Element.T) -> Self { pushBack(object) }

    @discardableResult @inlinable @inline(__always)
    static func <+ (list: Self, object: Element.T) -> Self { list.pushBack(object) }

    @discardableResult @inlinable @inline(__always)
    static func += (list: Self, object: Element.T) -> Self { list.pushBack(object) }
}

public extension BackAppendable where Self: HasRWLock & HasHead & HasCount {

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

public extension BackAppendable where Self: HasRWLock & HasCount {

    @discardableResult @inlinable @inline(__always)
    func pushBack(_ element: Element) -> Self {
        lock.writeLock()
        element.prev = tail
        tail = element
        count += 1
        lock.unlock()
        return self
    }
}

public extension BackAppendable where Self: HasCount {

    @discardableResult @inlinable @inline(__always)
    func pushBack(_ element: Element) -> Self {
        element.prev = tail
        tail = element
        count += 1
        return self
    }
}

public extension BackAppendable {

    @discardableResult @inlinable @inline(__always)
    func pushBack(_ element: Element) -> Self {
        element.prev = tail
        tail = element
        return self
    }
}

// ==========================================
// MARK: - BackRemovable Specification
// ==========================================

public protocol BackRemovable: AnyObject, HasTail where Element: ForwardConnection {

    @discardableResult @inlinable @inline(__always)
    func popBack() -> Element?
}

public extension BackRemovable {

    @discardableResult @inlinable @inline(__always)
    func popTail() -> Element? { popBack() }

    @discardableResult @inlinable @inline(__always)
    static postfix func ^ (list: Self) -> Element? { list.popBack() }
}

public extension BackRemovable where Element: ObjectContainer {

    @discardableResult @inlinable @inline(__always)
    func popBack() -> Element.T? { popBack()?.object }

    @discardableResult @inlinable @inline(__always)
    func popTail() -> Element.T? { popBack() }

    @discardableResult @inlinable @inline(__always)
    static postfix func ^ (list: Self) -> Element.T? { list.popBack() }
}

public extension BackRemovable where Self: HasRWLock & HasHead & HasCount, Element: BidirectionalConnection {

    @discardableResult @inlinable @inline(__always)
    func popBack() -> Element? {
        guard let element = tail else { return nil }
        lock.writeLock()
        defer { lock.unlock() }
        tail = element.prev
        if tail == nil { head = nil }
        tail?.next = nil
        element.prev = nil
        assert(count > 0)
        count -= 1
        return element
    }
}
