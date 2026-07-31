//
//  EmptyableTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
import CoreGraphics
@testable import SwanCore

@Suite("Emptyable Protocol & Operators Tests")
struct EmptyableTests {

    @Test("Test postfix unwrap operator (~!) for nil and values")
    func testPostfixUnwrapOperator() {
        let nilString: String? = nil
        let validString: String? = "Swan"
        #expect(nilString~! == "")
        #expect(validString~! == "Swan")

        let nilArray: [Int]? = nil
        let validArray: [Int]? = []
        #expect(nilArray~! == [])
        #expect(validArray~! == [])

        let nilInt: Int? = nil
        let validInt: Int? = 42
        #expect(nilInt~! == 0)
        #expect(validInt~! == 42)
    }

    @Test("Test infix empty-coalescing operator (~?) chaining")
    func testInfixEmptyCoalescingOperator() {
        let emptyStr = ""
        let fallbackStr = "Fallback"
        let finalStr = "Final"

        #expect(emptyStr ~? fallbackStr == "Fallback")
        #expect(fallbackStr ~? finalStr == "Fallback")

        let resolved = "" ~? "" ~? "Success" ~? "Ignored"
        #expect(resolved == "Success")
    }

    @Test("Test CoreGraphics CGRect optical emptiness rules")
    func testCGRectOpticalEmptiness() {
        let zeroRect: CGRect? = nil
        #expect(zeroRect~! == .zero)

        let edgeCaseRect = CGRect(x: 10, y: 10, width: 0, height: 100)
        let fallbackedRect = edgeCaseRect ~? CGRect(x: 0, y: 0, width: 5, height: 5)
        #expect(fallbackedRect.width == 5)
        #expect(fallbackedRect.height == 5)
    }
}
