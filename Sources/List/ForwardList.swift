//
//  ForwardList.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-20.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

public final class ForwardListElement<I>: ForwardListElementProtocol {
    public typealias T = I

    public var object: T

    public var next: ForwardListElement?

    required public init(_ object: T) {
        self.object = object
    }
}

public final class ForwardList<I: Sendable, Lock: RWLocking>: HasRWLock, HasCount, FrontAppendable {
    public typealias Element = ForwardListElement<I>

    public init() {}

    public var head: ForwardListElement<I>?

    public var cursor: ForwardListElement<I>?

    public var count: Int = 0

    public let lock = Lock()

    deinit {
        while let next = head?.next {
            head?.next = nil
            head = next
        }
    }
}

extension ForwardList: ListIterator {}

public final class UnsafeElement<T>: ForwardConnection {

    public var object: T

    public var next: UnsafeElement<T>?

    required public init(_ object: T) {
        self.object = object
    }
}

public final class UnsafeBuffer<I>: @unchecked Sendable, FrontAppendable {

    public typealias Element = UnsafeElement<I>

    public init() {}

    public var head: Element?

    deinit {
        while let next = head?.next {
            head?.next = nil
            head = next
        }
    }
}
