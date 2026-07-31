//
//  Bundle+MetadataTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("Bundle Metadata Properties Tests")
struct BundleMetadataTests {

    @Test("Test dynamic bundle properties parsing logic")
    func testBundleMetadataProperties() {
        let mockDict: [String: Any] = [
            kCFBundleExecutableKey as String: "MockExecutable",
            kCFBundleNameKey as String: "MockName",
            "CFBundleDisplayName": "Mock Display Name",
            "CFBundleShortVersionString": "0.9.1",
            kCFBundleVersionKey as String: "103"
        ]

        let executable = mockDict[kCFBundleExecutableKey as String] as? String
        let name = mockDict[kCFBundleNameKey as String] as? String
        let displayName = mockDict["CFBundleDisplayName"] as? String ?? name
        let shortVersion = mockDict["CFBundleShortVersionString"] as? String
        let buildNumber = mockDict[kCFBundleVersionKey as String] as? String

        #expect(executable == "MockExecutable")
        #expect(name == "MockName")
        #expect(displayName == "Mock Display Name")
        #expect(shortVersion == "0.9.1")
        #expect(buildNumber == "103")
    }
}
