//
//  DataDetector.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A high-performance, lightweight wrapper around `NSDataDetector` optimized for full-boundary string validation.
public struct DataDetector: Sendable {

    private let detector: NSDataDetector

    /// Initializes a data detector for specific structural checking types.
    /// - Parameter types: The structural checking types to identify (e.g., `.link`, `.phoneNumber`).
    public init(types: NSTextCheckingResult.CheckingType) throws {
        self.detector = try NSDataDetector(types: types.rawValue)
    }

    /// Evaluates if the input string contains a valid match that spans its exact entire length boundary.
    ///
    /// - Parameters:
    ///   - text: The raw text sequence undergoing verification.
    ///   - predicate: An optional custom evaluation closure to execute deep verification on the match properties.
    /// - Returns: `true` if a full-boundary match is found and passes the predicate; otherwise, `false`.
    public func matchesFullBoundary(
        in text: String,
        predicate: ((NSTextCheckingResult) -> Bool)? = nil
    ) -> Bool {
        let range = NSRange(location: 0, length: text.utf16.count)
        var isValid = false

        detector.enumerateMatches(in: text, options: [], range: range) { result, _, stop in
            guard let result, result.range == range else { return }

            if let predicate = predicate {
                isValid = predicate(result)
            } else {
                isValid = true
            }
            stop.initialize(to: true)
        }

        return isValid
    }
}
