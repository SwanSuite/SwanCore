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
    func localized(_ key: String, value: String? = nil, table: String? = nil) -> String {
        localizedString(forKey: key, value: value, table: table)
    }

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

    static func resolveBundle() -> Bundle {
        let symbols = Thread.callStackReturnAddresses
        guard
            symbols.count > 1,
            let callerAddress = UnsafeRawPointer(bitPattern: symbols[1].intValue)
        else { return .main }

        return DynamicBundleManager.shared.resolveBundle(for: callerAddress)
    }
}

// MARK: - DynamicBundleManager & Extension Bundle

/// An internal thread-safe manager responsible for mapping call stack instruction addresses to their corresponding framework bundles.
///
/// This manager avoids subclassing `Bundle` to prevent cyclic dependencies during early runtime initialization.
/// It uses lock-protected memoization to bypass heavy Mach-O binary lookups on repeated localization calls.
final class DynamicBundleManager: Sendable {

    /// The shared singleton instance of the dynamic bundle manager.
    static let shared = DynamicBundleManager()

    /// A thread-safe storage backing that maps a caller's instruction address directly to its resolved `Bundle`.
    private let lock = OSAllocatedUnfairLock<[UInt: Bundle]>(initialState: [:])

    /// Resolves and returns the `Bundle` associated with the specified call stack return address.
    ///
    /// The method first checks an internal cache using the instruction pointer address. If a cache miss occurs,
    /// it performs a dynamic runtime look-up via `dladdr` to locate the Dynamic Shared Object (DSO) file layout metadata.
    ///
    /// - Parameter callerAddress: The raw execution pointer extracted from the thread backtrace layout.
    /// - Returns: The resolved `Bundle` container matching the caller's binary origin, or `.main` as a fallback.
    ///
    /// - Complexity: O(1) on cache hit; O(N) where N is the file path depth on cache miss.
    func resolveBundle(for callerAddress: UnsafeRawPointer) -> Bundle {
        let cacheKey = UInt(bitPattern: callerAddress)

        if let cachedBundle = lock.withLock({ $0[cacheKey] }) {
            return cachedBundle
        }

        var info = Dl_info()
        guard dladdr(callerAddress, &info) != 0,
              let dsoBaseAddress = info.dli_fbase else {
            return .main
        }

        if let callerBundle = Bundle(forDsoAddress: dsoBaseAddress, info: info) {
            lock.withLock { $0[cacheKey] = callerBundle }
            return callerBundle
        }

        return .main
    }
}

private extension Bundle {
    /// Initializes a physical `Bundle` container mapped to a specific Dynamic Shared Object (DSO) memory location.
    ///
    /// This helper traverses up the file system hierarchy from the shared library's file path (`dli_fname`)
    /// until it identifies a valid bundle structure boundary.
    ///
    /// - Parameters:
    ///   - dsoAddress: The base memory address image pointer of the Mach-O binary.
    ///   - info: The structural metadata container populated by the system linker.
    /// - Returns: An initialized `Bundle` instance targeting the discovered container directory,
    ///   or `nil` if no matching directory infrastructure is located.
    convenience init?(forDsoAddress dsoAddress: UnsafeRawPointer, info: Dl_info) {
        guard let path = info.dli_fname else { return nil }
        let url = URL(fileURLWithPath: String(cString: path))

        var currentURL = url
        while currentURL.pathComponents.count > 1 {
            let ext = currentURL.pathExtension
            if ext == "framework" || ext == "bundle" || ext == "app" {
                self.init(url: currentURL)
                return
            }
            currentURL = currentURL.deletingLastPathComponent()
        }
        return nil
    }
}
