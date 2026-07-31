//
//  VersionTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("Version Framework Core Component Validation Suite")
struct VersionTests {

    // MARK: - Core Parser Functional Validation

    @Test("Parser: Standard structured semantic string resolution validation")
    func testStandardParsing() throws {
        let v1 = try #require(Version.parse("1.2.3"))
        #expect(v1.major == 1)
        #expect(v1.minor == 2)
        #expect(v1.patch == 3)
        #expect(v1.preReleaseIdentifier == .release)
        #expect(v1.preReleaseVersion == nil)
        #expect(v1.build == nil)

        let v2 = try #require(Version.parse("0.1.0-alpha.5"))
        #expect(v2.major == 0)
        #expect(v2.minor == 1)
        #expect(v2.patch == 0)
        #expect(v2.preReleaseIdentifier == .alpha)
        #expect(v2.preReleaseVersion == 5)
    }

    @Test("Parser: Flat branding layout and structural metadata compilation validation")
    func testComplexAndFlatParsing() throws {
        let v1 = try #require(Version.parse("v1.2-rc3+b45"))
        #expect(v1.major == 1)
        #expect(v1.minor == 2)
        #expect(v1.patch == nil)
        #expect(v1.preReleaseIdentifier == .releaseCandidate)
        #expect(v1.preReleaseVersion == 3)
        #expect(v1.build == 45)

        let v2 = try #require(Version.parse("version 2.0 (build 99)"))
        #expect(v2.major == 2)
        #expect(v2.minor == 0)
        #expect(v2.patch == nil)
        #expect(v2.preReleaseIdentifier == .release)
        #expect(v2.build == 99)
    }

    @Test("Parser: Initialization and garbage input pruning via LosslessStringConvertible")
    func testLosslessStringInitialization() {
        let version = Version("3.1.4-beta2")
        #expect(version?.major == 3)
        #expect(version?.minor == 1)
        #expect(version?.patch == 4)
        #expect(version?.preReleaseIdentifier == .beta)
        #expect(version?.preReleaseVersion == 2)

        let invalidVersion = Version("not_a_version")
        #expect(invalidVersion == nil)
    }

    // MARK: - Structural Comparison & Equatable Cascades

    @Test("Comparison: Comprehensive component hierarchy evaluation using the default empty unwrap operator")
    func testVersionComparisonCascade() {
        let v1_2 = Version(major: 1, minor: 2)
        let v1_2_0 = Version(major: 1, minor: 2, patch: 0)
        let v1_5 = Version(major: 1, minor: 5)
        let v2_0 = Version(major: 2, minor: 0)

        #expect(v1_2 == v1_2_0)
        #expect(!(v1_2 < v1_2_0))

        #expect(v1_2 < v1_5)
        #expect(v1_5 < v2_0)
        #expect(v1_2 < v2_0)
    }

    @Test("Comparison: Validation of missing or optional structural fields handled via native primitives")
    func testNilComponentsComparison() {
        let v1 = Version(major: 1, minor: 1, patch: 1, preReleaseIdentifier: .release, preReleaseVersion: nil, build: 5)
        let v2 = Version(major: 1, minor: 1, patch: 1, preReleaseIdentifier: .release, preReleaseVersion: nil, build: nil)

        #expect(v2 < v1)
        #expect(!(v1 < v2))

        let betaStandalone = Version(major: 1, preReleaseIdentifier: .beta, preReleaseVersion: nil)
        let beta2 = Version(major: 1, preReleaseIdentifier: .beta, preReleaseVersion: 2)

        #expect(betaStandalone < beta2)
    }

    @Test("Comparison: Timeline weights and software lifecycle iteration validation")
    func testPreReleaseComparison() {
        let alpha = Version(major: 1, preReleaseIdentifier: .alpha, preReleaseVersion: 5)
        let rc = Version(major: 1, preReleaseIdentifier: .releaseCandidate, preReleaseVersion: 1)
        let release = Version(major: 1, preReleaseIdentifier: .release)

        #expect(alpha < rc)
        #expect(rc < release)

        #expect(Version(major: 1, minor: 0, patch: 0, preReleaseIdentifier: .releaseCandidate, preReleaseVersion: 99) < Version(major: 1, minor: 0, patch: 0))
    }
}
