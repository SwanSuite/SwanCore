//
//  List.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-18.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation
import os

public protocol ListElement: AnyObject {
    associatedtype T
    var object: T? { get set }
    var next: Self? { get set }
    var prev: Self? { get set }
    init(_ object: T?)
}

public class List<Element: ListElement>: @unchecked Sendable {
    public init() {}

    public private(set) var head: Element?
    public private(set) var tail: Element?
    public private(set) var count: Int = 0

    deinit { clear() }

    private let lock = OSAllocatedUnfairLock()
}

// MARK: - Operators

infix operator +> // push
infix operator <+ // add
infix operator <<< // pop
infix operator >>> // pop tail
prefix operator ^ // pop prefix.
infix operator ++ // add

public extension List {
    static func ++ (list: List, object: Element.T) {
        list.add(Element(object))
    }

    static func +> (object: Element.T, list: List) {
        list.push(Element(object))
    }

    static func >>> (list: List, object: inout Element.T?) {
        object = list.popTail()?.object
    }

    static func <+ (list: List, object: Element.T) {
        list ++ object
    }

    static func <<< (object: inout Element.T?, list: List) {
        object = ^list
    }

    static prefix func ^ (list: List) -> Element.T? {
        list.pop()?.object
    }
}

// MARK: - Imaplementation

public extension List {
    func add(_ element: Element) {
        lock.lock()
        if head == nil {
            head = element
        }
        element.prev = tail
        tail?.next = element
        tail = element
        count += 1
        lock.unlock()
    }

    func push(_ element: Element) {
        lock.lock()
        if tail == nil {
            tail = element
        }
        element.next = head
        head?.prev = element
        head = element
        count += 1
        lock.unlock()
    }

    func pop() -> Element? {
        lock.lock()
        defer { lock.unlock() }
        guard let element = head else { return nil }
        head = element.next
        head?.prev = nil
        element.next = nil
        count -= 1
        return element
    }

    func popTail() -> Element? {
        lock.lock()
        defer { lock.unlock() }
        guard let element = tail else { return nil }
        tail = element.prev
        tail?.next = nil
        element.prev = nil
        count -= 1
        return element
    }

    func remove(_ element: Element) {
        lock.lock()
        defer { lock.unlock() }
        if let prev = element.prev {
            prev.next = element.next
        } else {
//            assert(element === root);
            head = element.next
        }
        if let next = element.next {
            next.prev = element.prev;
        } else {
//            assert(element == tail)
            tail = element.prev
        }
        count -= 1
    }

    private func first(where predicate: (Element) -> Bool) -> Element? {
        var cursor = head
        while cursor != nil {
            guard let current = cursor else { fatalError() }
            if current.object != nil {
                if predicate(current) {
                    return current
                }
            } else {
                remove(current)
            }
            cursor = current.next
        }
        return nil
    }

    func first(where predicate: (Element.T) -> Bool) -> Element.T? {
        first { (element: Element) -> Bool in
            guard let item = element.object else { fatalError() }
            return predicate(item)
        }?.object
    }

    func forEach(_ handler: (Element.T) -> Void) {
        _ = first { (element: Element) -> Bool in
            guard let item = element.object else { fatalError() }
            handler(item)
            return false
        }
    }

    func cleanup() {
        forEach { _ in }
    }
}

public final class RetainList<Item>: List<RetainList.Element<Item>>, @unchecked Sendable {
    public final class Element<I>: ListElement {
        public typealias T = I
        public var object: T?

        public var next: Element?
        public var prev: Element?

        required public init(_ object: T?) {
            self.object = object
        }
    }
}

public final class WeakList<Item: AnyObject>: List<WeakList.Element<Item>>, @unchecked Sendable {
    public final class Element<I: AnyObject>: ListElement {
        public typealias T = I
        weak public var object: T?

        public var next: Element?
        public var prev: Element?

        required public init(_ object: T?) {
            self.object = object
        }
    }
}

// MARK: - Private

private extension List {
    func clear() {
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
