//
//  DataDetectorTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("DataDetector Isolated Structural Suite")
struct DataDetectorTests {

    // MARK: - Core Boundary Evaluation

    @Test("DataDetector: Explicit boundary match isolation constraints")
    func testDataDetectorBoundaryMatching() throws {
        // Enforce try signature matching the throwing initialization contract
        let linkDetector = try DataDetector(types: .link)

        // Assert true for exact full-boundary structural strings
        #expect(linkDetector.matchesFullBoundary(in: "https://google.com") == true)

        // Partial matches must explicitly fail boundary check validation rules
        #expect(linkDetector.matchesFullBoundary(in: "https://google.com stray_text") == false)
    }
}
