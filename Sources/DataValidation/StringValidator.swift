//
//  StringValidator.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A unified protocol blueprint defining the strategy contract for text structural validation.
public protocol StringValidator: Sendable, Hashable {

    /// A unique structural identifier assigned during initialization context routing.
    var id: String { get }

    /// Evaluates if the provided text sequence satisfies the validation criteria.
    ///
    /// - Parameter text: The raw text sequence undergoing verification.
    /// - Returns: `true` if the text pattern matches the expected structural layout; otherwise, `false`.
    func validate(_ text: String) -> Bool
}

// MARK: - Default Hashable Implementation

public extension StringValidator {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Concrete Strategy: Email Validator

/// An atomic validator strategy ensuring input strings conform to valid international email handling formats.
public struct EmailValidator: StringValidator {

    public let id: String
    private let detector: DataDetector

    /// Initializes the email validator.
    /// - Throws: An error if the underlying `NSDataDetector` fails to instantiate.
    public init(id: String = UUID().uuidString) throws {
        self.id = id
        self.detector = try DataDetector(types: .link)
    }

    public func validate(_ text: String) -> Bool {
        detector.matchesFullBoundary(in: text) { $0.url?.scheme == "mailto" }
    }
}

// MARK: - Concrete Strategy: Phone Validator

/// An atomic validator strategy verifying structural integrity of international telephone sequences.
public struct PhoneNumberValidator: StringValidator {

    public let id: String
    private let detector: DataDetector

    /// Initializes the phone validator.
    /// - Throws: An error if the underlying `NSDataDetector` fails to instantiate.
    public init(id: String = UUID().uuidString) throws {
        self.id = id
        self.detector = try DataDetector(types: .phoneNumber)
    }

    public func validate(_ text: String) -> Bool {
        detector.matchesFullBoundary(in: text)
    }
}

// MARK: - Concrete Strategy: Link Validator

/// An atomic validator strategy ensuring hyperlink patterns conform to proper URL profiles.
public struct LinkValidator: StringValidator {

    public let id: String
    public let scheme: String?
    private let detector: DataDetector

    /// Initializes the link validator with optional scheme constraints.
    /// - Throws: An error if the underlying `NSDataDetector` fails to instantiate.
    public init(scheme: String? = nil, id: String = UUID().uuidString) throws {
        self.scheme = scheme
        self.id = id
        self.detector = try DataDetector(types: .link)
    }

    public func validate(_ text: String) -> Bool {
        var predicate: ((NSTextCheckingResult) -> Bool)? = nil
        if let scheme {
            predicate = { $0.url?.scheme?.lowercased() == scheme.lowercased() }
        }
        return detector.matchesFullBoundary(in: text, predicate: predicate)
    }
}
