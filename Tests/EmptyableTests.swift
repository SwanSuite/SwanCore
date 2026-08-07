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

    @Test("Test Numeric and FloatingPoint automation rules")
    func testNumericAndFloatingPointEmptiness() {
        // Проверка целых чисел (BinaryInteger)
        let zeroInt = 0
        let activeInt = -10
        #expect(zeroInt.isEmpty == true)
        #expect(activeInt.isEmpty == false)
        #expect(zeroInt ~? activeInt == -10)

        // Проверка чисел с плавающей точкой (FloatingPoint/CGFloat)
        let zeroDouble: Double = 0.0
        let validDouble: Double = 3.14
        #expect(zeroDouble.isEmpty == true)
        #expect(validDouble.isEmpty == false)
        #expect(zeroDouble ~? validDouble == 3.14)

        let nilFloat: Float? = nil
        #expect(nilFloat~! == 0.0)
    }

    @Test("Test 128-bit Integer registrations if available")
    func testLargeIntegersEmptiness() {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, *) {
            let zeroInt128 = Int128.zero
            let validInt128 = Int128(1000)
            #expect(zeroInt128.isEmpty == true)
            #expect(zeroInt128 ~? validInt128 == 1000)
        }
    }

    @Test("Test CoreGraphics geometric structures emptiness")
    func testCoreGraphicsStructuresEmptiness() {
        // CGPoint
        let zeroPoint = CGPoint.zero
        let activePoint = CGPoint(x: 1, y: 1)
        #expect(zeroPoint.isEmpty == true)
        #expect(activePoint.isEmpty == false)
        #expect(zeroPoint ~? activePoint == activePoint)

        // CGSize
        let zeroSize = CGSize.zero
        let activeSize = CGSize(width: 10, height: 20)
        #expect(zeroSize.isEmpty == true)
        #expect(zeroSize ~? activeSize == activeSize)
    }

    @Test("Test CoreGraphics CGRect optical emptiness rules")
    func testCGRectOpticalEmptiness() {
        let zeroRect: CGRect? = nil
        #expect(zeroRect~! == .zero)

        // CGRect пустой, так как ширина равна 0
        let edgeCaseRect = CGRect(x: 10, y: 10, width: 0, height: 100)
        let fallbackedRect = edgeCaseRect ~? CGRect(x: 0, y: 0, width: 5, height: 5)
        #expect(fallbackedRect.width == 5)
        #expect(fallbackedRect.height == 5)
    }
}
