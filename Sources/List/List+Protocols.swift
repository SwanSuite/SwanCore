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

/// Specifies the linear traversal orientation for data structure iteration routines.
public enum ListDirection {
    /// Iterates sequentially moving from `head` towards `next`.
    case forward
    /// Iterates sequentially moving from `tail` towards `prev`.
    case backward
}

/// Explicitly specifies the structural boundary target for modification or slicing.
public enum ModifyTarget {
    /// Targets the front-end (head boundary) axis of the collection.
    case front
    /// Targets the back-end (tail boundary) axis of the collection.
    case back
}

// ==========================================
// MARK: - List Metrics & Layout Hooks
// ==========================================

/// A layout contract specifying unique structural access to the head pointer anchor.
public protocol HasHead: AnyObject {
    associatedtype Element: ForwardConnection

    /// The root cursor node of the collection sequence.
    var head: Element? { get set }
}

/// A layout contract specifying unique structural access to the tail pointer anchor.
public protocol HasTail: AnyObject {
    associatedtype Element: BackwardConnection

    /// The terminating cursor node of the collection sequence.
    var tail: Element? { get set }
}

/// A layout contract specifying tracking metrics for structural elements capacity.
public protocol HasCount: AnyObject {
    /// The total unsigned number of structural node entries currently residing inside the container.
    var count: UInt { get set }
}

// ==========================================
// MARK: - Core Elements Specification
// ==========================================

/// A unified structural contract blueprint for a symmetric bi-directional list node topology.
public protocol ListElementProtocol: ObjectContainer, BidirectionalConnection {}

/// A structural contract blueprint for a linear, single-directional forward list node topology.
public protocol ForwardListElementProtocol: ObjectContainer, ForwardConnection {}

// ==========================================
// MARK: - ObjectContainer
// ==========================================

/// A strict design contract layout specifying a container that holds a non-optional sendable business object payload.
///
/// Unifies both strong and weak memory retention models via structural type aliasing at the implementation tier.
public protocol ObjectContainer: AnyObject {
    associatedtype T: Sendable

    /// The unique thread-safe payload item managed by the SwanCore storage engine.
    ///
    /// Can represent a standard strong type instance or an implicit `Optional` wrapping wrapper
    /// to seamlessly drive lazy zero-cost weak reference sweeps.
    var object: T { get set }

    /// Designated initializer enforcing explicit payload injection during structural node instantiation.
    init(_ object: T)
}

// ==========================================
// MARK: - Connections Topology Specification
// ==========================================

/// A topology contract specifying sequential forward iteration capability.
public protocol ForwardConnection: AnyObject {
    /// The next adjacent node pointer reference in the sequence chain.
    var next: Self? { get set }
}

/// A topology contract specifying sequential backward iteration capability.
public protocol BackwardConnection: AnyObject {
    /// The preceding adjacent node pointer reference in the sequence chain.
    var prev: Self? { get set }
}

/// A composite topology contract combining forward and backward capabilities into a symmetric bi-directional chain.
public protocol BidirectionalConnection: ForwardConnection, BackwardConnection {}

/// A streamlined framework alias representing a fully complete bi-directional link.
public typealias ListConnection = BidirectionalConnection
