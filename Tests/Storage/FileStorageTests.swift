//
//  FileStorageTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// MARK: - Spy FileManager Implementation

/// A precise subclass spy designed to intercept internal execution calls from FileManager.
private final class SpyFileManager: FileManager, @unchecked Sendable {

    var createDirectoryCallCount = 0
    var removeItemCallCount = 0
    var contentsCallCount = 0

    var lastCreatedURL: URL?
    var lastRemovedURL: URL?
    var lastRequestedPath: String?

    // Stubbed data bytes to return on contents request
    var stubbedContentsData: Data?

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        // Return a stable mock base path directory for verification testing
        return [URL(fileURLWithPath: "/tmp/mock_sandbox_dir")]
    }

    override func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        createDirectoryCallCount += 1
        lastCreatedURL = url
    }

    override func removeItem(at URL: URL) throws {
        removeItemCallCount += 1
        lastRemovedURL = URL
    }

    override func contents(atPath path: String) -> Data? {
        contentsCallCount += 1
        lastRequestedPath = path
        return stubbedContentsData
    }
}

// MARK: - Test Suite

@Suite("FileStorage Injected Spy Specifications Suite")
struct FileStorageTests {

    private var spyManager: SpyFileManager
    private var storage: FileStorage

    /// Modern replacement for XCTest 'setUp()'.
    /// Allocates completely clean, isolated spy environments per atomic test run.
    init() throws {
        let freshSpy = SpyFileManager()
        self.spyManager = freshSpy
        // Inject the spy instance explicitly into the storage structure framework
        self.storage = try FileStorage(.cachesDirectory, path: "SubsystemNode", fileManager: freshSpy)
    }

    // MARK: - 1. Initialization Boundaries Verification

    @Test("FileStorage: Verify that initialization immediately enforces directory tree creation")
    func testInitializationCreatesDirectory() {
        // Assert initial creation sequence triggers upon instance allocation
        #expect(spyManager.createDirectoryCallCount == 1)
        #expect(spyManager.lastCreatedURL?.path == "/tmp/mock_sandbox_dir/SubsystemNode")
    }

    // MARK: - 2. Data Retrieval Verification

    @Test("FileStorage: Verify data(forKey:) maps path strings and extracts contents correctly")
    func testDataRetrievalContract() throws {
        let targetKey = "configuration.plist"
        let stubbedBytes = try #require("mock_binary_stream".data(using: .utf8))
        spyManager.stubbedContentsData = stubbedBytes

        // Act
        let recoveredData = storage.data(forKey: targetKey)

        // Assert
        #expect(spyManager.contentsCallCount == 1)
        #expect(spyManager.lastRequestedPath == "/tmp/mock_sandbox_dir/SubsystemNode/configuration.plist")
        #expect(recoveredData == stubbedBytes)

        #expect(spyManager.removeItemCallCount == 0)
    }

    // MARK: - 3. Item Removal Verification

    @Test("FileStorage: Verify removeObject(forKey:) targets correct file URL references")
    func testRemoveObjectContract() throws {
        let targetKey = "volatile_token.tmp"

        // Act
        try storage.removeObject(forKey: targetKey)

        // Assert
        #expect(spyManager.removeItemCallCount == 1)
        #expect(spyManager.lastRemovedURL?.path == "/tmp/mock_sandbox_dir/SubsystemNode/volatile_token.tmp")

        #expect(spyManager.contentsCallCount == 0)
    }
}
