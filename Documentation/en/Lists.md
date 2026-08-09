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

