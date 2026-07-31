//
//  Version.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A thread-safe, structural representation of a software version component hierarchy.
///
/// `Version` encapsulates semantic version segments including major, minor, patch,
/// along with pre-release tags and compilation build numbers. It provides flexible formatting
/// capabilities and native protocol string conversions.
///
/// ### Memberwise Initialization
/// Because string parsing logic is decoupled into a dedicated static method, `Version`
/// preserves its native Swift auto-generated memberwise initializer:
/// ```swift
/// let release = Version(major: 1, minor: 2, patch: 0)
/// ```
public struct Version: Sendable {

    /// A convenient local typealias mapping onto the framework's dedicated token serialization engine.
    public typealias Formatter = VersionFormatter

    /// Predefined structural pre-release lifecycle stages supported natively by the framework.
    public enum PreReleaseIdentifier: String, Sendable {
        /// Represents an early, unstable development cycle baseline state.
        case alpha

        /// Represents a feature-complete but potentially unstable evaluation state.
        case beta

        /// Represents a mature, stable candidate milestone ready for production validation ("rc").
        case releaseCandidate = "rc"

        /// Represents the definitive, canonical stable public deployment state.
        case release
    }

    /// The primary major evolutionary release number component (e.g., **1** in "1.2.3").
    public var major: UInt

    /// The secondary minor feature enhancement release number component (e.g., **2** in "1.2.3").
    public var minor: UInt?

    /// The tertiary patch defect correction release number component (e.g., **3** in "1.2.3").
    public var patch: UInt?

    /// The canonical pre-release lifecycle stage token. Defaults to `.release`.
    public var preReleaseIdentifier: PreReleaseIdentifier = .release

    /// The numeric iteration identifier sequence within the active pre-release stage (e.g., **2** in "beta2").
    public var preReleaseVersion: UInt?

    /// The precise compilation build identifier sequence component (e.g., **45** in "1.2.3b45").
    public var build: UInt?

    /// Serializes the version structure components into a string using the specified formatter profile.
    ///
    /// - Example:
    ///   ```swift
    ///   let version = Version(major: 1, minor: 2, preReleaseIdentifier: .beta, preReleaseVersion: 3)
    ///   print(version.formatted(.medium)) // Outputs: "v1.2-beta3"
    ///   ```
    ///
    /// - Parameter formatter: The `VersionFormatter` configuration layout instance to employ. Defaults to `.medium`.
    /// - Returns: A fully composed text representation reflecting the formatter layout rules.
    @inlinable
    public func formatted(_ formatter: Formatter = .medium) -> String {
        formatter.string(from: self)
    }
}

// MARK: - Version + CustomStringConvertible

extension Version: CustomStringConvertible {

    /// A textual representation of this version, automatically mapped onto its default `.medium` layout preset style.
    ///
    /// Seamlessly intercepts native string interpolation contexts.
    /// ```swift
    /// let current = Version(major: 2, minor: 0)
    /// print("Running version: \(current)") // Outputs: "Running version: v2.0"
    /// ```
    public var description: String {
        formatted()
    }
}

// MARK: - Version + LosslessStringConvertible

extension Version: LosslessStringConvertible {

    /// Instantiates a structural version instance directly from a raw string description sequence.
    ///
    /// This lossless initializer enables native type conversion syntax mapping from text streams.
    /// ```swift
    /// guard let resolvedVersion = Version("1.2.0-rc1") else { return }
    /// ```
    ///
    /// - Parameter description: A structured version text sequence containing semantic version boundaries.
    public init?(_ description: String) {
        guard let parsed = Self.parse(description) else { return nil }
        self = parsed
    }
}

// MARK: - Version + Equatable

extension Version: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.major == rhs.major &&
        lhs.minor~! == rhs.minor~! &&
        lhs.patch~! == rhs.patch~! &&
        lhs.preReleaseIdentifier == rhs.preReleaseIdentifier &&
        lhs.preReleaseVersion~! == rhs.preReleaseVersion~! &&
        lhs.build~! == rhs.build~!
    }
}

// MARK: - Version + Comparable

/// Compares two sequential software versions by cascade-evaluating their component hierarchies.
///
/// The comparison evaluation pipeline executes linearly from the most significant block to the finest
/// granular entity. It utilizes the custom framework postfix unwrap operator `~!` to safely fall back
/// onto logical `.empty` identities (0) for missing components, ensuring uniform evaluation metrics.
///
/// ### Evaluation Cascade Priority Matrix
/// 1. `major` (Absolute priority baseline weight)
/// 2. `minor` (Defaults to `0` via `~!`)
/// 3. `patch` (Defaults to `0` via `~!`)
/// 4. `preReleaseIdentifier` (Evaluated via specific timeline weights)
/// 5. `preReleaseVersion` (Defaults to `0` via `~!`)
/// 6. `build` (Technical compilation build step fallback via `~!`)
///
/// - Parameters:
///   - lhs: A left-hand side version model instance operand.
///   - rhs: A right-hand side version model instance operand.
/// - Returns: `true` if the left version hierarchy precedes the right timeline progression path; otherwise, `false`.
extension Version: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor~! < rhs.minor~! }
        if lhs.patch != rhs.patch { return lhs.patch~! < rhs.patch~! }
        if lhs.preReleaseIdentifier != rhs.preReleaseIdentifier { return lhs.preReleaseIdentifier < rhs.preReleaseIdentifier }
        if lhs.preReleaseVersion != rhs.preReleaseVersion { return lhs.preReleaseVersion~! < rhs.preReleaseVersion~! }
        if lhs.build != rhs.build { return lhs.build~! < rhs.build~! }
        return false
    }
}

// MARK: - Version.PreReleaseIdentifier + CustomStringConvertible

extension Version.PreReleaseIdentifier: CustomStringConvertible {
    public var description: String { rawValue }
}

// MARK: - Version.PreReleaseIdentifier + Comparable

extension Version.PreReleaseIdentifier: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Private Core Utilities

private extension Version.PreReleaseIdentifier {

    /// Assigns an internal deterministic sorting weight to each pre-release stage.
    /// Negative numbers mathematically signify pre-production statuses relative to stable production release (0).
    var sortOrder: Int {
        switch self {
        case .alpha:            return -3
        case .beta:             return -2
        case .releaseCandidate: return -1
        case .release:          return  0
        }
    }
}
