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

    @Suite("List Performance Execution Suite", .serialized, .tags(.performance))
    struct ListPerformanceTests {

        // ==========================================
        // MARK: - Write Allocation Benchmarks
        // ==========================================

        @Test("RetainList + VoidRWLock: Zero-overhead baseline benchmark profile for single-threaded mutation", .tags(.performance))
        func testPerformanceVoidRW() {
            let list = List<Int, VoidRWLock>()
            let clock = ContinuousClock()

            let duration = clock.measure {
                for i in 0...500_000 {
                    list <+ i
                }
            }

            print("VoidRWLock Append Duration: \(duration)")
            #expect(duration < .seconds(0.3))
        }

        @Test("RetainList + OSAllocatedUnfairLock: Native OS kernel lock baseline performance profiling", .tags(.performance))
        func testPerformanceOSUnfair() {
            let list = List<Int, OSAllocatedUnfairLock>()
            let clock = ContinuousClock()

            let duration = clock.measure {
                for i in 0...500_000 {
                    list <+ i
                }
            }

            print("OSAllocatedUnfairLock Append Duration: \(duration)")
            #expect(duration < .seconds(0.3))
        }

        @Test("RetainList + AdaptiveSpinLock: Execution benchmark profile for intensive structural node allocation", .tags(.performance))
        func testPerformanceAdaptiveSpin() {
            let list = List<Int, AdaptiveSpinLock<NormalContention>>()
            let clock = ContinuousClock()

            let duration = clock.measure {
                for i in 0...500_000 {
                    list <+ i
                }
            }

            print("AdaptiveSpinLock Append Duration: \(duration)")
            #expect(duration < .seconds(0.3))
        }

        @Test("RetainList + PosixRWLock: Strict cross-platform mutex performance layout profile", .tags(.performance))
        func testPerformancePosixRW() {
            let list = List<Int, PosixRWLock>()
            let clock = ContinuousClock()

            let duration = clock.measure {
                for i in 0...500_000 {
                    list <+ i
                }
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

        @Test("RetainList + PosixRWLock: Massively parallel read scaling benchmark profile", .tags(.performance))
        func testConcurrentReadPosixRW() async throws {
            let list = List<Int, PosixRWLock>()
            let duration = try await executeConcurrentReadBenchmark(for: list, iterationsPerThread: 2)
            #expect(duration < .seconds(2.0))
        }

        @Test("RetainList + AdaptiveSpinLock: Concurrent read benchmark profile under exclusive spinning", .tags(.performance))
        func testConcurrentReadAdaptiveSpin() async throws {
            let list = List<Int, AdaptiveSpinLock<NormalContention>>()
            let duration = try await executeConcurrentReadBenchmark(for: list, iterationsPerThread: 2)
            #expect(duration < .seconds(1.5))
        }

        @Test("RetainList + OSAllocatedUnfairLock: Concurrent read benchmark profile under native kernel lock", .tags(.performance))
        func testConcurrentReadOSUnfair() async throws {
            let list = List<Int, OSAllocatedUnfairLock>()
            let duration = try await executeConcurrentReadBenchmark(for: list)
            #expect(duration < .seconds(1.5))
        }

        @Test("RetainList + VoidRWLock: Baseline execution profile for thread-free concurrent simulation", .tags(.performance))
        func testConcurrentReadVoidRW() async throws {
            let list = List<Int, VoidRWLock>()
            let duration = try await executeConcurrentReadBenchmark(for: list)
            #expect(duration < .seconds(1.0))
        }

        // ==========================================
        // MARK: - Private Benchmark Core Runner
        // ==========================================

        /// Унифицированный движок для замера производительности параллельного Lock Dropping чтения.
        private func executeConcurrentReadBenchmark<L: RWLocking>(
            for list: List<Int, L>,
            threads: UInt = 8,
            iterationsPerThread: UInt = 4
        ) async throws -> Duration {
            // Предварительно наполняем коллекцию элементами для итерации
            for i in 0..<100_000 {
                list <+ i
            }

            let clock = ContinuousClock()

            let duration = await clock.measure {
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0..<threads {
                        group.addTask {
                            for _ in 0..<iterationsPerThread {
                                list.forEach { _ in
                                    return
                                }
                            }
                        }
                    }
                    await group.waitForAll()
                }
            }

            print("===> \(String(describing: L.self)):\nConcurrent Read Duration (100_000x\(iterationsPerThread), \(threads) threads): \(duration)")
            return duration
        }
    }
}
