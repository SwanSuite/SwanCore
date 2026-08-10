# SwanCore Versioning Engine

A high-performance, memory-efficient, and highly extensible generic software versioning framework written in modern Swift. 

Unlike traditional flat versioning tools, **SwanCore** strictly separates the unchangeable industry core primitives (`major.minor.patch`) from the volatile, project-specific deployment lifecycle pipelines (pre-releases, branches, builds, CI/CD metadata) using advanced Swift generics and type-safe abstract layout trees.

---

## 🚀 Key Features

- **Zero-Allocation Core Primitives**: Immutable structural coordinates backed by optimized memory layout cascades.
- **Generic Lifecycle Contexts (`VersionStage`)**: Swap contexts at compile-time—from bare releases (`VoidVersionStage`) to full Semantic Versioning 2.0.0 (`CanonicalVersionStage`), or completely custom enterprise pipelines.
- **Bi-Directional Schema Symmetry**: Use a single tokenized pattern template string for **both** formatting a model into a string and parsing a string back into a structural type.
- **Strict AST Compiler State Machine**: Fast, linear character stream scanner executing complex nesting validation rules (AND/OR priority evaluation) without regular expressions or performance bottlenecks.
- **Mutually Exclusive Selections (`select`)**: Native support for strict One-Hot alternative pipelines through structural pipe configurations (`[ A | B ]`).

---

## 🛠 Architectural Overview

The engine acts as a loose-coupling bridge between your structural state data container models and layout presentation requirements:

```text
[ Raw String Input ] ──► (VersionFormatter Scanner) ──► [ Token Dictionary ]
                                                                │
                                                         (TokensComposable)
                                                                ▼
[ Stylized Output ]  ◄── (VersionFormatter Engine)  ◄── [ Generic Version<Stage> ]
```

---

## 📝 Format Pattern Blueprint Syntax

Templates utilize dedicated uppercase layout markers preceded by a `%` character. All static punctuation separators (dots, dashes, brackets, spacers) are processed as strict layout invariants.

### 1. Base Framework System Tokens
- `%MJ` — **Major**: Dominant primary development baseline integer index.
- `%MN` — **Minor**: Secondary feature enhancement iteration index.
- `%P`  — **Patch**: Tertiary bug correction deployment sequence index.

### 2. Canonical Stage Tokens (`CanonicalVersionStage`)
- `%SI` — **Stage Identifier**: Prerelease milestone string name (`alpha`, `beta`, `rc`).
- `%SV` — **Stage Version**: Incremental tracking step progressing within the active milestone.
- `%B`  — **Build**: Low-level technical machine compilation sequence tracking marker.

### 3. Structural Condition Boundaries `[...]`
Square brackets define hierarchical conditional logical layers:
- **AND (ALL) Strategy**: If an optional layer directly hosts template tokens, the block evaluates to an active state **only if all immediate layout tokens are explicitly populated** with non-nil parameters.
- **OR (ANY) Strategy**: If an optional layer hosts nested sub-blocks without immediate root tokens, it delegates active status tracking downwards, preserving visibility if **at least one** child branch remains valid.

### 4. Alternative Pipe Choice Framework `[ A | B ]`
The pipe operator `|` within a boundary level splits the domain space into mutually exclusive selection branches. The runtime controller applies **strict One-Hot verification metrics**: **exactly one** alternative choice path must evaluate to an active state. If 0 or ≥ 2 branches attempt to render simultaneously, a scheduling conflict is detected, and the entire node safely collapses into an empty stream.

---

## 📦 Core Layout Profiles (Presets)

SwanCore exposes standard built-in layout configurations via `VersionFormatter`:

| Preset | Pattern Structure | Sample Structural Realization Output |
| :--- | :--- | :--- |
| `.short` | `%MJ[.%MN][.%P]` | `"1.2.3"` or `"1"` *(trailing zero components are pruned)* |
| `.medium` | `%MJ.%MN[.%P][[-%SI[.%SV]]\|[ b%B]]` | `"1.2.3-rc1"`, `"1.0 b12"`, or `"2.0"` *(strict alternative selection)* |
| `.long` | `version %MJ.%MN.%P[-%SI[.%SV]][ build %B]` | `"version 1.2.3-rc1 build 45"` |
| `.semVer` | `%MJ.%MN.%P[-%SI[.%SV]][+b%B]` | `"1.2.3-rc1+b45"` *(strict standard SemVer 2.0.0 compliance)* |
| `.appleBundle`| `%MJ.%MN.%P` | `"1.2.3"` *(standard unified App Store / TestFlight blueprint)* |

---

## 💻 Usage Examples

### 1. Basic Models & Formats
```swift
// Pure version profile layout tracking (Zero-Allocation VoidVersionStage)
let coreLib = CoreVersion(major: 1, minor: 4, patch: 0, stage: .void)
print(coreLib.formatted(.short)) // Outputs: "1.4"

// Comprehensive standard SemVer layout configuration profile
let stage = CanonicalVersionStage(identifier: .beta, version: 3, build: 412)
let appVersion = CanonicalVersion(major: 2, minor: 0, patch: 1, stage: stage)

print(appVersion.formatted(.semVer)) // Outputs: "2.0.1-beta.3+b412"
print(appVersion.formatted(.medium)) // Outputs: "2.0.1-beta.3" (build omitted by select conflict)
```

### 2. Powerful Bi-Directional Mirror Parsing
Thanks to the unified `TokensComposable` protocol, models can seamlessly synthesize their states out of text descriptions matching any valid formatting mask:

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

### 3. Type-Safe Evolutionary Sorting Matrix
```swift
let v1 = CanonicalVersion(major: 1, minor: 0, stage: CanonicalVersionStage(identifier: .alpha, version: 5))
let v2 = CanonicalVersion(major: 1, minor: 0, stage: CanonicalVersionStage(identifier: .releaseCandidate, version: 1))
let v3 = CanonicalVersion(major: 1, minor: 0, stage: CanonicalVersionStage(identifier: .release)) // or nil stage

print(v1 < v2)  // Outputs: true  (alpha < rc)
print(v2 < v3)  // Outputs: true  (rc < release/stable)
print(v3 == CanonicalVersion(major: 1, minor: 0, patch: 0)) // Outputs: true (nil normalization comparison checks)
```

---

## 🔒 Thread Safety and Performance

- **`Sendable` Compliance**: All structural data components, layout format types, internal abstract tree states (`AST.Node`), and validation context nodes strictly declare and maintain complete `Sendable` conformity.
- **Linear Compilation Performance**: Complex layout design template pattern operations compile strictly **once** at token engine validation initialization time into lightweight execution nodes, transforming formatting and reverse scanning loops into high-velocity, heap-free CPU branch cascades.
