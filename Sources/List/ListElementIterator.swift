//
//  ListElementIterator.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-09.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

public protocol ListElementIterator {
    associatedtype Element

    @discardableResult @inlinable @inline(__always)
    func forEachElement(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element) throws -> Bool
    ) rethrows -> Element?
}

public extension ListElementIterator {

    @inlinable @inline(__always)
    func forEachElement(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        handler: (Element) throws -> Void
    ) rethrows {
        try forEachElement(start: start, next: next, interruptHandler: { element in
            try handler(element)
            return false
        })
    }
}

// MARK: - implementation

public extension ListElementIterator where Self: HasRWLock {

    @discardableResult @inlinable @inline(__always)
    func forEachElement(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element) throws -> Bool
    ) rethrows -> Element? {
        lock.readLock()
        var cursor = self[keyPath: start]
        while let current = cursor {
            cursor = current[keyPath: next]
            if try interruptHandler(current) {
                return current
            }
        }
        lock.unlock()
        return nil
    }
}

public extension ListElementIterator where Self: Sendable & HasRWLock & ElementRemover & Maintainable, Element: Emptiable {

    @discardableResult @inlinable @inline(__always)
    func forEachElement(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element) throws -> Bool
    ) rethrows -> Element? {
        lock.readLock()
        let buffer = UnsafeBuffer<Element>()
        var cursor = self[keyPath: start]
        while let current = cursor {
            let next = current[keyPath: next]
            guard maintainance(element: current, buffer: buffer) else {
                cursor = next
                continue
            }
            if try interruptHandler(current) {
                return current
            }
            cursor = next
        }
        lock.unlock()
        Task.detached { [self, buffer] in cleanup(buffer: buffer) }
        return nil
    }
}

// MARK: - Specialized Topology Anchors

public extension ListElementIterator where Self: HasHead {

    @discardableResult @inlinable @inline(__always)
    func forwardElementIterator(interruptHandler: (Element) throws -> Bool) rethrows -> Element? {
        try forEachElement(start: \.head, next: \.next, interruptHandler: interruptHandler)
    }

    @inlinable @inline(__always)
    func forwardElementIterator(handler: (Element) throws -> Void) rethrows {
        try forEachElement(start: \.head, next: \.next, handler: handler)
    }
}

public extension ListElementIterator where Self: HasTail, Element: BackwardConnection {

    @discardableResult @inlinable @inline(__always)
    func backwardElementIterator(interruptHandler: (Element) throws -> Bool) rethrows -> Element? {
        try forEachElement(start: \.tail, next: \.prev, interruptHandler: interruptHandler)
    }

    @inlinable @inline(__always)
    func backwardElementIterator(handler: (Element) throws -> Void) rethrows {
        try forEachElement(start: \.tail, next: \.prev, handler: handler)
    }
}

// MARK: - Symmetric Composite Interface

public extension ListElementIterator where Self: HasHead & HasTail, Element: BackwardConnection {

    @inlinable @inline(__always)
    func forEachElement(_ direction: ListDirection = .forward, handler: (Element) throws -> Void) rethrows {
        switch direction {
        case .forward: try forwardElementIterator(handler: handler)
        case .backward: try backwardElementIterator(handler: handler)
        }
    }

    @inlinable @inline(__always)
    func firstElement(_ direction: ListDirection = .forward, where predicate: (Element) throws -> Bool) rethrows -> Element? {
        switch direction {
        case .forward: try forwardElementIterator(interruptHandler: predicate)
        case .backward: try backwardElementIterator(interruptHandler: predicate)
        }
    }
}
