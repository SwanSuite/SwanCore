# SwanCore Serialization Utilities (JSON Codable Helpers)

This component provides a collection of lightweight utilities, extensions, and protocols designed to optimize serialization and deserialization workflows within the Swift ecosystem, augmenting standard `JSONEncoder` and `JSONDecoder` capabilities. The package automates call-site type inference and introduces dynamic, bidirectional, real-time key formatting transformation layers.

## Architecture and Core Components

The serialization toolkit architecture consists of three cohesive layers:
1. **Type Inference API**: Extensions for `JSONDecoder`, `Decodable`, and `Data` that eliminate the requirement of explicitly passing type metatypes (`T.self`) when the target structure can be statically deduced by the compiler.
2. **Declarative Configuration (Fluent API)**: Encoder and decoder configuration modifiers implementing the Builder design pattern, enabling declarative configuration chains.
3. **Dynamic Key Mapping and Casing Translation**: A structural abstraction layer backed by the `CustomizableCodingKeyMapping` protocol and concrete `CamelKey` / `ScreamingSnakeKey` implementations for intercepting and rewriting naming conventions on the fly.

---

## The CustomizableCodingKeyMapping Protocol

The protocol inherits from `CodingKey` and `Sendable`, guaranteeing complete concurrency thread safety across asynchronous isolation boundaries within the Swift 6 Strict Concurrency model.

```swift
public protocol CustomizableCodingKeyMapping: CodingKey, Sendable {
    var mapped: CodingKey { get }
}
```

By implementing the `mapped` property, an eligible type establishes a dedicated routing fallback rule. If a key encountered during serialization complies with this protocol, the custom strategy delegates execution to the underlying substitution rule. An identity mapping fallback returning `self` is applied by default.

---

## Built-in Case Transformation Strategies

The package exposes two extended pre-configured key strategies that combine automated case conversions with native support for dynamic key redirection protocols:

### 1. The `convertFromSnakeCaseExtended` Strategy
* **Target Interface**: `JSONDecoder.KeyDecodingStrategy`.
* **Behavior**: Utilizes the concrete `CamelKey` structure to automatically map inbound `snake_case` JSON fields into standard `camelCase` properties.
* **Evaluation Mechanics**: If an active token complies with `CustomizableCodingKeyMapping`, its individual `mapped` rule is respected; otherwise, the identifier converts to `camelCase` via string layout analysis.

### 2. The `convertToScreamingSnakeCase` Strategy
* **Target Interface**: `JSONEncoder.KeyEncodingStrategy`.
* **Behavior**: Utilizes the concrete `ScreamingSnakeKey` structure to transform typical `camelCase` application models into uppercase `SCREAMING_SNAKE_CASE` configurations during serialization.
* **Array Index Safety**: The `init(intValue:)` constructor isolates collection indexes from erroneous string mapping: index inputs translate to a string fallback for encoder stability, while `intValue` explicitly returns `nil` to declare an out-of-scope subscript conversion.

---

## Code Examples

### 1. Streamlined Decoding via Type Inference
```swift
// Traditional Foundation pattern:
let user = try JSONDecoder().decode(User.self, from: rawData)

// SwanCore type-inferred pattern (target structure is derived from the call-site):
let user: User = try rawData.decode()
let profile: Profile = try JSONDecoder().decode(payloadData)
```

### 2. Fluent Decoder Configuration with Snake Case Support
```swift
let decoder = JSONDecoder()
    .keyDecodingStrategy(.convertFromSnakeCaseExtended)
    .dateDecodingStrategy(.iso8601)

let session: Session = try decoder.decode(networkData)
```

### 3. Serialization into SCREAMING_SNAKE_CASE
```swift
let encoder = JSONEncoder(.convertToScreamingSnakeCase)
    .dateEncodingStrategy(.millisecondsSince1970)

// Inverted execution sequence triggered directly on the encodable model instance
let payload: Data = try serverConfig.encode(encoder: encoder)
```

---

## String Case Converting Utilities

The extension on `String` performs atomic, low-level case transformations independently of expensive system layout locales:
* `upperFirst()` — Capitalizes the initial character of a string while maintaining the casing of the remaining stream.
* `pascalCasedSnake` — Decomposes a `snake_case` layout to assemble a valid `PascalCase` string representation.
* `camelCasedSnake` — Transforms a `snake_case` string into a standard `camelCase` format.
* `camelCaseTo_SCREAMING_SNAKE` — Parses `camelCase` attributes via regular expression boundaries, inserting underscores before uppercase or numeric transitions, and mapping the entire sequence to its uppercase equivalent.
