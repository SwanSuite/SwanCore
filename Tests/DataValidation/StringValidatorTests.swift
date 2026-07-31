//
//  StringValidatorTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("Atomic String Validators Architectural Suite")
struct StringValidatorTests {

    // MARK: - 1. Email Validator Strategy Verification

    @Test("EmailValidator: Structural processing of email handles")
    func testEmailValidatorStrategy() throws {
        let validator = try EmailValidator()

        // Assert valid formatting rules
        #expect(validator.validate("developer@swankit.io") == true)

        // Assert malformed formatting boundaries
        #expect(validator.validate("invalid_email_handle") == false)
        #expect(validator.validate("developer@swankit.io trailing_text") == false)
    }

    // MARK: - 2. Phone Validator Strategy Verification

    @Test("PhoneNumberValidator: Structural processing of international telephone layouts")
    func testPhoneNumberValidatorStrategy() throws {
        let validator = try PhoneNumberValidator()

        // Assert valid formatting rules
        #expect(validator.validate("+1234567890") == true)

        // Assert malformed formatting boundaries
        #expect(validator.validate("pure_alphabetical_junk") == false)
        #expect(validator.validate("+1234567890 text_injection") == false)
    }

    // MARK: - 3. Link Validator Strategy Verification

    @Test("LinkValidator: Structural evaluation of hyperlink paths and protocol constraints")
    func testLinkValidatorStrategy() throws {
        let openValidator = try LinkValidator()
        let httpsValidator = try LinkValidator(scheme: "https")

        // Assert open constraints mapping
        #expect(openValidator.validate("https://anobisoft.com") == true)
        #expect(openValidator.validate("http://anobisoft.com") == true)

        // Assert explicit scheme filter boundaries
        #expect(httpsValidator.validate("https://anobisoft.com") == true)
        #expect(httpsValidator.validate("http://anobisoft.com") == false)
        #expect(openValidator.validate("completely_corrupted_link") == false)
    }

    // MARK: - 4. Hashable Strategy Verification

    @Test("Validator: Hashable conformance and custom identifier evaluation")
    func testValidatorHashableConformance() throws {
        let idToken = "custom_email_input_id"
        let v1 = try EmailValidator(id: idToken)
        let v2 = try EmailValidator(id: idToken)
        let v3 = try EmailValidator() // Generates randomized default uuidString

        // Assert programmatic equality constraints based on ID mapping token matches
        #expect(v1 == v2)
        #expect(v1 != v3)

        // Verify key capability routing within dictionary structures
        var trackingDict: [AnyHashable: Bool] = [:]
        trackingDict[v1] = true

        #expect(trackingDict[v2] == true)
        #expect(trackingDict[v3] == nil)
    }
}
