//
//  ElementRemover.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-09.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

public protocol ElementRemover: AnyObject, HasHead, HasTail where Element: BackwardConnection {

    @inlinable @inline(__always)
    func remove(_ element: Element)
}

public extension ElementRemover where Self: HasRWLock & HasCount {

    @inlinable @inline(__always)
    func remove(_ element: Element) {
        lock.writeLock()
        _remove(element)
        count -= 1
        lock.unlock()
    }

    @inlinable @inline(__always)
    func remove(_ elements: [Element]) {
        lock.writeLock()
        for element in elements { _remove(element) }
        count -= elements.count
        lock.unlock()
    }
}

extension ElementRemover {
    @inlinable @inline(__always)
    func _remove(_ element: Element) {
        if let prev = element.prev {
            prev.next = element.next
        } else {
            assert(element === head)
            head = element.next
        }

        if let next = element.next {
            next.prev = element.prev
        } else {
            assert(element === tail)
            tail = element.prev
        }

        element.next = nil
        element.prev = nil
    }
}
