//
//  StorableTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Test Mocks

/// A reference-type wrapper to track method execution counts.
/// Used to safely mutate counters across immutable structures within Swift 6 Concurrency domains.
final class CallCounter: @unchecked Sendable {
    var serializeCount = 0
}

/// A standard model for verifying basic composite key generation and Codable integration.
struct TestUser: Storable, Codable {
    let id: String
    let name: String

    // Conforms to Storable requirements explicitly for clear testing boundaries.
    var dataCache: Data? { nil }
}

/// A nested model configuration to evaluate deep namespace resolution.
enum NetworkData {
    struct SessionToken: Storable, Codable {
        let id: String
        let token: String
        var dataCache: Data? { nil }
    }
}

/// A specialized mock model designed to validate data caching mechanics.
struct CachedTestModel: Storable {
    let id: String
    let counter: CallCounter

    // Required by Storable protocol
    var dataCache: Data?

    init(id: String, dataCache: Data? = nil, counter: CallCounter) {
        self.id = id
        self.dataCache = dataCache
        self.counter = counter
    }

    init?(id: String, data: Data) throws {
        self.id = id
        self.dataCache = data
        self.counter = CallCounter()
    }

    func serialize() throws -> Data {
        counter.serializeCount += 1
        return "serialized_data_from_method".data(using: .utf8)!
    }
}

// MARK: - Test Suite

@Suite("Storable Protocol Unit Tests")
struct StorableTests {

    // MARK: Composite Key Lifecycle Tests

    @Test("Verify standard flat composite key structure")
    func testStandardCompositeKey() {
        // Given
        let entityId = "user_99"
        let user = TestUser(id: entityId, name: "Stanislav")

        // When
        let keyFromInstance = user.compositeKey
        let keyFromType = TestUser.compositeKey(entityId)

        // Then
        #expect(keyFromInstance == keyFromType)
        #expect(keyFromInstance.hasSuffix("TestUser.\(entityId)"))

        let parts = keyFromInstance.components(separatedBy: ".")
        #expect(parts.count >= 3, "The generated key must contain at least [Module].[Type].[ID]")
    }

    @Test("Verify deeply nested type namespaces are preserved")
    func testNestedTypeCompositeKey() {
        // Given
        let tokenId = "session_abc123"
        let token = NetworkData.SessionToken(id: tokenId, token: "secret")

        // When
        let key = token.compositeKey

        // Then
        #expect(key.hasSuffix("NetworkData.SessionToken.\(tokenId)"))
    }

    @Test("Verify dynamic compiler artifacts (unknown contexts) are successfully stripped")
    func testDynamicContextFiltering() {
        // Declaring a local struct inside a function forces the Swift compiler to generate
        // reflection metadata like: "SwanKitFoundationTests.(unknown context at $104ae0a4c).LocalModel"
        struct LocalModel: Storable, Codable {
            let id: String
            var dataCache: Data? { nil }
        }

        let localId = "local_42"
        let model = LocalModel(id: localId)

        // When
        let key = model.compositeKey

        // Then
        #expect(!key.contains("unknown context"), "Compiler runtime metadata must be discarded")
        #expect(key.hasSuffix("LocalModel.\(localId)"))
        #expect(!key.contains(".."), "The sanitized key must not contain empty path fragments or double dots")
    }

    // MARK: Data Cache Resolution Tests

    @Test("Invoke serialize() lazily when dataCache is nil")
    func testDataGenerationWhenCacheIsEmpty() throws {
        // Given
        let counter = CallCounter()
        let model = CachedTestModel(id: "test_1", dataCache: nil, counter: counter)

        // When
        let data = try model.data

        // Then
        #expect(data == "serialized_data_from_method".data(using: .utf8)!)
        #expect(counter.serializeCount == 1, "The serialize() fallback method must be called exactly once")
    }

    @Test("Bypass serialize() entirely and resolve data instantly when dataCache is populated")
    func testDataGenerationWhenCacheIsPresent() throws {
        // Given
        let counter = CallCounter()
        let cachedRawData = "cached_data_pre_generated".data(using: .utf8)!
        let model = CachedTestModel(id: "test_2", dataCache: cachedRawData, counter: counter)

        // When
        let data = try model.data

        // Then
        #expect(data == cachedRawData, "The resolved binary data must strictly match the cached contents")
        #expect(counter.serializeCount == 0, "The heavy serialize() method must not be executed when a valid cache exists")
    }
}
