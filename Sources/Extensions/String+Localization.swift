//
//  String+Localization.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-31.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation
import os

public extension String {

    /// Returns the localized version of the string using the primary application bundle (`Bundle.main`).
    @inlinable
    var localized: String {
        Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }

    /// Looks up and returns the localized representation of the string within a specific bundle scope.
    ///
    /// - Parameters:
    ///   - bundle: The target resource container bundle. Defaults to `.main`.
    ///   - value: A default fallback value to return if the key is not found. Defaults to `nil`.
    ///   - table: The target strings table file name to search. Defaults to `nil`.
    /// - Returns: The localized variant matching the structural key layout configuration.
    @inlinable
    func localized(_ bundle: Bundle = .main, value: String? = nil, table: String? = nil) -> String {
        bundle.localized(self, value: value, table: table)
    }

    /// Looks up, localized, and formats the receiver string using the specified bundle context, locale rules, and replacement tokens.
    ///
    /// - Parameters:
    ///   - bundle: The target resource container bundle. Defaults to `.main`.
    ///   - value: A default fallback value to return if the key is not found. Defaults to `nil`.
    ///   - table: The target strings table file name to search. Defaults to `nil`.
    ///   - locale: The formatting locale rule to apply for numbers or dates. Defaults to `.current`.
    ///   - arguments: A sequential collection of variable tokens to merge into the formatted template.
    /// - Returns: A fully formatted, localized textual representation.
    @inlinable
    func localized(
        _ bundle: Bundle = .main,
        value: String? = nil,
        table: String? = nil,
        locale: Locale = .current,
        with arguments: CVarArg...
    ) -> String {
        bundle.localized(self, value: value, table: table, locale: locale, with: arguments)
    }
}
