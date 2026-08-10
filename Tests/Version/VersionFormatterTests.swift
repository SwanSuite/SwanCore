//
//  VersionFormatterTests.swift
//  SwanCoreTests
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Equatable Conformance for Validation Errors

extension VersionFormatter.ValidationError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.unbalancedBrackets, .unbalancedBrackets):
            return true
        case (.invalidToken(let lToken), .invalidToken(let rToken)):
            return lToken == rToken
        default:
            return false
        }
    }
}

// MARK: - Mock Provider Infrastructure

private struct MockProvider: VersionComponentProvider {
    let storage: [String: String]

    func value(for token: String) -> VersionComponent? {
        return storage[token]
    }
}

// MARK: - Suite 1: Syntax and Base Rendering

@Suite("VersionFormatter Syntax and Base Rendering Tests")
struct VersionFormatterTests {

    @Test("Verify template compilation success and strict validation exceptions")
    func templateCompilationAndValidation() {
        // Valid structural pattern strings should compile smoothly
        #expect(throws: Never.self) { try VersionFormatter(format: "%MJ.%MN.%P") }
        #expect(throws: Never.self) { try VersionFormatter(format: "v%MJ[.%MN][-%SI]") }
        #expect(throws: Never.self) { try VersionFormatter(format: "[%SI|%SV]") }

        // Invalid: Unbalanced or orphaned square brackets
        #expect(throws: VersionFormatter.ValidationError.unbalancedBrackets) {
            try VersionFormatter(format: "v%MJ[.%MN")
        }
        #expect(throws: VersionFormatter.ValidationError.unbalancedBrackets) {
            try VersionFormatter(format: "v%MJ.%MN]")
        }

        // Invalid: Empty percent token marker indicator sequence
        #expect(throws: VersionFormatter.ValidationError.invalidToken("%")) {
            try VersionFormatter(format: "version %")
        }
    }

    @Test("Verify flat root-level formatting and default zero fallbacks")
    func flatRootLevelFormatting() throws {
        let provider = MockProvider(storage: ["MJ": "1", "MN": "2"])

        let formatter1 = try VersionFormatter(format: "%MJ.%MN")
        #expect(formatter1.string(from: provider) == "1.2")

        let formatter2 = try VersionFormatter(format: "%MJ.%MN.%P")
        #expect(formatter2.string(from: provider) == "1.2.0")
    }
}

// MARK: - Suite 2: Hierarchical Rules and Selection Logic

@Suite("VersionFormatter Hierarchical Rules and Selection Logic")
struct VersionFormatterLogicTests {

    // MARK: - Hierarchical Brackets (AND/OR) Tests

    @Test("Verify custom hierarchical rules (AND/OR) for nested brackets")
    func nestedBracketsLogic() throws {
        // Case 1: Active single-token anchor on current level (%MN). Value exists -> block is operational.
        let provider1 = MockProvider(storage: ["MJ": "1", "MN": "0"]) // patch is nil
        let formatter1 = try VersionFormatter(format: "v%MJ[.%MN[.%P]]")
        #expect(formatter1.string(from: provider1) == "v1.0")

        // Case 2: Level anchor (%MN) is missing -> entire optional root block is instantly pruned,
        // despite the fact that nested child property (%P) actively exists.
        let provider2 = MockProvider(storage: ["MJ": "1", "P": "3"]) // minor is nil
        #expect(formatter1.string(from: provider2) == "v1")

        // Case 3: Multiple immediate layout tokens on active layer (%SI and %SV). Triggers ALL (AND) Strategy.
        // Both tokens exist -> entire group boundary renders seamlessly.
        let provider3 = MockProvider(storage: ["MJ": "1", "MN": "2", "P": "3", "SI": "rc", "SV": "1"])
        let formatter2 = try VersionFormatter(format: "%MJ.%MN.%P[[- %SI].%SV]")
        #expect(formatter2.string(from: provider3) == "1.2.3- rc.1")

        // Case 4: Triggers ALL (AND) Strategy. One immediate flat token (%SV) is completely missing ->
        // parent group node is wiped out to prevent trailing/orphaned delimiters.
        let provider4 = MockProvider(storage: ["MJ": "1", "MN": "2", "P": "3", "SI": "rc"]) // SV is nil
        #expect(formatter2.string(from: provider4) == "1.2.3")
    }

    // MARK: - Mutually Exclusive Selection (Select/Pipe) Tests

    @Test("Verify strict One-Hot alternative selection via structural pipe operator")
    func selectPipeLogic() throws {
        // Alternative setup template: renders branch A (prerelease) OR branch B (technical build suffix)
        let formatter = try VersionFormatter(format: "%MJ.%MN[.%P][[-%SI[.%SV]]|[ b%B]]")

        // Case A: Prerelease metadata exists -> leftmost choice branch activates cleanly
        let providerA = MockProvider(storage: ["MJ": "1", "MN": "0", "SI": "rc", "SV": "1"])
        #expect(formatter.string(from: providerA) == "1.0-rc.1")

        // Case B: Technical compilation identifier exists -> rightmost choice branch activates cleanly
        let providerB = MockProvider(storage: ["MJ": "1", "MN": "0", "B": "12"])
        #expect(formatter.string(from: providerB) == "1.0 b12")

        // Case C: Conflict validation! Both branches evaluate to active state ->
        // One-Hot strict layout constraints fail, collapsing entire .select node safely to empty stream.
        let providerC = MockProvider(storage: ["MJ": "1", "MN": "0", "SI": "rc", "SV": "1", "B": "12"])
        #expect(formatter.string(from: providerC) == "1.0")

        // Case D: Completely empty metadata fields -> zero branches active, node collapses safely
        let providerD = MockProvider(storage: ["MJ": "1", "MN": "0"])
        #expect(formatter.string(from: providerD) == "1.0")
    }
}
