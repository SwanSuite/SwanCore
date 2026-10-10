//
//  ListPerformanceTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Testing
import Foundation
import os
@testable import SwanCore

extension Tag {
    @Tag static var performance: Self
}

// ==========================================
// MARK: - List Performance Execution Suite
// ==========================================

@Suite("Performance Isolation Wrapper", .serialized, .tags(.performance))
struct AllPerformanceTests {

    // ==========================================
    // MARK: - List Sequential Write Benchmarks
    // ==========================================

    @Suite("List Sequential Write Performance Suite", .serialized, .tags(.performance))
    struct ListSequentialWritePerformanceTests {

        @Test("List + VoidLock: Zero-overhead baseline benchmark profile for single-threaded mutation", .tags(.performance))
        func testPerformanceVoid() {
            let list = List<Int, VoidLock>()
            let clock = ContinuousClock()

            let duration = clock.measure {
                for i in 0...500_000 { list <+ i }
            }

            print("VoidRWLock Append Duration: \(duration)")
            #expect(duration < .seconds(0.3))
        }

        @Test("List + OSAllocatedUnfairLock: Native OS kernel lock baseline performance profiling", .tags(.performance))
        func testPerformanceOSUnfair() {
            let list = List<Int, OSAllocatedUnfairLock>()
            let clock = ContinuousClock()

            let duration = clock.measure {
                for i in 0...500_000 { list <+ i }
            }

            print("OSAllocatedUnfairLock Append Duration: \(duration)")
            #expect(duration < .seconds(0.3))
        }

        @Test("List + RWLock: Strict cross-platform mutex performance layout profile", .tags(.performance))
        func testPerformanceRWLock() {
            let list = List<Int, RWLock>()
            let clock = ContinuousClock()

            let duration = clock.measure {
                for i in 0...500_000 { list <+ i }
            }

            print("PosixRWLock Append Duration: \(duration)")
            #expect(duration < .seconds(0.3))
        }
    }


    // ==============================================
    // MARK: - List Concurrent Read Performance Suite
    // ==============================================

    @Suite("List Concurrent Read Performance Suite", .serialized, .tags(.performance))
    struct ListConcurrentReadPerformanceTests {

        @Test("List + VoidLock: Baseline execution profile for thread-free concurrent simulation", .tags(.performance))
        func testConcurrentReadVoid() async throws {
            let list = List<Int, VoidLock>()
            let duration = try await executeConcurrentReadBenchmark(for: list)
            #expect(duration < .seconds(1.0))
        }

        @Test("List + OSAllocatedUnfairLock: Concurrent read benchmark profile under native kernel lock", .tags(.performance))
        func testConcurrentReadOSUnfair() async throws {
            let list = List<Int, OSAllocatedUnfairLock>()
            let duration = try await executeConcurrentReadBenchmark(for: list)
            #expect(duration < .seconds(2.0))
        }

        @Test("List + RWLock: Massively parallel read scaling benchmark profile", .tags(.performance))
        func testConcurrentReadRWLock() async throws {
            let list = List<Int, RWLock>()
            let duration = try await executeConcurrentReadBenchmark(for: list)
            #expect(duration < .seconds(4.0))
        }

        // ==========================================
        // MARK: - Private Benchmark Core Runner
        // ==========================================

        private func executeConcurrentReadBenchmark<L: RWLocking>(
            for list: List<Int, L>,
            threads: UInt = 8,
            iterationsPerThread: UInt = 4
        ) async throws -> Duration {
            for i in 0...100_000 { list <+ i }

            let clock = ContinuousClock()

            let duration = await clock.measure {
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<threads {
                        group.addTask {
                            for _ in 0..<iterationsPerThread {
                                list.forEach { _ in }
                            }
                        }
                    }
                    await group.waitForAll()
                }
            }

