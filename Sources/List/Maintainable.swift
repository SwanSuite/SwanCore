//
//  Maintainable.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-21.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

public protocol Maintainable {
    associatedtype Element: ListElementProtocol

    @inlinable @inline(__always)
    func maintainance(element: Element, buffer: UnsafeBuffer<Element>) -> Bool
}

public extension Maintainable where Element: Emptiable {

    @inlinable @inline(__always)
    func maintainance(element: Element, buffer: UnsafeBuffer<Element>) -> Bool {
        if element.isEmpty {
            UnsafeElement(element) +> buffer
            return false
        }
        return true
    }
}

public extension Maintainable where Self: HasRWLock & ElementRemover {
    func cleanup(buffer: UnsafeBuffer<Element>) {
        lock.writeLock()
        var cursor = buffer.head
        while let current = cursor {
            _remove(current.object)
            cursor = current.next
        }
        lock.unlock()
    }
}
