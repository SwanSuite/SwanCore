//
//  ListTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-18.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Mock Test Entity

final class A: Sendable {
    let id = UUID()
}

extension A: Equatable {
    static func == (lhs: A, rhs: A) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Functional Test Suite

@Suite("WeakList Storage Lifecycle Validation Suite")
struct ListTests {

    private var list: WeakList<A>
    private var array: [A]?
    private let retain: [A]

    /// Modern replacement for XCTest 'setUp()'.
    /// State is instantiated fresh for each individual test execution.
    init() {
        self.list = WeakList()
        let a2 = A()
        let a3 = A()

        self.array = [A(), A(), a2, a3, A(), A(), A(), A()]
        self.retain = [a2, a3]
    }

    @Test("WeakList: Verification of dynamic weak reference autoreleasing and collection sweeping")
    mutating func testAutoreleasing() throws {
        // Unwrapping optional array securely for local test scope context
        var localArray = try #require(array)

        autoreleasepool {
            var count = 0
            for object in localArray {
                count += 1
                list <+ object
                #expect(list.count == count)
            }
            #expect(list.count == localArray.count)

            // Validate that all streaming elements exist inside the baseline source matrix
            list.forEach { #expect(localArray.contains($0)) }

            // Explicitly release un-retained structural elements inside the memory pool
            localArray.removeAll()
            array = nil
        }

        // Execute manual sweep or iterate to verify only strongly retained objects survive
        var strictlyCount = 0
        list.forEach { _ in strictlyCount += 1 }

        #expect(strictlyCount == retain.count)
        #expect(strictlyCount == list.count)

        var index = 0
        list.forEach { element in
            #expect(retain[index] == element)
            index += 1
        }
    }
}

// MARK: - Performance Test Suite

@Suite("List Performance Execution Suite")
struct ListPerformanceTests {

    @Test("RetainList: Execution benchmark profile for intensive structural node allocation")
    func testPerformance() {
        let list = RetainList<Int>()
        let clock = ContinuousClock()

        // Modern programmatic implementation replacing XCTest 'self.measure' block
        let duration = clock.measure {
            for i in 0...500_000 {
                list <+ i
            }
            // В твоей реализации 0.1.0 метод clear() вызывается автоматически в deinit,
            // но мы можем проверить явное обнуление графа через пошаговый pop, если необходимо.
        }

        // SLA Verification: Ensure half a million nodes append in under 0.5 seconds
        print("duration: \(duration)")
        #expect(duration < .seconds(0.5))
    }
}
