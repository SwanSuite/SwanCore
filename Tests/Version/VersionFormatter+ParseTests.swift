//
//  VersionFormatter+ParseTests.swift
//  SwanCoreTests
//
//  Created by Stanislav Pletnev on 2026-08-11.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("VersionFormatter Mirror Parsing and Token Composition Logic")
struct VersionFormatterParseTests {

    // MARK: - Core Scanner Matrix Verification

    @Test("Scanner: Standard linear schema sequence extraction validation")
    func testStandardBlueprintScanning() throws {
        let formatter = try VersionFormatter(format: "%MJ.%MN.%P")

        // Exact matching structure
        let tokens = try #require(formatter.parse("1.2.3"))
        #expect(tokens["MJ"] == "1")
        #expect(tokens["MN"] == "2")
        #expect(tokens["P"] == "3")

        // Error case: Missing text delimiter constraint (.) triggers parsing failure
        #expect(formatter.parse("1-2-3") == nil)

        // Error case: Trailing garbage symbols block clean termination check
        #expect(formatter.parse("1.2.3-garbage") == nil)
    }

    @Test("Scanner: Optional nesting block context rollback behavior validation")
    func testOptionalBlockRollbackScenarios() throws {
        let formatter = try VersionFormatter(format: "v%MJ[.%MN[.%P]]")

        // Case A: Pure root layout with all optional components missing
        let tokensA = try #require(formatter.parse("v1"))
        #expect(tokensA["MJ"] == "1")
        #expect(tokensA["MN"] == nil)

        // Case B: Partially filled sequence matching intermediate nesting filters
        let tokensB = try #require(formatter.parse("v1.2"))
        #expect(tokensB["MJ"] == "1")
        #expect(tokensB["MN"] == "2")
        #expect(tokensB["P"] == nil)

        // Case C: Fully realized tree layout matches perfectly
        let tokensC = try #require(formatter.parse("v1.2.3"))
        #expect(tokensC["MJ"] == "1")
        #expect(tokensC["MN"] == "2")
        #expect(tokensC["P"] == "3")

        // Case D: Incomplete nested structure (dot present but number missing) triggers safe rollback
        #expect(formatter.parse("v1.2.") == nil)
    }

    // MARK: - Mutually Exclusive Selection (Pipe) Parsing

    @Test("Scanner: Strict One-Hot alternative select branch prioritization validation")
    func testSelectBranchParsing() throws {
        // Renders either branch A (prerelease) OR branch B (technical build suffix)
        let formatter = try VersionFormatter(format: "%MJ.%MN[.%P][[-%SI[.%SV]]|[ b%B]]")

        // Match Left Branch (Prerelease)
        let tokensLeft = try #require(formatter.parse("1.0-rc.2"))
        #expect(tokensLeft["MJ"] == "1")
        #expect(tokensLeft["MN"] == "0")
        #expect(tokensLeft["SI"] == "rc")
        #expect(tokensLeft["SV"] == "2")
        #expect(tokensLeft["B"] == nil)

        // Match Right Branch (Build Suffix)
        let tokensRight = try #require(formatter.parse("1.0 b145"))
        #expect(tokensRight["MJ"] == "1")
        #expect(tokensRight["MN"] == "0")
        #expect(tokensRight["SI"] == nil)
        #expect(tokensRight["B"] == "145")
    }

    // MARK: - Core Lossless Model Initialization via TokensComposable

    @Test("Model: Full serialization loop using default framework medium presets")
    func testLosslessStringInitializationLoop() throws {
        // Complete structural initialization loop verification
        let versionString = "1.2.0-beta.3"
        let version = try #require(CanonicalVersion(versionString))

        #expect(version.major == 1)
        #expect(version.minor == 2)
        #expect(version.patch == 0)
        #expect(version.stage?.identifier == .beta)
        #expect(version.stage?.version == 3)
        #expect(version.stage?.build == nil)

        // Garbage string input pruning validation
        let invalidVersion = CanonicalVersion("garbage_text_framework")
        #expect(invalidVersion == nil)
    }
}
