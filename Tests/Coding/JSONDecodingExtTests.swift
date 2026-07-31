//
//  JSONDecodingExtTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Mock Decodable Entities

private struct User: Decodable, Equatable {
    let userId: Int
    let firstName: String
    let emailAddress: String
}

private struct MockCustomKey: CodingKey, CustomizableCodingKeyMapping {
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
        return CamelKey(stringValue: stringValue)!
    }
}

// MARK: - Test Suite

@Suite("JSON Decoder Extensions Validation Suite")
struct JSONDecodingExtTests {

    // MARK: - 1. Conveniences & Builders Validation

    @Test("Decoder: Verification of convenience initializers and fluent builder configuration API")
    func testConvenienceInitializersAndBuilders() {

        let decoder1 = JSONDecoder(strategy: JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase)
        guard case .convertFromSnakeCase = decoder1.keyDecodingStrategy else {
            Issue.record("Key decoding strategy does not match .convertFromSnakeCase")
        }

        // 2. Тестируем инициализатор стратегии дат
        let decoder2 = JSONDecoder(strategy: JSONDecoder.DateDecodingStrategy.iso8601)
        guard case .iso8601 = decoder2.dateDecodingStrategy else {
            Issue.record("Date decoding strategy does not match .iso8601")
        }

        let configuredDecoder = JSONDecoder()
            .keyDecodingStrategy(.useDefaultKeys)
            .dateDecodingStrategy(.millisecondsSince1970)
            .dataDecodingStrategy(.base64)

        guard case .useDefaultKeys = configuredDecoder.keyDecodingStrategy else {
            Issue.record("Fluent builder failed to set .useDefaultKeys")
        }

        guard case .millisecondsSince1970 = configuredDecoder.dateDecodingStrategy else {
            Issue.record("Fluent builder failed to set .millisecondsSince1970")
        }

        guard case .base64 = configuredDecoder.dataDecodingStrategy else {
            Issue.record("Fluent builder failed to set .base64")
        }
    }

    // MARK: - 2. Custom Extended Key Decoding Strategy Verification

    @Test("Decoder: Evaluation of custom extended snake_case decoding strategy using CamelKey parsing")
    func testConvertFromSnakeCaseExtended() throws {
        let jsonString = """
        {
            "user_id": 101,
            "first_name": "John",
            "email_address": "johnny@testmail.com"
        }
        """

        let jsonData = try #require(jsonString.data(using: .utf8))

        // Setup decoder using the extended custom strategy mapping layer
        let decoder = JSONDecoder(strategy: JSONDecoder.KeyDecodingStrategy.convertFromSnakeCaseExtended)

        // Execute dynamic decoding workflow
        let user = try decoder.decode(User.self, from: jsonData)

        #expect(user.userId == 101)
        #expect(user.firstName == "John")
        #expect(user.emailAddress == "johnny@testmail.com")
    }

    // MARK: - 3. Customizable Coding Key Protocol Redirection Mapping

    @Test("Decoder: Dynamic customizable protocol mapping interception validation")
    func testCustomizableKeyMappingInterception() throws {
        let strategy = JSONDecoder.KeyDecodingStrategy.customizable(CamelKey.self)

        if case .custom(let closure) = strategy {
            let mockInputKey = try #require(MockCustomKey(stringValue: "auth_token_expiration"))
            let processedKey = closure([mockInputKey])

            #expect(processedKey.stringValue == "authTokenExpiration")
        } else {
            Issue.record("Customizable strategy type failed internal metadata enum unpacking extraction rules.")
        }
    }

}
