//
//  List.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-18.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

// ==========================================
// MARK: - RetainList Layout
// ==========================================

/// A concrete, strongly retained node structure fulfilling the bi-directional topology contract.
public final class ListElement<I>: ListElementProtocol {
    public typealias T = I

    /// The guaranteed, non-optional business object payload instance.
    public var object: T

    public var next: ListElement?
    public var prev: ListElement?

    /// Designated node initializer enforcing non-optional payload injection.
    required public init(_ object: T) {
        self.object = object
    }
}

/// A thread-safe, double-linked list managing nodes with strong reference retention.
///
/// Modeled as a direct analog to C++ `std::list`. It guarantees that business objects
/// remain pinned in memory as long as their containing nodes reside inside the sequence structure.
public final class List<Item: Sendable, Lock: RWLocking>: AbstractList<ListElement<Item>, Lock>, @unchecked Sendable {}

extension List: FrontModifiable, BackModifiable, ListIterator {}


// ==========================================
// MARK: - WeakList Layout
// ==========================================

/// A thread-safe, double-linked list managing nodes with weak reference retention.
///
/// Designed to track transient lifecycle resources safely. It encapsulates optional payloads
/// inside an automated type-aliased layout contract, triggering O(1) inline lazy cleanup
/// during linear traversal sweeps whenever tracked objects undergo deallocation outside the framework.
public final class WeakList<Item: AnyObject, Lock: RWLocking>: AbstractList<WeakListElement<Item>, Lock>, @unchecked Sendable {}

/// A concrete, weakly retained node structure tracking transient system memory resources.
public final class WeakListElement<I: AnyObject & Sendable>: ListElementProtocol {
    public typealias T = Optional<I>

    /// The weakly retained business object payload bridge instance.
    public weak var object: T

    public var next: WeakListElement?
    public var prev: WeakListElement?

    /// Designated node initializer supporting implicit optional reference captures.
    required public init(_ object: T) {
        self.object = object
    }
}

extension WeakListElement: Emptiable {

    /// Evaluates to `true` if the referenced business object has been reclaimed by the runtime ARC subsystem.
    public var isEmpty: Bool { object == nil }
}

extension WeakList: FrontModifiable, BackModifiable, ListIterator {}


// ==========================================
// MARK: - AbstractList Base
// ==========================================

/// A polymorphic blueprint specification driving foundational double-linked list layout engines.
///
/// Abstracts common state indicators like pointer anchors and capacities, delegating behavioral
/// data injection, extraction, and memory model strategies to target type extensions.
open class AbstractList<Element: ListElementProtocol, Lock: RWLocking>: @unchecked Sendable, ElementRemover, HasRWLock, HasCount {
    public typealias Direction = ListDirection

    /// Initializes a generic abstract list sequence protected by a consumed synchronization primitive.
    public init() {}

    /// The root pointer anchor node of the double-linked sequence chain.
    public var head: Element?

    /// The terminating pointer anchor node of the double-linked sequence chain.
    public var tail: Element?

    /// A generic auxiliary movable tracking cursor for advanced structural step mutations.
    public var cursor: Element?

    /// The total unsigned number of nodes currently linked into the sequence topology.
    public var count: UInt = 0

    /// The shared-exclusive synchronization block managing internal thread isolation.
    public let lock = Lock()

    deinit {
        var cursor = head
        tail = nil
        head = nil
        count = 0
        while let next = cursor?.next {
            next.prev = nil
            cursor?.next = nil
            cursor = next
        }
    }
}
