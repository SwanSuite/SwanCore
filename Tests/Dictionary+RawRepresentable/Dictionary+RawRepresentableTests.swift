//
//  Dictionary+RawRepresentableTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Mock Enums for Testing

private enum MockKey: String {
    case id = "id_field"
    case status = "status_field"
    case role = "role_field"
}

private enum MockTargetKey: String {
    case id = "id_field"
    case status = "status_field"
}

private enum MockValue: Int {
    case pending = 0
    case active = 1
    case suspended = 2
}

private enum MockTargetValue: Int {
    case pending = 0
    case active = 1
}

// MARK: - Test Suite

@Suite("Dictionary RawRepresentable Transformations Validation Suite")
struct DictionaryRawRepresentableTests {

    // MARK: - 1. Key: RawRepresentable Extensions

    @Test("Dictionary: Convert from [EnumKey: Value] to [RawKey: Value]")
    func testResolveRepresentationKeyToRaw() {
        let dict: [MockKey: String] = [.id: "123", .status: "OK"]
        let resolved: [String: String] = dict.resolveRepresentation()

        #expect(resolved["id_field"] == "123")
        #expect(resolved["status_field"] == "OK")
    }

    @Test("Dictionary: Convert from [EnumKey: RawValue] to [RawKey: TargetedEnumValue] with type reconstruction")
    func testResolveRepresentationKeyToRawValueToEnum() {
        let dict: [MockKey: Int] = [.id: 1, .status: 99] // 99 is invalid for MockTargetValue
        let resolved: [String: MockTargetValue] = dict.resolveRepresentation()

        #expect(resolved["id_field"] == .active)
        #expect(resolved["status_field"] == nil) // Pruned due to invalid raw value
    }

    // MARK: - 2. Optional Values Processing

    @Test("Dictionary: Convert from [EnumKey: Value?] to [RawKey: Value] removing nils")
    func testResolveRepresentationOptionalValuePruning() {
        let dict: [MockKey: String?] = [.id: "123", .status: nil, .role: "Admin"]
        let resolved: [String: String] = dict.resolveRepresentation()

        #expect(resolved["id_field"] == "123")
        #expect(resolved["status_field"] == nil)
        #expect(resolved["role_field"] == "Admin")
    }

    @Test("Dictionary: Convert from [EnumKey: EnumValue?] to [RawKey: RawValue] removing nils")
    func testResolveRepresentationOptionalEnumValueToRawPruning() {
        let dict: [MockKey: MockValue?] = [.id: .active, .status: nil, .role: .suspended]
        let resolved: [String: Int] = dict.resolveRepresentation()

        #expect(resolved["id_field"] == 1)
        #expect(resolved["status_field"] == nil)
        #expect(resolved["role_field"] == 2)
    }

    @Test("Dictionary: Convert from [EnumKey: RawValue?] to [RawKey: TargetedEnumValue] reconstruction and pruning")
    func testResolveRepresentationOptionalRawValueToEnumPruning() {
        let dict: [MockKey: Int?] = [.id: 1, .status: nil, .role: 99]
        let resolved: [String: MockTargetValue] = dict.resolveRepresentation()

        #expect(resolved["id_field"] == .active)
        #expect(resolved["status_field"] == nil) // Nil value pruned
        #expect(resolved["role_field"] == nil)   // Invalid raw value 99 pruned
    }

    // MARK: - 3. Value: RawRepresentable Extensions

    @Test("Dictionary: Convert from [Key: EnumValue] to [Key: RawValue]")
    func testResolveRepresentationValueToRaw() {
        let dict: [String: MockValue] = ["user1": .active, "user2": .suspended]
        let resolved: [String: Int] = dict.resolveRepresentation()

        #expect(resolved["user1"] == 1)
        #expect(resolved["user2"] == 2)
    }

    @Test("Dictionary: Convert from [RawKey: EnumValue] to [TargetedEnumKey: RawValue] with initialization sweep")
    func testResolveRepresentationRawKeyToEnumAndValueToRaw() {
        let dict: [String: MockValue] = ["id_field": .active, "invalid_key": .pending]
        let resolved: [MockTargetKey: Int] = dict.resolveRepresentation()

        #expect(resolved[.id] == 1)
        #expect(resolved[.status] == nil)
        #expect(resolved.count == 1) // "invalid_key" failed to map to MockTargetKey and is removed
    }

    // MARK: - 4. Dual Component Mapping (Key: RawRepresentable, Value: RawRepresentable)

    @Test("Dictionary: Convert from [EnumKey: EnumValue] to [RawKey: RawValue]")
    func testResolveRepresentationBothEnumToRaw() {
        let dict: [MockKey: MockValue] = [.id: .active, .status: .pending]
        let resolved: [String: Int] = dict.resolveRepresentation()

        #expect(resolved["id_field"] == 1)
        #expect(resolved["status_field"] == 0)
    }

    // MARK: - 5. Standard Primitive Dictionary Extensions

    @Test("Dictionary: Reconstruct raw keys into [TargetedEnumKey: Value]")
    func testResolveRepresentationRawKeyToTargetedEnum() {
        let dict: [String: Int] = ["id_field": 10, "unknown_field": 20]
        let resolved: [MockTargetKey: Int] = dict.resolveRepresentation()

        #expect(resolved[.id] == 10)
        #expect(resolved.count == 1) // "unknown_field" safely discarded
    }

    @Test("Dictionary: Reconstruct raw values into [Key: TargetedEnumValue]")
    func testResolveRepresentationRawValueToTargetedEnum() {
        let dict: [String: Int] = ["item1": 1, "item2": 99]
        let resolved: [String: MockTargetValue] = dict.resolveRepresentation()

        #expect(resolved["item1"] == .active)
        #expect(resolved["item2"] == nil) // 99 is discarded
    }

    @Test("Dictionary: Reconstruct both raw components into [TargetedEnumKey: TargetedEnumValue]")
    func testResolveRepresentationBothRawToEnum() {
        let dict: [String: Int] = ["id_field": 1, "status_field": 99, "invalid_field": 0]
        let resolved: [MockTargetKey: MockTargetValue] = dict.resolveRepresentation()

        #expect(resolved[.id] == .active)
        #expect(resolved[.status] == nil) // 99 fails value resolution, pair discarded
        #expect(resolved.count == 1)       // Only fully resolved pairs survive
    }
}
