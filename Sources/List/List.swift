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

public final class ListElement<I>: ListElementProtocol {
    public typealias T = I

    public var object: T

    public var next: ListElement?
    public var prev: ListElement?

    required public init(_ object: T) {
        self.object = object
    }
}

public final class List<Item: Sendable, Lock: RWLocking>: AbstractList<ListElement<Item>, Lock>, @unchecked Sendable {}

extension List: FrontModifiable, BackModifiable, ListIterator {}

// ==========================================
// MARK: - WeakList Layout
// ==========================================

public final class WeakList<Item: AnyObject, Lock: RWLocking>: AbstractList<WeakListElement<Item>, Lock>, @unchecked Sendable {}

public final class WeakListElement<I: AnyObject & Sendable>: ListElementProtocol {
    public typealias T = Optional<I>

    public weak var object: T

    public var next: WeakListElement?
    public var prev: WeakListElement?

    required public init(_ object: T) {
        self.object = object
    }
}

extension WeakListElement: Emptiable {

    public var isEmpty: Bool { object == nil }
}

extension WeakList: FrontModifiable, BackModifiable, ListIterator, Maintainable {}

// ==========================================
// MARK: - AbstractList Base
// ==========================================

open class AbstractList<Element: ListElementProtocol, Lock: RWLocking>: @unchecked Sendable, ElementRemover, HasRWLock, HasCount {
    
    public init() {}

    public var head: Element?

    public var tail: Element?

    public var cursor: Element?

    public var count: Int = 0

    public let lock = Lock()

    deinit {
        cursor = head
        tail = nil
        head = nil
        while let next = cursor?.next {
            next.prev = nil
            cursor?.next = nil
            cursor = next
        }
    }
}
