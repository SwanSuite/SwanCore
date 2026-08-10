//
//  CanonicalVersionStage.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A comprehensive implementation of the standard Semantic Versioning 2.0.0 lifecycle pipeline stage.
///
/// `CanonicalVersionStage` encapsulates highly structured prerelease metadata tokens—including specific
/// lifecycle phase tags and internal cycle iterations—alongside standard technical compilation build numbers.
public struct CanonicalVersionStage: VersionStage {

    /// Predefined evolutionary development milestones supported natively by the semantic framework stage.
    public enum Identifier: String, Sendable {
        /// Represents an early, potentially unstable development cycle baseline state.
        case alpha
        /// Represents a feature-complete but unstable evaluation and testing milestone.
        case beta
        /// Represents a mature, stable candidate milestone ready for final deployment verification.
        case releaseCandidate = "rc"
        /// Represents the definitive, canonical stable public deployment production state.
        case release
    }

    /// The current pre-production lifecycle milestone marker.
    public var identifier: Identifier?

    /// The incremental development cycle iteration integer advancing within the active milestone.
    public var version: UInt?

    /// The low-level architecture compilation step tracking sequence.
    public var build: UInt?

    /// Instantiates a canonical semantic stage context configuration layout.
    public init(identifier: Identifier? = nil, version: UInt? = nil, build: UInt? = nil) {
        self.identifier = identifier
        self.version = version
        self.build = build
    }

    public init?(tokens: [String: String]) {
        identifier = tokens["SI"].flatMap(Identifier.init(rawValue:))
        version = tokens["SV"].flatMap(UInt.init)
        build = tokens["B"].flatMap(UInt.init)
    }

    // MARK: - VersionComponentProvider Contract

    /// Evaluates compiled layout design parameters to expose native metadata properties.
    ///
    /// - Parameter token: A target identifier key (`"SI"` for stage raw string, `"SV"` for version, or `"B"` for build layout).
    /// - Returns: The unboxed content node value matching token criteria, or `nil` if unknown.
    public func value(for token: String) -> VersionComponent? {
        switch token {
        case "SI": return identifier?.rawValue
        case "SV": return version
        case "B":  return build
        default:   return nil
        }
    }

    // MARK: - Blankable & Comparable

    /// Instantiates a completely blank semantic blueprint configuration.
    public static var empty: CanonicalVersionStage { CanonicalVersionStage() }

    /// A Boolean value indicating whether all underlying structural features match absolute default states.
    public var isEmpty: Bool {
        identifier~!.isEmpty && version~!.isEmpty && build~!.isEmpty
    }

    /// Evaluates sequential priority precedence metrics across two stage instances.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.identifier != rhs.identifier { return lhs.identifier~! < rhs.identifier~!   }
        if lhs.version != rhs.version { return lhs.version~! < rhs.version~! }
        if lhs.build != rhs.build { return lhs.build~! < rhs.build~! }
        return false
    }
}

/// The main framework software version profile handling standard SemVer metadata operations.
public typealias CanonicalVersion = Version<CanonicalVersionStage>

// MARK: - Identifier + Comparable

extension CanonicalVersionStage.Identifier: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.order < rhs.order
    }

    /// Assigns an internal deterministic sorting weight used during timeline evaluation.
    private var order: Int {
        switch self {
        case .alpha:            return -3
        case .beta:             return -2
        case .releaseCandidate: return -1
        case .release:          return  0
        }
    }
}

// MARK: - Identifier + Blankable

extension CanonicalVersionStage.Identifier: Blankable {
    /// A Boolean value indicating whether the milestone status marks a finalized production state.
    public var isEmpty: Bool { self == .release }
    public static var empty: CanonicalVersionStage.Identifier { .release }
}
