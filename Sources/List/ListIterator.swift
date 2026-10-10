//
//  ListIterator.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-09.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

public protocol ListIterator: ListElementIterator where Element: ObjectContainer {

    @discardableResult @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element.T) throws -> Bool
    ) rethrows -> Element.T?

    @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        handler: (Element.T) throws -> Void
    ) rethrows
}

public extension ListIterator {

    @discardableResult @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element.T) throws -> Bool
    ) rethrows -> Element.T? {
        try forEachElement(start: start, next: next, interruptHandler: { element in
            try interruptHandler(element.object)
        })?.object
    }

    @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        handler: (Element.T) throws -> Void
    ) rethrows {
        try forEachElement(start: start, next: next, handler: { element in
            try handler(element.object)
        })
    }

}

public extension ListIterator where Self: HasRWLock {
    @discardableResult @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element.T) throws -> Bool
    ) rethrows -> Element.T? {
        try forEachElement(start: start, next: next, interruptHandler: { element in
            try interruptHandler(element.object)
        })?.object
    }

    @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        handler: (Element.T) throws -> Void
    ) rethrows {
        try forEachElement(start: start, next: next, interruptHandler: { element in
            try handler(element.object)
            return false
        })
    }
}

public extension ListIterator where Self: HasHead {

    @discardableResult @inlinable @inline(__always)
    func forwardIterator(interruptHandler: (Element.T) throws -> Bool) rethrows -> Element.T? {
        try forEach(start: \.head, next: \.next, interruptHandler: interruptHandler)
    }

    @inlinable @inline(__always)
    func forwardIterator(handler: (Element.T) throws -> Void) rethrows {
        try forEach(start: \.head, next: \.next, handler: handler)
    }
}

public extension ListIterator where Self: HasTail, Element: BackwardConnection {

    @discardableResult @inlinable @inline(__always)
    func backwardIterator(interruptHandler: (Element.T) throws -> Bool) rethrows -> Element.T? {
        try forEach(start: \.tail, next: \.prev, interruptHandler: interruptHandler)
    }

    @inlinable @inline(__always)
    func backwardIterator(handler: (Element.T) throws -> Void) rethrows {
        try forEach(start: \.tail, next: \.prev, handler: handler)
    }
}

// MARK: - Symmetric Composite Interface

public extension ListIterator where Self: HasHead & HasTail, Element: BackwardConnection {

    @inlinable @inline(__always)
    func forEach(_ direction: ListDirection = .forward, handler: (Element.T) throws -> Void) rethrows {
        switch direction {
        case .forward: try forwardIterator(handler: handler)
        case .backward: try backwardIterator(handler: handler)
        }
    }

    @inlinable @inline(__always)
    func first(_ direction: ListDirection = .forward, where predicate: (Element.T) throws -> Bool) rethrows -> Element.T? {
        switch direction {
        case .forward: try forwardIterator(interruptHandler: predicate)
        case .backward: try backwardIterator(interruptHandler: predicate)
        }
    }
}
