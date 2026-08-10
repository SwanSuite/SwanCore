//
//  String+CaseConvertingTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("String Case Converting Utilities Validation Suite")
struct StringCaseConvertingTests {

    // MARK: - 1. Boundary & Emptiable States Validation

    @Test("Transcoding: Edge cases including completely empty string sequences")
    func testEmptyAndMinimalStrings() {
        // Verification of Emptiable.empty state baseline behaviors
        let emptyText = String.empty
        #expect(emptyText.transcodeFirst { $0.uppercased() } == "")
        #expect(emptyText.upperFirst() == "")
        #expect(emptyText.pascalCasedSnake == "")
        #expect(emptyText.camelCasedSnake == "")
        #expect(emptyText.camelCaseTo_SCREAMING_SNAKE == "")

        // Single character operational boundaries
        #expect("a".upperFirst() == "A")
        #expect("A".transcodeFirst { $0.lowercased() } == "a")
    }

    // MARK: - 2. Snake Case to Pascal / Camel Conversions

    @Test("Transcoding: Transformation workflows from snake_case layouts")
    func testSnakeCaseConversions() {
        let key = "user_profile_details"
        #expect(key.pascalCasedSnake == "UserProfileDetails")
        #expect(key.camelCasedSnake == "userProfileDetails")

        // Verifies systemic capitalization behavior (drops subsequent acronym letters to lower)
        let acronymKey = "http_api_client"
        #expect(acronymKey.pascalCasedSnake == "HttpApiClient")

        // Dynamic proxy namespace validations
        #expect(String.Transcoding.snakeToPascalCase("auth_token") == "AuthToken")
        #expect(String.Transcoding.snakeToCamelCase("auth_token") == "authToken")
    }

    // MARK: - 3. Camel Case to Screaming Snake Conversions

    @Test("Transcoding: Transformation workflows from pure camelCase onto SCREAMING_SNAKE formats")
    func testCamelCaseToScreamingSnake() {
        #expect("maxRetryCount".camelCaseTo_SCREAMING_SNAKE == "MAX_RETRY_COUNT")
        #expect("authTokenExpiration".camelCaseTo_SCREAMING_SNAKE == "AUTH_TOKEN_EXPIRATION")

        // Validation of numeric boundaries: numbers attached to uppercase characters stay cohesive
        #expect("version2Block".camelCaseTo_SCREAMING_SNAKE == "VERSION_2BLOCK")
        #expect("testV2block".camelCaseTo_SCREAMING_SNAKE == "TEST_V2BLOCK")
        #expect("testV2Block".camelCaseTo_SCREAMING_SNAKE == "TEST_V2BLOCK")
    }

}
