//
//  VersionFormatter.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A high-performance, stream-lined formatting engine designed to compile tokenized pattern templates into fully realized ``Version`` strings.
///
/// This structure provides complete compile-time type safety via unified `<?` and `<!` operators,
/// leveraging powerful regular expressions to dynamically expand or prune optional bracket blocks `[...]`.
public struct VersionFormatter: Sendable {

    /// The active raw token rule pattern to process.
    public let format: String

    /// Initializes a formatting engine utilizing a highly custom placeholder string structure blueprint.
    /// - Parameter format: The custom template string composition layout rules. Defaults to `.semVer` format.
    public init(format: String = VersionFormatter.semVer.format) {
        self.format = format
    }

    /// Combines a target version metadata profile with the active template layout constraints.
    ///
    /// Evaluates the complete token map matrix through an optimized loop, executing
    /// safe, deterministic regular expression transformations with zero dynamic type-erasure.
    ///
    /// - Parameter version: The data-source version instance.
    /// - Returns: A fully stylized, processed string outcome.
    public func string(from version: Version) -> String {
        var result = format

        for token in Token.allCases {
            // Улучшенная регулярка: захватывает и префикс ($1), и суффикс ($2) вокруг маркера токена
            let pattern = "\\[([^%^\\[^\\]]*)\(token.rawValue)([^%^\\[^\\]]*)\\]"

            let optionalValue = switch token {
            case .major: <?version.major
            case .minor: <?version.minor
            case .patch: <?version.patch
            case .preReleaseIdentifier: <?version.preReleaseIdentifier
            case .preReleaseVersion: <?version.preReleaseVersion
            case .build: <?version.build
            }

            result = result.replacingOccurrences(
                of: pattern,
                with: optionalValue,
                options: .regularExpression
            )

            let requiredValue = switch token {
            case .major: <!version.major
            case .minor: <!version.minor
            case .patch: <!version.patch
            case .preReleaseIdentifier: <!version.preReleaseIdentifier
            case .preReleaseVersion: <!version.preReleaseVersion
            case .build: <!version.build
            }

            result = result.replacingOccurrences(
                of: "%\(token.rawValue)",
                with: requiredValue
            )
        }

        result = result.replacingOccurrences(
            of: "\\[\\]",
            with: "",
            options: .regularExpression
        )

        return result
    }
}

// MARK: - Predefined Static Formatters

public extension VersionFormatter {

    /// Minimalistic index layout focusing on main release numbers.
    /// Trailing zeros in optional blocks are treated as empty and automatically pruned.
    /// Maps onto: `"%MJ[.MN][.P]"` -> outputs `"1.2.3"` or `"1"` (for "1.0.0").
    static let short = VersionFormatter(format: "%MJ[.MN][.P]")

    /// Compact framework branding layout used by default within the framework.
    /// Maps onto: `"%MJ.%MN[.P][-RIRV+][bB]"` -> outputs `"1.2.3-rc1b45"` or `"1.0b12"`.
    static let medium = VersionFormatter(format: "v%MJ.%MN[.P][-RI][RV][+bB]")

    /// Formal engineering deployment layout incorporating spacing tokens.
    /// Maps onto: `"version %MJ.%MN.%P[-RI.RV] build %B"` -> outputs `"version 1.2.3-rc.1 build 45"`.
    static let long = VersionFormatter(format: "version %MJ.%MN.%P[[-RI.RV]] build %B")

    /// Adheres strictly to the official Semantic Versioning 2.0.0 specification framework layout.
    /// Maps onto: `"%MJ.%MN.%P[-RI][.RV]"` -> outputs `"1.2.3-rc.1"`.
    static let semVer = VersionFormatter(format: "%MJ.%MN.%P[-RI][.RV]")

    /// Standard fallback layout targeting standard Apple bundle representations.
    /// Maps onto: `"%MJ.%MN.%P"` -> outputs `"1.2.3"`.
    static let appleBundle = VersionFormatter(format: "%MJ.%MN.%P")
}


// MARK: - Private Token Matrix

private extension VersionFormatter {
    enum Token: String, CaseIterable {
        case major = "MJ"
        case minor = "MN"
        case patch = "P"
        case preReleaseIdentifier = "RI"
        case preReleaseVersion = "RV"
        case build = "B"
    }
}

// MARK: - Safe Prefix Operators

prefix operator <?
prefix operator <!

private extension Optional where Wrapped: CustomStringConvertible, Wrapped: Emptyable {
    static prefix func <? (value: Wrapped?) -> String {
        guard let value, value.isNotEmpty else { return "" }
        return "$1" + value.description + "$2"
    }

    static prefix func <! (value: Wrapped?) -> String {
        value.flatMap { $0.description } ?? Wrapped.empty.description
    }
}

// MARK: - PreReleaseIdentifier + Emptyable

extension Version.PreReleaseIdentifier: Emptyable {

    public var isEmpty: Bool {
        self == .release
    }

    public static var empty: Version.PreReleaseIdentifier {
        .release
    }
}
