# SwanCore Synchronization Architecture Specification

## Overview

The `SwanCore` synchronization engine delivers an ultra-high-performance, thread-safe, memory-efficient execution isolation tier optimized for modern multi-threaded environments. By deeply integrating with modern Swift safety invariants, the architecture completely eliminates runtime dynamic dispatch overhead and prevents accidental data-race mutations at compile time.

### Core Architectural Pillars
1. **Uniqueness via Non-Copyable Concepts (`~Copyable`)**: Restricting bitwise memory replication at compile time prevents accidental duplication of low-level primitive locks—avoiding undefined kernel-scheduler behaviors and race defects.
2. **Static Flattening Polynomials (`associatedtype`)**: Storage containers isolate synchronization policies using static type requirements rather than runtime existential type erasure wrappers (`AnyObject`). This permits the compiler to completely inline (`@inline(__always)`) locking structures directly into application loops.
3. **Lock Dropping Traversal Modalities**: Sequential iteration engines employ an aggressive read-lock dropping strategy. Shared locks are held exclusively to read and buffer structural sequence cursors, then completely uncoupled before user payloads or clean-up hooks trigger. This prevents priority inversion, lock starvation, and cross-module cascade deadlocks.

---

## 1. Protocol Structural Layout Contracts

### `Locking`
A high-performance mutual exclusion specification enforcing exclusive resource ownership under unique borrow boundaries.

```swift
public protocol Locking: Sendable, ~Copyable {
    init()

    /// Acquires the lock exclusively. Blocks the calling thread if already held.
    borrowing func lock()

    /// Releases the exclusive lock.
    borrowing func unlock()

    /// Tries to acquire the exclusive lock without blocking the calling thread.
    /// - Returns: `true` if successfully acquired; otherwise, `false`.
    borrowing func lockIfAvailable() -> Bool
}
```

### `RWLocking`
A high-performance shared-exclusive synchronization contract enforcing multi-threaded concurrent reading routes while strictly isolating state mutations behind a single writer block path.

```swift
public protocol RWLocking: Sendable, ~Copyable {
    init()
    borrowing func readLock()
    borrowing func writeLock()
    borrowing func unlock()
    borrowing func tryReadLock() -> Bool
    borrowing func tryWriteLock() -> Bool
}
```

### Container Layout Ties (`HasLock` & `HasRWLock`)
Establishes clear ownership boundaries over concrete locking types within data structures.

```swift
public protocol HasLock: AnyObject {
    associatedtype Lock: Locking
    var lock: Lock { get }
}

public protocol HasRWLock: AnyObject {
    associatedtype Lock: RWLocking
    var lock: Lock { get }
}
```

---

## 2. Low-Level Primitive Implementations

### `AdaptiveSpinLock`
A zero-cost generic lock that dynamically balances active CPU user-space spinning with safe thread suspension paths. It uses an **inverted contention profiling strategy** to automatically tune spin-loop strategies based on target thread densities.

* **High Contention Strategy (Axiom)**: Under high data congestion, active spinning is highly destructive due to intensive cache-line bouncing. The lock decreases active spin counts under heavy load, safely parking threads into kernel wait queues immediately to keep the shared CPU memory bus clear.

```swift
public protocol SpinThreshold {
    static var attemptsMax: UInt { get }
}

/// For isolated environments with zero thread-collisions. Maximize user-space spinning.
public enum LazyContention: SpinThreshold { public static var attemptsMax: UInt { 10000 } }

/// Balanced setting for standard application concurrent routing passes.
public enum NormalContention: SpinThreshold { public static var attemptsMax: UInt { 1000 } }

/// For high-traffic shared resources. Abort spin loops quickly to avoid bus over-saturation.
public enum HeavyContention: SpinThreshold { public static var attemptsMax: UInt { 100 } }

/// Saturated parallel execution hotspots. Instantly block to prevent thermal throttling.
public enum ExtremeContention: SpinThreshold { public static var attemptsMax: UInt { 10 } }
```

#### Memory Geometry & Allocation Profile
`AdaptiveSpinLock` achieves a **Zero-Cost Storage Layout**. It stores **no state fields** for bounds tracking on the class instance level. The threshold value `T.attemptsMax` is treated as a compile-time constant, injected directly by the LLVM optimizer into target hardware CPU registers (`MOV` instructions) during static compilation phases.

