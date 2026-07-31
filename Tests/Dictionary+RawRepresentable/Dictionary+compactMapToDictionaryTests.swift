//
//  Dictionary+compactMapToDictionaryTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("Dictionary Compact Map To Dictionary Functional Suite")
struct DictionaryCompactMapToDictionaryTests {

    // MARK: - 1. Compact Map Entire Dictionary

    @Test("Dictionary: Transform elements and omit nil pairs using compactMapToDictionary")
    func testCompactMapToDictionaryTransform() {
        let source: [String: Int] = ["one": 1, "skip_me": 2, "three": 3]

        let transformed: [String: String] = source.compactMapToDictionary { key, value in
            guard key != "skip_me" else { return nil }
            return (key.uppercased(), String(value * 10))
        }

        #expect(transformed["ONE"] == "10")
        #expect(transformed["THREE"] == "30")
        #expect(transformed["SKIP_ME"] == nil)
        #expect(transformed.count == 2)
    }

    // MARK: - 2. Compact Map Keys Only

    @Test("Dictionary: Transform only keys and omit nil steps using compactMapKeys")
    func testCompactMapKeysTransform() {
        let source: [Int: String] = [1: "apple", 99: "discard", 2: "banana"]

        let transformed: [String: String] = source.compactMapKeys { key in
            guard key != 99 else { return nil }
            return "ID_\(key)"
        }

        #expect(transformed["ID_1"] == "apple")
        #expect(transformed["ID_2"] == "banana")
        #expect(transformed.count == 2)
    }

    // MARK: - 3. Compact Map Keys With Optional Values

    @Test("Dictionary: Transform keys and unwrap optional values simultaneously using compactMapKeys overload")
    func testCompactMapKeysWithOptionalValues() {
        let source: [String: Int?] = [
            "user_id": 101,
            "session_id": nil,      // Nil value should trigger pair removal
            "skip_key": 202,        // Closure will return nil for this key
            "token_id": 303
        ]

        let transformed: [String: Int] = source.compactMapKeys { key in
            guard key != "skip_key" else { return nil }
            return key.camelCasedSnake
        }

        #expect(transformed["userId"] == 101)
        #expect(transformed["tokenId"] == 303)
        #expect(transformed.count == 2)
    }

    // MARK: - 4. Compact Map Values (Unwrap Optional Values)

    @Test("Dictionary: Unwraps dictionary optional values filtering out any nil entries")
    func testCompactMapValuesPureUnwrap() {
        let source: [String: String?] = ["profile": "active", "avatar": nil, "theme": "dark"]
        let resolved: [String: String] = source.compactMapValues()

        #expect(resolved["profile"] == "active")
        #expect(resolved["avatar"] == nil)
        #expect(resolved["theme"] == "dark")
        #expect(resolved.count == 2)
    }

    // MARK: - 5. Error Propagation Triggers

    @Test("Dictionary: Verification of error propagation within throwing compact mapping closures")
    func testCompactMappingErrorPropagation() {
        struct MockCompactError: Error {}
        let source: [String: Int] = ["trigger": 1]
        let optionalSource: [String: Int?] = ["trigger": 1]

        // Explicit return type descriptions defined to guide type inference engine
        #expect(throws: MockCompactError.self) {
            try source.compactMapToDictionary { _, _ -> (String, Int)? in
                throw MockCompactError()
            }
        }

        #expect(throws: MockCompactError.self) {
            try source.compactMapKeys { _ -> String? in
                throw MockCompactError()
            }
        }

        #expect(throws: MockCompactError.self) {
            try optionalSource.compactMapKeys { _ -> String? in
                throw MockCompactError()
            }
        }
    }
}
