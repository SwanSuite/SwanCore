//
//  Bundle+Localization.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation
import os

public extension Bundle {

    /// Returns a localized string from the bundle using the specified key, fallback value, and table.
    ///
    /// - Parameters:
    ///   - key: The key for a string in the specified table.
    ///   - value: The value to return if key is nil or not found in the table. Defaults to `nil`.
    ///   - table: The receiver’s string table to search. Defaults to `nil`.
    /// - Returns: A localized version of the string associated with the specified key.
    func localized(_ key: String, value: String? = nil, table: String? = nil) -> String {
        localizedString(forKey: key, value: value, table: table)
    }

    /// Returns a formatted localized string from the bundle using a specific locale and substitution arguments.
    ///
    /// - Parameters:
    ///   - key: The key for a string in the specified table.
    ///   - value: The value to return if key is nil or not found in the table. Defaults to `nil`.
    ///   - table: The receiver’s string table to search. Defaults to `nil`.
    ///   - locale: The locale to use for formatting numbers and dates. Defaults to `.current`.
    ///   - arguments: A comma-separated list of arguments to substitute into the format string.
    /// - Returns: A formatted, localized version of the string associated with the specified key.
    func localized(
        _ key: String,
        value: String? = nil,
        table: String? = nil,
        locale: Locale = .current,
        with arguments: CVarArg...
    ) -> String {
        let format = localizedString(forKey: key, value: value, table: table)
        return String(format: format, locale: locale, arguments: arguments)
    }

    /// Synchronously deserializes and extracts all raw entries from the primary strings file inside this bundle.
    ///
    /// Useful for testing pipelines, localization completeness validation, or diagnostic logging.
    ///
    /// - Returns: A dictionary containing localized key-value string mappings, or `nil` if the resource is missing.
    /// - Throws: An error if file reading or property list serialization fails.
    func fetchLocalizableStrings() throws -> [String: String]? {
        guard let fileURL = url(forResource: "Localizable", withExtension: "strings") else {
            return nil
        }
        let data = try Data(contentsOf: fileURL)
        let plist = try PropertyListSerialization.propertyList(from: data, format: .none)
        return plist as? [String: String]
    }
}