### `PosixRWLock`
A strict POSIX-compliant implementation wrapping `pthread_rwlock_t` within a `final class` footprint. The class footprint guarantees a perfectly stable memory location address for the raw C kernel primitive, eliminating memory shifting defects while allowing direct pointer bindings within non-mutating `borrowing` execution contexts.

### `VoidRWLock`
A zero-cost, frozen dummy synchronization primitive that completely skips all locking instructions. It is designed to act as a benchmark baseline and to optimize execution pipelines operating in guaranteed single-threaded isolation contexts.

---

## 3. Hardware Execution Profile Analysis

The synchronization architecture was profiled on an Apple Silicon `arm64e` hardware matrix under a strict serialized execution benchmark suite (500,000 dense boundary mutations and 8,000,000 parallel read iterations over a 100,000 element topological sequence).

### Single-Threaded Write Allocation Layout (0 to 500,000 Appends)

| Primitive Type | Duration (Seconds) | Execution Efficiency vs. Baseline (`VoidRWLock`) |
| :--- | :--- | :--- |
| `VoidRWLock` | **0.229s** | *Baseline (100% Ideal Performance - No Locks)* |
| `OSAllocatedUnfairLock` | **0.230s** | +0.43% (Near-Zero Hardware Overhead) |
| `PosixRWLock` | **0.235s** | +2.62% |
| `AdaptiveSpinLock<Normal>` | **0.234s** | +2.18% (Optimized Register-level `while` loop) |

#### Hardware Insights:
* **The `while` vs `for-in` Micro-Optimization**: Shifting the software fallback spin phase from a standard `for-in` sequence range loop to a flat register `while` condition reduced execution overhead from **0.330s** down to **0.234s**. This optimization removed the hidden allocation of `IndexingIterator` wrappers and boundary checking code, restoring pure C-speed performance.
* **The Native Fast Path**: In single-threaded operations where zero contention occurs, native `os_unfair_lock` engines execute a single atomic `LDREX`/`STREX` cycle straight in the L1 CPU cache lines, matching the performance of thread-unsafe code.

### Massively Parallel Read Layout (4 Concurrent Workers × 5 Sweeps)

| Primitive Type | Concurrent Duration (Seconds) | Architectural Vulnerability under High Traffic |
| :--- | :--- | :--- |
| `VoidRWLock` | **0.447s** | Thread Unsafe (Simulation Only) |
| `OSAllocatedUnfairLock` | **0.786s** | Moderate Bus Contention |
| `PosixRWLock` | **1.072s** | Reader Registry Atomic Counter Overhead |
| `AdaptiveSpinLock<Normal>` | **1.354s** | Severe Cache-Line Bouncing |

#### Hardware Insights:
* **Why `OSAllocatedUnfairLock` Outperformed Shared Reader-Writer Mutexes**: Under fast Lock Dropping paths (where the critical section only copies a single node reference cursor), the atomic book-keeping overhead inside `pthread_rwlock_rdlock` (tracking reader thread counts, checking active writer flags, and managing ticket queues) becomes more expensive than the execution of the lock itself. The lightweight, user-space nature of Apple's unfair lock processes high-frequency cycles with significantly lower latency.
* **Why `AdaptiveSpinLock` Suffered under High Stress**: Saturated parallel contention forced all 4 cores to repeatedly enter active hardware spin loops simultaneously. This caused intense **Cache Line Bouncing**, requiring the CPU to continuously synchronize memory states across core clusters, adding 0.5 seconds of latency compared to native unfair locking.

---

## 4. Integration Guidelines

To assign a custom synchronization primitive to an existing `SwanCore` container, specify the target lock during generic structural declaration bounds initialization:

```swift
// Production Build Configuration: Optimized for high-frequency low-latency Apple platforms
let platformSecureList = List<Int, OSAllocatedUnfairLock>()

// High-Traffic Distributed Hotspot: Enforces register-level spin-to-block bounds protection
let highlyConcurrentList = List<String, AdaptiveSpinLock<HeavyContention>>()

// Single-Threaded Worker / Sandbox: Disables all lock overhead entirely via static compilation
let sandboxedBenchmarkList = List<Double, VoidRWLock>()
```