            print("\(String(describing: L.self)): Concurrent Read Duration (100_000 records, \(iterationsPerThread) iterations, \(threads) threads): \(duration)")
            return duration
        }
    }


    // ==============================================
    // MARK: - List Concurrent Write Performance Suite
    // ==============================================

    @Suite("List Concurrent Write Performance Suite", .serialized, .tags(.performance))
    struct ListConcurrentWritePerformanceTests {

        @Test("List + OSAllocatedUnfairLock: Heavy concurrent append operations under native kernel lock", .tags(.performance))
        func testConcurrentWriteOSUnfair() async throws {
            let list = List<Int, OSAllocatedUnfairLock>()
            let duration = try await executeConcurrentWriteBenchmark(for: list)
            #expect(duration < .seconds(0.3))
        }

        @Test("List + RWLock: Heavy concurrent append operations under POSIX write-exclusive mutex", .tags(.performance))
        func testConcurrentWriteRWLock() async throws {
            let list = List<Int, RWLock>()
            let duration = try await executeConcurrentWriteBenchmark(for: list)
            #expect(duration < .seconds(0.8))
        }

        // ==========================================
        // MARK: - Private Benchmark Core Runner
        // ==========================================

        private func executeConcurrentWriteBenchmark<L: RWLocking>(
            for list: List<Int, L>,
            threads: UInt = 4,
            appendsPerThread: UInt = 50_000
        ) async throws -> Duration {
            let clock = ContinuousClock()

            let duration = await clock.measure {
                await withTaskGroup(of: Void.self) { group in
                    for threadIndex in 0..<threads {
                        group.addTask {
                            let baseOffset = Int(threadIndex * appendsPerThread)
                            for i in 0..<appendsPerThread {
                                list <+ (baseOffset + Int(i))
                            }
                        }
                    }
                    await group.waitForAll()
                }
            }

            print("\(String(describing: L.self)): Concurrent Write Duration (\(threads * appendsPerThread) total appends, \(threads) parallel workers): \(duration)")
            return duration
        }
    }


    // ==============================================
    // MARK: - List Mixed Read-Write Performance Suite
    // ==============================================

    @Suite("List Mixed Read-Write Performance Suite", .serialized, .tags(.performance))
    struct ListMixedReadWritePerformanceTests {

        @Test("List + OSAllocatedUnfairLock: Mixed read-write pipeline contention layout under native lock", .tags(.performance))
        func testMixedReadWriteOSUnfair() async throws {
            let list = List<Int, OSAllocatedUnfairLock>()
            let duration = try await executeMixedReadWriteBenchmark(for: list)
            #expect(duration < .seconds(0.8))
        }

        @Test("List + RWLock: Mixed read-write pipeline layout utilizing shared-reader advantages", .tags(.performance))
        func testMixedReadWriteRWLock() async throws {
            let list = List<Int, RWLock>()
            let duration = try await executeMixedReadWriteBenchmark(for: list)
            #expect(duration < .seconds(2.0))
        }

        // ==========================================
        // MARK: - Private Benchmark Core Runner
        // ==========================================

        private func executeMixedReadWriteBenchmark<L: RWLocking>(
            for list: List<Int, L>,
            readerThreads: UInt = 6,
            writerThreads: UInt = 2,
            iterations: UInt = 5
        ) async throws -> Duration {
            for i in 0..<50_000 { list <+ i }

            let clock = ContinuousClock()

            let duration = await clock.measure {
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<readerThreads {
                        group.addTask {
                            for _ in 0..<iterations {
                                list.forEach { _ in }
                            }
                        }
                    }

                    for writerIndex in 0..<writerThreads {
                        group.addTask {
                            let baseOffset = Int(writerIndex * 1000)
                            for i in 0..<1000 {
                                list <+ (baseOffset + i)
                                _ = ^list
                            }
                        }
                    }

                    await group.waitForAll()
                }
            }

            print("\(String(describing: L.self)): Mixed Contentions Duration (\(readerThreads) Readers, \(writerThreads) Writers): \(duration)")
            return duration
        }
    }


    // ==============================================
    // MARK: - List Node Excision O(1) Performance Suite
    // ==============================================

    @Suite("List Node Excision Performance Suite", .serialized, .tags(.performance))
    struct ListNodeExcisionPerformanceTests {

        @Test("List + OSAllocatedUnfairLock: Single-threaded O(1) intermediate node removal efficiency profile", .tags(.performance))
        func testNodeExcisionOSUnfair() {
            let list = List<Int, OSAllocatedUnfairLock>()
            executeExcisionBenchmark(for: list)
        }

        @Test("List + RWLock: Single-threaded O(1) intermediate node removal under POSIX write mutex", .tags(.performance))
        func testNodeExcisionRWLock() {
            let list = List<Int, RWLock>()
            executeExcisionBenchmark(for: list)
        }

        // ==========================================
        // MARK: - Private Benchmark Core Runner
        // ==========================================

        private func executeExcisionBenchmark<L: RWLocking>(for list: List<Int, L>, totalElements: Int = 100_000) {
            var references: [ListElement<Int>] = []
            references.reserveCapacity(totalElements / 2)

            for i in 0..<totalElements {
                list <+ i
                if i % 2 == 0, let currentTailNode = list.tail {
                    references.append(currentTailNode)
                }
            }

            let clock = ContinuousClock()

            let duration = clock.measure {
                for elementRef in references {
                    list.remove(elementRef)
                }
            }

            print("\(String(describing: L.self)): O(1) Excision Duration (\(references.count) nodes dropped out of \(totalElements)): \(duration)")
            #expect(list.count == UInt(totalElements - references.count))
            #expect(duration < .seconds(0.1))
        }
    }

}
