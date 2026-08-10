# SwanCore List Container Specification

## Overview

The `List<T, Lock>` container in `SwanCore` is a high-performance, thread-safe, symmetrical doubly linked list built entirely on modular protocol compositions. By implementing strict reference topology separation, it provides **O(1)** boundary mutations, comprehensive **Lock Dropping** iteration capabilities, and zero-cost abstraction fallback profiles.

---

## The L-Shape Mnemonics (Data Flow Geography)

To reconcile the vertical nature of a **Stack** (LIFO) and the horizontal nature of a **Queue** (FIFO) within a single unified data structure, this framework introduces the geometric **L-Shape Metaphor**. 

The letter **L** acts as a spatial anchor for memory, defining a strict two-dimensional geography for data flow.

```text
       [ Head / Peak ]   <--- Vertical Axis (Stack View)
              |               Elements are dropped from above:
              +> [Item]       - Chained push: `30 +> 20 +> list`
              |               - Head extraction hook: `^list`
              |
              |
              |
              +—————————————————— [ Tail / End ]   <--- Horizontal Axis (Queue View)
                                         <+ [Item]      Elements append to the right:
                                                        - Chained add: `list <+ 10 <+ 20`
                                                        - Tail extraction hook: `list^`
```

### 1. The Vertical Axis: Head (Top of the Stack)
The top-most vertex of the **L** represents the **Head** of the collection. It operates like a classic stack of documents where the most accessible item sits right at the peak.
* **`+>` (Push)**: Data falls vertically into the top. Right-associativity allows intuitive stacking syntax (`30 +> 20 +> list` means `20` goes first, then `30` lands on top of it).
* **`^list` (Prefix Pop)**: A vertical "hook" that lifts and pulls the top element off the peak.

### 2. The Horizontal Axis: Tail (End of the Queue)
The bottom-right vector of the **L** represents the **Tail** of the collection. It operates like a standard queue or service line where new data arrives at the rear end.
* **`<+` / `++` (Add / Append)**: Data attaches horizontally to the right tail. Left-associativity allows continuous pipeline flow (`list <+ 10 <+ 20`).
* **`list^` (Postfix Pop Tail)**: A horizontal "hook" that snaps and detaches the very last element from the tail.

### Precedence Rule Note
In Swift, **postfix operators always take precedence over prefix operators**. 
If you combine both hooks on a single list without parentheses (e.g., `^list^`), the compiler will strictly evaluate the **postfix tail hook first**, stripping the last element before any prefix operation occurs.

---

## 1. Architectural Architecture Breakdown

### Protocol Composition Blueprint
The `List` container implements thread safety and topology manipulation by combining lightweight, discrete structural components:

```text
              ┌──────────────────────────────────────┐
              │           ListContainer              │
              └──────────────────────────────────────┘
                  │              │               │
  ┌───────────────▼────────┐ ┌───▼───────────┐ ┌─▼──────────────────────┐
  │ FrontModifiable        │ │ ElementRemover│ │ ListIterator           │
  │ (pushFront / popFront) │ │ (O(1) remove) │ │ (Lock Dropping forEach)│
  └────────────────────────┘ └───────────────┘ └────────────────────────┘
                  │              │               │
                  └──────────────┼───────────────┘
                                 │
                     ┌───────────▼───────────┐
                     │       HasRWLock       │
                     │  (associatedtype Lock)│
                     └───────────────────────┘
```

* **`HasHead` / `HasTail` / `HasCount`**: Provide raw, unified layout hooks for referencing sequence borders (`Element?`) and tracking storage metrics (`UInt`) under strict reference semantics.
* **`ObjectContainer`**: Abstract memory model layout decoupling infrastructure wrappers from the payload tier. It allows `List` to hold strong, direct instances while seamlessly enabling weak delegate sweeps in `WeakList` implementations by setting `Element.T` to an implicit `Optional` wrapper.

---

## 2. Core Functional Mechanisms

### Symmetrical O(1) Boundary Mutators
Mutations at either end of the container are processed in constant time (**O(1)**). The architecture leverages static extension routing bound by conditional trait requirements to synthesize default thread-isolated mutator code blocks:

```swift
// Extracted from FrontAppendable implementation blueprint
lock.writeLock()
if tail == nil { tail = element }
element.next = head
head?.prev = element
head = element
count += 1
lock.unlock()
```

### O(1) Intermediate Node Deletion (`ElementRemover`)
Arbitrary node excision completely bypasses linear traversal scans. When an explicit reference to a `ListElement` is captured, the `remove(_:)` routine isolates the segment, stitches adjacent neighbors together under an exclusive writer lock path, and decrements the internal tracking metric counter without touching other sequence nodes.

```swift
public func remove(_ element: Element) {
    lock.writeLock()
    if let prev = element.prev { prev.next = element.next } else { head = element.next }
    if let next = element.next { next.prev = element.prev } else { tail = element.prev }
    count -= 1
    lock.unlock()
}
```

### High-Concurrency Lock Dropping Iterators
To guarantee system responsiveness and eliminate cross-module deadlocks, `List` avoids locking the collection over the entire duration of a loop. The core `forEachElement` loop uses a highly reactive **Lock Dropping** loop strategy:

1. **Acquire Read Lock**: Secures the current cursor and pre-buffers the subsequent step connection pointer (`let next = current.next`).
2. **Release Read Lock**: Immediately uncouples the shared lock.
3. **Execute Closures**: Invokes lazy inline `maintainance` filters (such as wiping expired weak slots) and runs user-provided handlers outside the lock.
4. **Re-acquire Read Lock**: Transitions safely to the pre-buffered step cursor.

This strategy ensures that if the current node is concurrently cut out or erased by a parallel worker thread, the iterator's state remains valid and successfully traverses to the end of the collection without breaking.

---

## 3. Idiomatic Usage Profiles

### Continuous Pipeline Feeding (Queue Layout)
Leverage left-associative data pipelines to feed data continuously into the collection's tail:

```swift
let queue = List<String, OSAllocatedUnfairLock>()

// Horizontal pipelining via <+ operator
queue <+ "First Task" <+ "Second Task" <+ "Third Task"

// Dequeue items sequentially using postfix pop hooks
while let task: String = queue^ {
    print("Processing: \(task)")
}
```

### Pushing Frames onto the Peak (Stack Layout)
Leverage right-associative vertical pipelines to stack entries on the collection's head:

```swift
let stack = List<Int, AdaptiveSpinLock<LazyContention>>()

// Vertical stacking via +> operator
100 +> 200 +> 300 +> stack

// Pop frames sequentially using prefix pop hooks
while let frame: Int = ^stack {
    print("Evaluating Frame: \(frame)")
}
```

### Dynamic Boundary Modifications
When operational boundaries are dictated at runtime, utilize dynamic target mapping via the `ModifyTarget` axis matrix:

```swift
func insert<T>(payload: T, into list: List<T, PosixRWLock>, at target: ModifyTarget) {
    // Dynamically routes execution into pushFront or pushBack paths
    list.push(payload, target: target)
}
```
