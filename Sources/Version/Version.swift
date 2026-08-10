//
//  Version.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

// MARK: - Core Protocols & Types

/// A typealias representing a composition of components that can evaluate their emptiness and provide a string description.
public typealias VersionComponent = Blankable & CustomStringConvertible

/// A protocol for types capable of extracting and providing their internal content mapped directly onto string token indicators.
public protocol VersionComponentProvider: Sendable {
    /// Extracts a software version data property matching a specific format template key.
    ///
    /// - Parameter token: A short string representation of the field layout rule.
    /// - Returns: A valid ``VersionComponent`` instance if found, otherwise `nil`.
    func value(for token: String) -> VersionComponent?
}

public protocol TokensComposable {
    init?(tokens: [String: String])
}

/// A protocol establishing structural layout behaviors, sorting rules, and metadata capabilities for evolutionary runtime contexts.
public protocol VersionStage: VersionComponentProvider, TokensComposable, Blankable, Comparable {}

// MARK: - Core Structural Generic Model

/// A thread-safe, structural generic model representing a modular software version hierarchy.
///
/// `Version` encapsulates essential core numbering coordinates—major, minor, and patch—alongside
/// an open generic pipeline context to handle custom metadata, pre-release stages, and technical builds.
public struct Version<Stage: VersionStage>: VersionComponentProvider, TokensComposable {
    public typealias Formatter = VersionFormatter

    /// The primary evolutionary release number component (e.g., **1** in "1.2.3").
    public var major: UInt

    /// The secondary minor feature enhancement release number component (e.g., **2** in "1.2.3").
    public var minor: UInt?

    /// The tertiary patch defect correction release number component (e.g., **3** in "1.2.3").
    public var patch: UInt?

    /// An optional custom pipeline or lifecycle phase environment extension matching the version state.
    public var stage: Stage?

    /// Instantiates a structural software version instance with optional components.
    public init(major: UInt, minor: UInt? = nil, patch: UInt? = nil, stage: Stage? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.stage = stage
    }

    public init?(tokens: [String : String]) {
        guard let major = tokens["MJ"].flatMap(UInt.init) else { return nil }
        self.major = major
        minor = tokens["MN"].flatMap(UInt.init)
        patch = tokens["P"].flatMap(UInt.init)
        stage = .init(tokens: tokens)
    }

    /// Serializes the version structural elements into a string using the specified layout configuration preset.
    ///
    /// - Parameter formatter: The active layout composition profile to employ. Defaults to `.medium`.
    /// - Returns: A fully composed text representation reflecting the formatter rules.
    @inlinable
    public func formatted(_ formatter: Formatter = .medium) -> String {
        formatter.string(from: self)
    }

    /// Resolves and fetches internal property states mapped directly to layout format tokens.
    ///
    /// Evaluates base structural numbers natively before falling back on custom stage dictionary query chains.
    ///
    /// - Parameter token: A target layout design parameter code (e.g., `"MJ"`, `"MN"`, `"P"`).
    /// - Returns: A structural data node slice mapping to requested metrics, or `nil` if unrecognized.
    public func value(for token: String) -> VersionComponent? {
        switch token {
        case "MJ": major
        case "MN": minor
        case "P" : patch
        default  : stage?.value(for: token)
        }
    }
}

// MARK: - Version + Emptiable

extension Version: Emptiable {
    /// A Boolean value indicating whether all component properties currently represent absolute baseline default states.
    public var isEmpty: Bool {
        major.isEmpty && minor~!.isEmpty && patch~!.isEmpty && stage~!.isEmpty
    }
}

// MARK: - Version + CustomStringConvertible

extension Version: CustomStringConvertible {
    /// A textual representation of this version instance, automatically mapped onto its default layout preset style.
    public var description: String { formatted() }
}

// MARK: - Version + LosslessStringConvertible

extension Version: LosslessStringConvertible where Stage == CanonicalVersionStage {
    /// Instantiates a version instance sequence directly from a raw string description text context.
    ///
    /// - Parameter description: A structured raw version pattern container layout sequence.
    public init?(_ description: String) {
        guard let tokens = VersionFormatter.default.parse(description) else { return nil }
        self.init(tokens: tokens)
    }
}

// MARK: - Version + Equatable

extension Version: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.major   == rhs.major   &&
        lhs.minor~! == rhs.minor~! &&
        lhs.patch~! == rhs.patch~! &&
        lhs.stage   == rhs.stage
    }
}

// MARK: - Version + Comparable

extension Version: Comparable {
    /// Evaluates linear historical advancement steps to prioritize sorting sequences across two versions.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major   < rhs.major   }
        if lhs.minor != rhs.minor { return lhs.minor~! < rhs.minor~! }
        if lhs.patch != rhs.patch { return lhs.patch~! < rhs.patch~! }
        if lhs.stage != rhs.stage { return lhs.stage~! < rhs.stage~! }
        return false
    }
}
