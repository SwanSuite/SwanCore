//
//  Dictionary+mapToDictionaryTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("Dictionary Map To Dictionary Functional Suite")
struct DictionaryMapToDictionaryTests {

    // MARK: - 1. Map Entire Dictionary Verification

    @Test("Dictionary: Transform both keys and values using mapToDictionary mapping rules")
    func testMapToDictionaryTransform() throws {
        let source: [Int: String] = [1: "one", 2: "two", 3: "three"]

        // Transform keys to strings and capitalize string values
        let transformed: [String: String] = source.mapToDictionary { key, value in
            return (String(key), value.uppercased())
        }

        #expect(transformed["1"] == "ONE")
        #expect(transformed["2"] == "TWO")
        #expect(transformed["3"] == "THREE")
        #expect(transformed.count == 3)
    }

    // MARK: - 2. Map Keys Only Verification

    @Test("Dictionary: Transform only keys using mapKeys while keeping original values intact")
    func testMapKeysTransform() throws {
        let source: [String: Int] = ["a": 10, "b": 20]

        // Uppercase keys only
        let transformed: [String: Int] = source.mapKeys { key in
            return key.uppercased()
        }

        #expect(transformed["A"] == 10)
        #expect(transformed["B"] == 20)
        #expect(transformed.count == 2)
    }

    // MARK: - 3. Error Propagation Triggers

    @Test("Dictionary: Verification of error propagation semantics within throwing mapping closures")
    func testMappingErrorPropagation() {
        struct MockMappingError: Error {}
        let source: [String: Int] = ["trigger_error": 1]

        #expect(throws: MockMappingError.self) {
            // Явно указываем ожидаемый тип возвращаемого кортежа -> (String, Int)
            try source.mapToDictionary { _, _ -> (String, Int) in
                throw MockMappingError()
            }
        }

        #expect(throws: MockMappingError.self) {
            // Явно указываем ожидаемый тип возвращаемого ключа -> String
            try source.mapKeys { _ -> String in
                throw MockMappingError()
            }
        }
    }

}
