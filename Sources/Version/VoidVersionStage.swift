//
//  VoidVersionStage.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//


/// A stateless, zero-allocation stub stage representation used for basic software versions.
///
/// Use this stage variant when tracking relies strictly on standard structural core components
/// (`major`, `minor`, `patch`) and explicitly lacks custom prerelease cycles or build iteration states.
public enum VoidVersionStage: VersionStage {
    case void

    public init?(tokens: [String : String]) {
        self = .void
    }

    /// Intercepts formatting lookup metrics. Always returns `nil` since no data tokens are managed.
    public func value(for token: String) -> VersionComponent? { nil }

    /// The canonical identity configuration instance representing absolute emptiness.
    public static var empty: VoidVersionStage { .void }

    /// A Boolean value indicating whether the environment is completely empty. Always returns `true`.
    public var isEmpty: Bool { true }

    public static func < (lhs: Self, rhs: Self) -> Bool { false }
}

/// A convenient typealias mapping onto versions completely stripped of additional stage sub-components.
typealias CoreVersion = Version<VoidVersionStage>
