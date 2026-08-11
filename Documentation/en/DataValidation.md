# Data Validation and Text Strategies (DataValidation)

The `SwanCore` module provides high-performance tools for strict text data validation (emails, phone numbers, and URLs) built upon the system `NSDataDetector` engine and adapted for the Swift 6 Strict Concurrency model.

## ✨ Key Features
* **Full-Boundary Matching**: Unlike the standard `NSDataDetector`, which searches for substrings within text (potentially validating strings containing arbitrary trailing characters), the `matchesFullBoundary` method requires the detected range to exactly match the total length of the string (`result.range == range`).
* **Unified Strategy Contract**: The `StringValidator` protocol establishes a uniform interface for all validators, providing automatic synthesis of `Hashable` and `Equatable` conformance based on a unique string identifier (`id`).
* **Performance and Safety**: The components execute faster than standard regular expressions, correctly parse complex international Unicode domains, and natively conform to `Sendable` for safe utilization in asynchronous contexts.

---

## 🚀 Built-in Strategies Usage

The module includes three pre-configured atomic validation strategies covering common application use cases:

```swift
import SwanCore
import Foundation

do {
    // 1. Email Validation (utilizes the mailto scheme internally)
    let emailValidator = try EmailValidator()
    print(emailValidator.validate("developer@swankit.io")) // true
    print(emailValidator.validate("developer@swankit.io trailing text")) // false

    // 2. Phone Number Validation
    let phoneValidator = try PhoneNumberValidator()
    print(phoneValidator.validate("+1234567890")) // true
    print(phoneValidator.validate("Call me at +1234567890")) // false (boundary violation)

    // 3. Link Validation with Optional Scheme Filtering
    let httpsValidator = try LinkValidator(scheme: "https")
    print(httpsValidator.validate("https://anobisoft.com")) // true
    print(httpsValidator.validate("http://anobisoft.com"))  // false (scheme mismatch)
} catch {
    print("System detector initialization error: \(error)")
}
```

---

## 🏗 Collection Integration and Identification

Due to built-in `Hashable` conformance, validation strategies can be grouped, injected as dependencies, or utilized as dictionary keys for dynamic input form routing:

```swift
let customID = "profile_email_input"
let validatorA = try EmailValidator(id: customID)
let validatorB = try EmailValidator(id: customID)

// Comparison by ID
print(validatorA == validatorB) // true

// Usage as a hash table key
var validationRules: [AnyHashable: String] = [:]
validationRules[validatorA] = "The field must contain a valid email address"

print(validationRules[validatorB] ?? "Rule not found") 
// Outputs: "The field must contain a valid email address"
```

---

## 🛠 Implementing Custom Validation Strategies

The system can be extended by defining a custom structure that conforms to the `StringValidator` protocol. Example implementation for a 6-digit confirmation code validator:

```swift
public struct VerificationCodeValidator: StringValidator {
    public let id: String
    
    public init(id: String = UUID().uuidString) {
        self.id = id
    }
    
    public func validate(_ text: String) -> Bool {
        // Verifies that the string consists of exactly 6 digits
        return text.count == 6 && text.allSatisfy { \$0.isNumber }
    }
}
```
