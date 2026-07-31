//
//  Dictionary+RawRepresentable+OptionalTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Mock Enums for Optional Testing

private enum MockOptionalKey: String {
    case id = "id_field"
    case session = "session_field"
    case context = "context_field"
}

private enum MockOptionalValue: Int {
    case disabled = 0
    case enabled = 1
}

private enum MockTargetOptionalValue: Int {
    case disabled = 0
    case enabled = 1
}

// MARK: - Test Suite

@Suite("Dictionary Optional RawRepresentable Transformations Validation Suite")
struct DictionaryRawRepresentableOptionalTests {

    // MARK: - 1. Standard Value Optional Pruning

    @Test("Dictionary: Convert from [Key: Value?] to [Key: Value] discarding nils")
    func testResolveRepresentationStripNils() {
        let dict: [String: Int?] = ["key1": 10, "key2": nil, "key3": 30]
        let resolved: [String: Int] = dict.resolveRepresentation()

        #expect(resolved["key1"] == 10)
        #expect(resolved["key2"] == nil)
        #expect(resolved["key3"] == 30)
        #expect(resolved.count == 2)
    }

    @Test("Dictionary: Convert from [Key: EnumValue?] to [Key: RawValue] discarding nils")
    func testResolveRepresentationOptionalEnumValueToRaw() {
        let dict: [String: MockOptionalValue?] = ["item1": .enabled, "item2": nil, "item3": .disabled]
        let resolved: [String: Int] = dict.resolveRepresentation()

        #expect(resolved["item1"] == 1)
        #expect(resolved["item2"] == nil)
        #expect(resolved["item3"] == 0)
    }

    @Test("Dictionary: Convert from [Key: RawValue?] to [Key: TargetedEnumValue] discarding nils and invalid values")
    func testResolveRepresentationOptionalRawValueToEnum() {
        let dict: [String: Int?] = ["setting1": 1, "setting2": nil, "setting3": 99] // 99 is out of enum scope
        let resolved: [String: MockTargetOptionalValue] = dict.resolveRepresentation()

        #expect(resolved["setting1"] == .enabled)
        #expect(resolved["setting2"] == nil)
        #expect(resolved["setting3"] == nil)
        #expect(resolved.count == 1)
    }

    // MARK: - 2. Key Reconstruction with Optional Values

    @Test("Dictionary: Convert from [RawKey: Value?] to [TargetedEnumKey: Value] discarding nils and invalid keys")
    func testResolveRepresentationRawKeyToEnumWithOptionalValue() {
        let dict: [String: String?] = ["id_field": "valid", "session_field": nil, "unknown_field": "discard"]
        let resolved: [MockOptionalKey: String] = dict.resolveRepresentation()

        #expect(resolved[.id] == "valid")
        #expect(resolved[.session] == nil)
        #expect(resolved.count == 1) // Only valid keys with non-nil values survive
    }

    @Test("Dictionary: Convert from [RawKey: EnumValue?] to [TargetedEnumKey: RawValue] sweeping complex nodes")
    func testResolveRepresentationRawKeyToEnumAndOptionalEnumValueToRaw() {
        let dict: [String: MockOptionalValue?] = ["id_field": .enabled, "session_field": nil, "unknown_field": .disabled]
        let resolved: [MockOptionalKey: Int] = dict.resolveRepresentation()

        #expect(resolved[.id] == 1)
        #expect(resolved[.session] == nil)
        #expect(resolved.count == 1)
    }

    @Test("Dictionary: Convert from [RawKey: RawValue?] to [TargetedEnumKey: TargetedEnumValue] with total mapping sweep")
    func testResolveRepresentationRawKeyToEnumAndOptionalRawValueToEnum() {
        let dict: [String: Int?] = [
            "id_field": 1,
            "session_field": nil,
            "context_field": 99, // Invalid value
            "unknown_field": 0   // Invalid key mapping context
        ]
        let resolved: [MockOptionalKey: MockTargetOptionalValue] = dict.resolveRepresentation()

        #expect(resolved[.id] == .enabled)
        #expect(resolved[.session] == nil)
        #expect(resolved[.context] == nil)
        #expect(resolved.count == 1)
    }
}
