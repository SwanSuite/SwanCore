//
//  PersistentStorageTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Honest Minimalist Mock Storage

private final class HonestMockStorage: PersistentStorage, @unchecked Sendable {
    private var memoryStore: [String: Data] = [:]
    private let lock = NSLock()

    // Concrete implementations required by the protocol blueprint
    func data(forKey key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return memoryStore[key]
    }

    func save(_ data: Data, forKey key: String) throws {
        lock.lock()
        memoryStore[key] = data
        lock.unlock()
    }

    func removeObject(forKey key: String) {
        lock.lock()
        memoryStore.removeValue(forKey: key)
        lock.unlock()
    }
}

// MARK: - Mock Codable Entity

private struct MockProfile: Codable, Equatable {
    let username: String
    let theme: String
}

// MARK: - Test Suite

@Suite("PersistentStorage Extensions Operational Suite")
struct PersistentStorageTests {

    // MARK: - 1. Standard Codable Integration Loop

    @Test("PersistentStorage: Encoding and decoding of standard Codable structures using default JSON engine")
    func testCodableSerializationLifecycle() throws {
        let storage = HonestMockStorage()
        let profile = MockProfile(username: "stan_p", theme: "system_dark")
        let key = "user_settings_key"

        // Assert initial blank state
        let initialLoad: MockProfile? = try storage.retrieveObject(forKey: key)
        #expect(initialLoad == nil)

        // Store via encodable extension loop
        try storage.store(profile, forKey: key)

        // Retrieve via decodable extension loop
        let loadedProfile: MockProfile? = try storage.retrieveObject(forKey: key)
        let unwrappedProfile = try #require(loadedProfile)

        #expect(unwrappedProfile == profile)
        #expect(unwrappedProfile.username == "stan_p")
        #expect(unwrappedProfile.theme == "system_dark")

        // Verify entry removal
        storage.removeObject(forKey: key)
        #expect(try storage.retrieveObject(forKey: key) as MockProfile? == nil)
    }

    // MARK: - 2. Fluent API Method Chaining Verification

    @Test("PersistentStorage: Fluent instance extensions verification on Encodable and Decodable primitives")
    func testFluentConfigurationAPI() throws {
        let storage = HonestMockStorage()
        let profile = MockProfile(username: "fluent_user", theme: "light")
        let recordId = "profile_101"

        // Execute dynamic descriptive push serialization
        try profile.save(for: recordId, to: storage)

        // Execute declarative type reconstruction extraction loop
        let loaded = try MockProfile.load(id: recordId, from: storage)
        let unwrapped = try #require(loaded)

        #expect(unwrapped == profile)
        #expect(unwrapped.username == "fluent_user")
    }
}
