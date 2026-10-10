//
//  List+Sugar.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-08.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

// ==========================================
// MARK: - Precedence Groups & Operators
// ==========================================

precedencegroup TailAppendPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator <+: TailAppendPrecedence

precedencegroup HeadPushPrecedence {
    associativity: right
    higherThan: AssignmentPrecedence
}

infix operator +>: HeadPushPrecedence

postfix operator ^
prefix operator ^

public enum ModifyTarget {
    case front
    case back
}

// ==========================================
// MARK: - Dynamic Targeting Extensions
// ==========================================

public extension FrontAppendable where Self: BackAppendable {

    @discardableResult @inlinable @inline(__always)
    func push(_ element: Element, target: ModifyTarget = .front) -> Self {
        switch target {
        case .front: pushFront(element)
        case .back: pushBack(element)
        }
    }
}

public extension FrontAppendable where Self: BackAppendable, Element: ObjectContainer {

    @discardableResult @inlinable @inline(__always)
    func push(_ object: Element.T, target: ModifyTarget = .front) -> Self {
        switch target {
        case .front: pushFront(object)
        case .back: pushBack(object)
        }
    }
}

public extension FrontRemovable where Self: BackRemovable {

    @discardableResult @inlinable @inline(__always)
    func pop(_ target: ModifyTarget = .front) -> Element? {
        switch target {
        case .front: popFront()
        case .back: popBack()
        }
    }
}

public extension FrontRemovable where Self: BackRemovable, Element: ObjectContainer {

    @discardableResult @inlinable @inline(__always)
    func pop(_ target: ModifyTarget = .front) -> Element.T? {
        switch target {
        case .front: popFront()
        case .back: popBack()
        }
    }
}
