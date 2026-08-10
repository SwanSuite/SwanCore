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

    // MARK: - Structural Comparison & Equatable Cascades

    @Test("Comparison: Comprehensive component hierarchy evaluation using the default empty unwrap operator")
    func testVersionComparisonCascade() {
        let v1_2 = CanonicalVersion(major: 1, minor: 2)
        let v1_2_0 = CanonicalVersion(major: 1, minor: 2, patch: 0)
        let v1_5 = CanonicalVersion(major: 1, minor: 5)
        let v2_0 = CanonicalVersion(major: 2, minor: 0)

        // Verifies Equatable logic handles structural nil-coalescing identical footprints (2.0 vs 2.0.0)
        #expect(v1_2 == v1_2_0)
        #expect(!(v1_2 < v1_2_0))

        // Verifies linear major/minor step progression priority sequence weight overrides
        #expect(v1_2 < v1_5)
        #expect(v1_5 < v2_0)
        #expect(v1_2 < v2_0)
    }

    @Test("Comparison: Validation of missing or optional structural fields handled via native primitives")
    func testNilComponentsComparison() {
        let stage1 = CanonicalVersionStage(identifier: .release, version: nil, build: 5)
        let stage2 = CanonicalVersionStage(identifier: .release, version: nil, build: nil)

        let v1 = CanonicalVersion(major: 1, minor: 1, patch: 1, stage: stage1)
        let v2 = CanonicalVersion(major: 1, minor: 1, patch: 1, stage: stage2)

        // Low-level technical build incremental comparison logic verification
        #expect(v2 < v1)
        #expect(!(v1 < v2))

        let stageBetaStandalone = CanonicalVersionStage(identifier: .beta, version: nil)
        let stageBeta2 = CanonicalVersionStage(identifier: .beta, version: 2)

        let betaStandalone = CanonicalVersion(major: 1, stage: stageBetaStandalone)
        let beta2 = CanonicalVersion(major: 1, stage: stageBeta2)

        // Stage numerical iteration lifecycle sequence verification (beta1 < beta2)
        #expect(betaStandalone < beta2)
    }

    @Test("Comparison: Timeline weights and software lifecycle iteration validation")
    func testPreReleaseComparison() {
        let stageAlpha = CanonicalVersionStage(identifier: .alpha, version: 5)
        let stageRC = CanonicalVersionStage(identifier: .releaseCandidate, version: 1)
        let stageRelease = CanonicalVersionStage(identifier: .release)

        let alpha = CanonicalVersion(major: 1, stage: stageAlpha)
        let rc = CanonicalVersion(major: 1, stage: stageRC)
        let release = CanonicalVersion(major: 1, stage: stageRelease)

        // Milestone priority cascade sorting weight validation (alpha < rc < release)
        #expect(alpha < rc)
        #expect(rc < release)

        // Optional prerelease tags always mathematically precede production states
        let standaloneRC = CanonicalVersionStage(identifier: .releaseCandidate, version: 99)
        #expect(CanonicalVersion(major: 1, minor: 0, patch: 0, stage: standaloneRC) < CanonicalVersion(major: 1, minor: 0, patch: 0))
    }
}
