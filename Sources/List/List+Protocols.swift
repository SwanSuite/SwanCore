//
//  List+Protocols.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-07.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

// ==========================================
// MARK: - Directioning & Targeting
// ==========================================

public enum ListDirection {
    case forward
    case backward
}

// ==========================================
// MARK: - List Metrics & Layout Hooks
// ==========================================

public protocol HasHead: AnyObject {
    associatedtype Element: ForwardConnection

    var head: Element? { get set }
}

public protocol HasTail: AnyObject {
    associatedtype Element: BackwardConnection

    var tail: Element? { get set }
}

public protocol HasCount: AnyObject {
    var count: Int { get set }
}

// ==========================================
// MARK: - Core Elements Specification
// ==========================================

public protocol ListElementProtocol: ObjectContainer, BidirectionalConnection {}

public protocol ForwardListElementProtocol: ObjectContainer, ForwardConnection {}

// ==========================================
// MARK: - ObjectContainer
// ==========================================

public protocol ObjectContainer: AnyObject {
    associatedtype T: Sendable

    var object: T { get set }

    init(_ object: T)
}

// ==========================================
// MARK: - Connections Topology Specification
// ==========================================

public protocol ForwardConnection: AnyObject {
    var next: Self? { get set }
}

public protocol BackwardConnection: AnyObject {
    var prev: Self? { get set }
}

public protocol BidirectionalConnection: ForwardConnection, BackwardConnection {}

public typealias ListConnection = BidirectionalConnection
