//
//  ListIterator.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-09.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

/// A high-performance capability contract layout for executing thread-safe linear iterations.
///
/// Unifies forward and backward traversals under a single, highly optimized KeyPath engine,
/// natively integrating inline maintenance routines like lazy data purging.
public protocol ListIterator {
    associatedtype Element

    /// Core loop executing a synchronized linear scan with strict context lock dropping boundaries.
    @discardableResult @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element) -> Bool
    ) -> Element?

    /// Polymorphic architectural hook driving automated element state verification during traversal sweeps.
    ///
    /// - Returns: `true` if the node is valid and can be processed; `false` if it was discarded.
    @inlinable @inline(__always)
    func maintainance(element: Element) -> Bool
}

public extension ListIterator {

    /// Default fallback implementation treating all evaluated nodes as structurally valid.
    @inlinable @inline(__always)
    func maintainance(element: Element) -> Bool { true }
}

public extension ListIterator where Self: HasRWLock {

    /// Default blueprint engine driving the synchronized KeyPath traversal pattern.
    ///
    /// The `readLock` is safely dropped prior to invocation of `maintainance` and user closures,
    /// ensuring zero lock contention and permitting cross-thread access during iteration steps.
    @discardableResult @inlinable @inline(__always)
    func forEach(
        start: KeyPath<Self, Element?>,
        next: KeyPath<Element, Element?>,
        interruptHandler: (Element) -> Bool
    ) -> Element? {
        lock.readLock()

        var cursor = self[keyPath: start]

        while cursor != nil {
            guard let current = cursor else { fatalError() }
            lock.unlock()

            // Execute maintenance checks and user code outside the read lock path
            if maintainance(element: current) && interruptHandler(current) {
                return current
            }

            lock.readLock()
            cursor = current[keyPath: next]
        }
        lock.unlock()
        return nil
    }
}

public extension ListIterator where Self: ElementRemover, Element: Emptyable {

    /// Specialized memory-management layer executing inline, zero-cost lazy purging for empty nodes.
    ///
    /// Automatically detects zombie entries (e.g., collapsed weak references) and dispatches them
    /// straight to `remove(_:)`, which securely shields modifications under a strict `writeLock()`.
    @inlinable @inline(__always)
    func maintainance(element: Element) -> Bool {
        if element.isEmpty {
            remove(element)
            return false
        }
        return true
    }
}

// MARK: - Specialized Topology Anchors

extension HasHead where Self: ListIterator {

    /// Initiates a forward linear iteration pass starting directly from the `head` pointer.
    ///
    /// The compiler natively knows that Element conforms to ForwardConnection due to HasHead protocols constraints.
    @discardableResult @inlinable @inline(__always)
    func forwardIterator(interruptHandler: (Element) -> Bool) -> Element? {
        forEach(start: \.head, next: \.next, interruptHandler: interruptHandler)
    }
}

extension HasTail where Self: ListIterator {

    /// Initiates a backward linear iteration pass starting directly from the `tail` pointer.
    ///
    /// The compiler natively knows that Element conforms to BackwardConnection due to HasTail protocols constraints.
    @discardableResult @inlinable @inline(__always)
    func backwardIterator(interruptHandler: (Element) -> Bool) -> Element? {
        forEach(start: \.tail, next: \.prev, interruptHandler: interruptHandler)
    }
}

// MARK: - Symmetric Composite Interface

public extension HasTail where Self: ListIterator & HasHead {

    /// Performs a fully unified directional iteration sweep across the data sequence structure.
    @discardableResult @inlinable @inline(__always)
    func forEach(_ direction: ListDirection = .forward, interruptHandler: (Element) -> Bool) -> Element? {
        switch direction {
        case .forward:
            return forEach(start: \.head, next: \.next, interruptHandler: interruptHandler)
        case .backward:
            return forEach(start: \.tail, next: \.prev, interruptHandler: interruptHandler)
        }
    }

    /// Scans the collection sequentially to fetch the first structural node matching a specific predicate requirement.
    @inlinable @inline(__always)
    func first(_ direction: ListDirection = .forward, where predicate: (Element) -> Bool) -> Element? {
        forEach(direction, interruptHandler: predicate)
    }
}
