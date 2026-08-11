# SwanCore Versioning Utilities (Data Models & Formatting Helpers)

This component provides a collection of lightweight data structures and utilities designed for representing, formatting, and parsing software versions. The solution decouples immutable core version properties from volatile deployment lifecycle contexts using Swift generics and Abstract Syntax Tree (AST) layout evaluation.

## Architecture and Core Components

The utility architecture consists of three logical layers:
1. **Data Containers (`Version<Stage>`)**: A generic structure encapsulating primary numeric coordinates (`major`, `minor`, `patch`) alongside a polymorphic lifecycle wrapper (`Stage`).
2. **Lifecycle Strategies (`VersionStage`)**: A protocol defining behaviors for pre-release and build metadata tracking. It includes two concrete implementations out of the box:
   * `VoidVersionStage` (aliased as `CoreVersion`) — a stateless, zero-allocation stub structure for standard versions lacking extended metadata.
   * `CanonicalVersionStage` (aliased as `CanonicalVersion`) — a structured model providing full compliance with the SemVer 2.0.0 specification.
3. **Layout Compilation Engine (`VersionFormatter`)**: A compiler that transforms a tokenized design pattern string into an Abstract Syntax Tree (AST) at initialization time, enabling bidirectional translation (string formatting and reverse text parsing).

---

## Pattern Syntax Blueprint

The layout configurations for `VersionFormatter` are declared using a template string where uppercase characters preceded by a `%` character are evaluated as dynamic data tokens. All static punctuation markers, spaces, and literal characters are processed as strict layout invariants.

### Token Identifiers
* `%MJ` — **Major**: Dominant primary release integer index (`major` component).
* `%MN` — — **Minor**: Secondary feature enhancement iteration index (`minor` component).
* `%P`  — **Patch**: Tertiary bug correction deployment sequence index (`patch` component).
* `%SI` — **Stage Identifier**: Pre-release milestone string identifier (`alpha`, `beta`, `rc` — `stage.identifier` component).
* `%SV` — **Stage Version**: Incremental tracking step progressing within the active milestone (`stage.version` component).
* `%B`  — **Build**: Technical machine compilation sequence tracking marker (`stage.build` component).

### Condition Boundaries `[...]`
Square brackets define hierarchical conditional logical layers:
* **AND (ALL) Strategy**: If an optional layer directly hosts template tokens, the block evaluates to an active state **only if all immediate layout tokens are explicitly populated** with non-nil parameters.
* **OR (ANY) Strategy**: If an optional layer hosts nested sub-blocks without immediate root tokens, it delegates active status tracking downwards, preserving visibility if **at least one** child branch remains valid.

### Alternative Choice Framework `[ A | B ]`
The pipe operator `|` within a boundary level splits the domain space into mutually exclusive selection branches. The runtime controller applies **strict One-Hot verification metrics**: **exactly one** alternative choice path must evaluate to an active state. If 0 or ≥ 2 branches attempt to render simultaneously, a scheduling conflict is detected, and the entire node collapses into an empty stream.

---

## Built-in Layout Profiles (Presets)

`VersionFormatter` exposes standard built-in layout configurations via predefined static properties:

| Preset | Pattern Structure | Sample Realization Output |
| :--- | :--- | :--- |
| `.short` | `%MJ[.%MN][.%P]` | `"1.2.3"` or `"1"` *(trailing zero components are pruned)* |
| `.medium` | `%MJ.%MN[.%P][[-%SI[.%SV]]\|[ b%B]]` | `"1.2.3-rc1"`, `"1.0 b12"`, or `"2.0"` *(strict alternative selection)* |
| `.long` | `version %MJ.%MN.%P[-%SI[.%SV]][ build %B]` | `"version 1.2.3-rc1 build 45"` |
| `.semVer` | `%MJ.%MN.%P[-%SI[.%SV]][+b%B]` | `"1.2.3-rc1+b45"` *(strict standard SemVer 2.0.0 compliance)* |
| `.appleBundle`| `%MJ.%MN.%P` | `"1.2.3"` *(standard unified App Store / TestFlight blueprint)* |

---

## Code Examples

### 1. Formatting Data Models
```swift
// Utilizing pure version tracking without metadata (VoidVersionStage)
let coreLib = CoreVersion(major: 1, minor: 4, patch: 0)
print(coreLib.formatted(.short)) // Outputs: "1.4"

// Utilizing comprehensive standard SemVer layout configuration profile
let stage = CanonicalVersionStage(identifier: .beta, version: 3, build: 412)
let appVersion = CanonicalVersion(major: 2, minor: 0, patch: 1, stage: stage)

print(appVersion.formatted(.semVer)) // Outputs: "2.0.1-beta.3+b412"
print(appVersion.formatted(.medium)) // Outputs: "2.0.1-beta.3" (build omitted by select conflict)
```

### 2. Powerful Bi-Directional Mirror Parsing
The parser decompiles text streams using the pre-compiled AST hierarchy, employing local stream rollbacks if structural parsing rules fail:

```swift
// Direct string parsing via type-safe LosslessStringConvertible (employing .medium by default)
if let parsed = CanonicalVersion("1.0 b145") {
    print(parsed.major)         // Outputs: 1
    print(parsed.minor)         // Outputs: 0
    print(parsed.stage?.build)  // Outputs: 145
}

// Custom specialized blueprint context reverse-parsing execution sequence
let gitTagFormatter = try VersionFormatter(format: "release-v%MJ.%MN[.%P]")
if let rawTokens = gitTagFormatter.parse("release-v1.8") {
    let customVersion = CanonicalVersion(tokens: rawTokens)
    print(customVersion?.minor) // Outputs: 8
}
```

### 3. Type-Safe Evolutionary Sorting
The `Version` structure implements `Comparable`. Precedence validation routes sequentially through components: `major` -> `minor` -> `patch` -> `stage`.

```swift
let v1 = CanonicalVersion(major: 1, minor: 0, stage: .init(identifier: .alpha, version: 5))
let v2 = CanonicalVersion(major: 1, minor: 0, stage: .init(identifier: .releaseCandidate, version: 1))
let v3 = CanonicalVersion(major: 1, minor: 0, stage: .init(identifier: .release))

print(v1 < v2)  // Outputs: true (alpha < rc)
print(v2 < v3)  // Outputs: true (rc < release/stable)
print(v3 == CanonicalVersion(major: 1, minor: 0, patch: 0)) // Outputs: true (nil normalization checks)
```

---

## Thread Safety and Computational Complexity

* **Type Concurrency Safety**: All data containers (`Version`, `VersionFormatter`), internal representations (`AST.Node`), and validation sub-components explicitly declare complete `Sendable` conformity. This allows safe usage within Swift 6 Strict Concurrency asynchronous loops without external thread locks.
* **Performance Overhead Optimization**: Template evaluation pattern operations compile strictly **once** during `VersionFormatter` initialization. Subsequent serialization or reverse parsing execution operations run within linear time complexity O(N) relative to string length, bypassing standard regular expression engines and operating without heap allocation overhead for intermediate tree components.
