//
//  String+CaseConverting.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// An extension providing lightweight, high-performance case conversion utilities for strings.
///
/// This component handles transformation workflows between various programming naming conventions,
/// including `camelCase`, `snake_case`, `PascalCase`, and `SCREAMING_SNAKE_CASE`.
public extension String {

    /// Transforms the very first character of the string using a custom closure block.
    ///
    /// - Parameter transcode: A closure that processes the initial `Character` and returns its string representation.
    /// - Returns: A brand new modified string sequence, or an empty string if the receiver is empty.
    @inlinable
    func transcodeFirst(_ transcode: (Character) -> String) -> String {
        guard let f = first else { return "" }
        return transcode(f) + dropFirst()
    }

    /// Capitalizes the very first character of the string while preserving the casing of all subsequent characters.
    ///
    /// ```swift
    /// let text = "swanKit"
    /// print(text.upperFirst()) // Outputs: "SwanKit"
    /// ```
    ///
    /// - Returns: The string with an capitalized leading character.
    @inlinable
    func upperFirst() -> String {
        transcodeFirst { $0.uppercased() }
    }

    /// Splits a snake_case string into an array of individual components separated by underscores.
    @inlinable
    var snakeComponents: [String] {
        components(separatedBy: "_")
    }

    /// Converts a `snake_case` string into `PascalCase`.
    ///
    /// ```swift
    /// let key = "user_profile_details"
    /// print(key.pascalCasedSnake) // Outputs: "UserProfileDetails"
    /// ```
    @inlinable
    var pascalCasedSnake: String {
        snakeComponents.map { $0.capitalized }.joined()
    }

    /// Converts a `snake_case` string into `camelCase`.
    ///
    /// ```swift
    /// let key = "auth_token_expiration"
    /// print(key.camelCasedSnake) // Outputs: "authTokenExpiration"
    /// ```
    @inlinable
    var camelCasedSnake: String {
        pascalCasedSnake.transcodeFirst { $0.lowercased() }
    }

    /// Partially normalizes a `camelCase` string into an intermediate underscored layout.
    ///
    /// Uses a regular expression pattern matching to intercept uppercase letters and numeric boundaries,
    /// prepending an underscore to isolate structural word transitions.
    ///
    /// ```swift
    /// let property = "snakeEatingTrain"
    /// print(property.camelCaseTo_snake_Eating_Train) // Outputs: "snake_Eating_Train"
    /// ```
    @inlinable
    var camelCaseTo_snake_Eating_Train: String {
        replacingOccurrences(of: "([A-Z,\\d]+)", with: "_$1",
                             options: .regularExpression, range: nil)
    }

    /// Converts a standard `camelCase` attribute name into an alphanumeric `SCREAMING_SNAKE_CASE` sequence.
    ///
    /// ```swift
    /// let setting = "maxRetryCount"
    /// print(setting.camelCaseTo_SCREAMING_SNAKE) // Outputs: "MAX_RETRY_COUNT"
    /// ```
    @inlinable
    var camelCaseTo_SCREAMING_SNAKE: String {
        camelCaseTo_snake_Eating_Train.uppercased()
    }

    /// A dedicated stateless functional namespace encapsulating modular string conversion profiles.
    enum Transcoding {

        /// Proxy method converting a `snake_case` string input into a `PascalCase` representation.
        @inlinable
        public static func snakeToPascalCase(_ input: String) -> String {
            input.pascalCasedSnake
        }

        /// Proxy method converting a `snake_case` string input into a `camelCase` representation.
        @inlinable
        public static func snakeToCamelCase(_ input: String) -> String {
            input.camelCasedSnake
        }
    }
}
