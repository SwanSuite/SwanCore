//
//  JSONEncodingExtTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Mock Encodable Entities

private struct ConfigurationSetting: Encodable, Equatable {
    let maxRetryCount: Int
    let authTokenExpiration: String
}

private struct MockCustomEncodingKey: CodingKey, CustomizableCodingKeyMapping {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }

    var mapped: CodingKey {
        return ScreamingSnakeKey(stringValue: stringValue)!
    }
}

// MARK: - Test Suite

@Suite("JSON Encoder Extensions Validation Suite")
struct JSONEncodingExtTests {

    // MARK: - 1. Conveniences & Builders Validation

    @Test("Encoder: Verification of convenience initializers and fluent builder configuration API")
    func testConvenienceInitializersAndBuilders() {
        // Test convenience init targeting key strategy
        let encoder1 = JSONEncoder(.convertToSnakeCase)
        guard case .convertToSnakeCase = encoder1.keyEncodingStrategy else {
            Issue.record("Key encoding strategy does not match .convertToSnakeCase")
        }

        // Test convenience init targeting date strategy
        let encoder2 = JSONEncoder(.iso8601)
        guard case .iso8601 = encoder2.dateEncodingStrategy else { // Assuming dateEncodingStrategy typo sync
            Issue.record("Failed to set dateEncodingStrategy")
        }

        // Test Fluent Builder API method chaining chaining
        let configuredEncoder = JSONEncoder()
            .keyEncodingStrategy(.useDefaultKeys)
            .dateEncodingStrategy(.millisecondsSince1970)
            .dataEncodingStrategy(.base64)

        guard case .useDefaultKeys = configuredEncoder.keyEncodingStrategy else {
            Issue.record("Fluent builder failed to set .useDefaultKeys")
        }

        guard case .millisecondsSince1970 = configuredEncoder.dateEncodingStrategy else {
            Issue.record("Fluent builder failed to set .millisecondsSince1970")
        }

        guard case .base64 = configuredEncoder.dataEncodingStrategy else {
            Issue.record("Fluent builder failed to set .base64")
        }
    }

    // MARK: - 2. Custom Extended Key Encoding Strategy Verification

    @Test("Encoder: Evaluation of custom extended SCREAMING_SNAKE_CASE encoding strategy using ScreamingSnakeKey")
    func testConvertToScreamingSnakeCase() throws {
        let setting = ConfigurationSetting(maxRetryCount: 5, authTokenExpiration: "3600s")

        let encoder = JSONEncoder()
            .keyEncodingStrategy(.convertToScreamingSnakeCase)

        let encodedData = try encoder.encode(setting)
        let jsonObject = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any]
        let unwrappedDict = try #require(jsonObject)

        // Assert that the properties converted successfully to SCREAMING_SNAKE_CASE keys
        #expect(unwrappedDict["MAX_RETRY_COUNT"] as? Int == 5)
        #expect(unwrappedDict["AUTH_TOKEN_EXPIRATION"] as? String == "3600s")
    }

    // MARK: - 3. Customizable Coding Key Protocol Interception

    @Test("Encoder: Dynamic customizable protocol mapping interception validation")
    func testCustomizableKeyMappingInterception() throws {
        let strategy = JSONEncoder.KeyEncodingStrategy.customizable(ScreamingSnakeKey.self)

        if case .custom(let closure) = strategy {
            // CustomizableCodingKeyMapping
            let mockInputKey = try #require(MockCustomEncodingKey(stringValue: "authTokenExpiration"))
            let processedKey = closure([mockInputKey])

            #expect(processedKey.stringValue == "AUTH_TOKEN_EXPIRATION")
        } else {
            Issue.record("Customizable encoding strategy type failed internal metadata enum unpacking extraction rules.")
        }
    }

    // MARK: - 4. Int Value Array Fallback Verification

    @Test("ScreamingSnakeKey: Validation of array index formatting fallback layout rules")
    func testScreamingSnakeKeyIntValueFallback() throws {
        let keyIndexed = try #require(ScreamingSnakeKey(intValue: 404))

        #expect(keyIndexed.stringValue == "404")
        #expect(keyIndexed.intValue == nil)
    }
}
