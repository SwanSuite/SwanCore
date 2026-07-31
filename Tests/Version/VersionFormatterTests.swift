//
//  VersionFormatterTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("VersionFormatter Isolated Isolation Suite")
struct VersionFormatterTests {

    // MARK: - Predefined Static Formatters Evaluation

    @Test("Formatter: Compilation of standard predefined system style presets")
    func testIsolatedPredefinedFormatters() {
        let v = Version(major: 1, minor: 2, patch: 3, preReleaseIdentifier: .releaseCandidate, preReleaseVersion: 1, build: 45)

        #expect(VersionFormatter.short.string(from: v) == "1.2.3")
        #expect(VersionFormatter.medium.string(from: v) == "v1.2.3-rc1+b45")
        #expect(VersionFormatter.semVer.string(from: v) == "1.2.3-rc.1")
        #expect(VersionFormatter.long.string(from: v) == "version 1.2.3-rc.1 build 45")
        #expect(VersionFormatter.appleBundle.string(from: v) == "1.2.3")
    }

    // MARK: - Optional Bracket Pruning & Fallback Verification

    @Test("Formatter: Comprehensive evaluation of structural nil and empty component pruning")
    func testPruningNilComponents() {
        let vMinimal = Version(major: 2, minor: nil, patch: nil, preReleaseIdentifier: .release, preReleaseVersion: nil, build: nil)

        #expect(VersionFormatter.short.string(from: vMinimal) == "2")
        #expect(VersionFormatter.medium.string(from: vMinimal) == "v2.0")
        #expect(VersionFormatter.appleBundle.string(from: vMinimal) == "2.0.0")

        let vPartial = Version(major: 1, minor: 4, patch: nil)
        #expect(VersionFormatter.appleBundle.string(from: vPartial) == "1.4.0")
        #expect(VersionFormatter.semVer.string(from: vPartial) == "1.4.0")

        let vWithBuildOnly = Version(major: 1, minor: 1, preReleaseIdentifier: .release, build: 99)
        #expect(VersionFormatter.medium.string(from: vWithBuildOnly) == "v1.1+b99")
    }

    // MARK: - Custom Layout & Nested Matching Verification

    @Test("Formatter: Comprehensive validation of custom pattern templates and nested layout structures")
    func testIsolatedCustomLayoutTemplates() {
        let v = Version(major: 4, minor: 2, preReleaseIdentifier: .beta, preReleaseVersion: 7, build: 88)

        let customFormatter1 = VersionFormatter(format: "[RELEASE: [RI] (vRV)]-b%B")
        #expect(customFormatter1.string(from: v) == "RELEASE: beta (v7)-b88")

        let customFormatter2 = VersionFormatter(format: "System core %MJ.%MN.%P (Build %B)")
        #expect(customFormatter2.string(from: v) == "System core 4.2.0 (Build 88)")

        let messyFormatter = VersionFormatter(format: "%MJ.[ - RI - ][ (vRV) ][ + bB ]")
        #expect(messyFormatter.string(from: v) == "4. - beta -  (v7)  + b88 ")

        let commitFormatter = VersionFormatter(format: "%MJ.%MN.%P[ - B]")
        #expect(commitFormatter.string(from: v) == "4.2.0 - 88")
    }

    // MARK: - Extension Proximity Logic Evaluation

    @Test("Helpers: Resolution confirmation of native structure formatted mapping proxies")
    func testExtensionHelperMethods() {
        let v = Version(major: 1, minor: 1, preReleaseIdentifier: .alpha, preReleaseVersion: 3)

        #expect(v.formatted(.short) == "1.1")
        #expect(v.formatted() == "v1.1-alpha3")
    }
}
