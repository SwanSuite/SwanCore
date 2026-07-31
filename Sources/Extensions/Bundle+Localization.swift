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

    /// A runtime proxy instance that dynamically detects the bundle of the calling framework on the fly.
    ///
    /// Use this instance when you want a shared utility or a subframework to load strings
    /// from the specific module that initiated the localization call, rather than forcing a hardcoded bundle.
    ///
    /// ```swift
    /// let text = "profile_title".localized(.dynamic)
    /// ```
    static var dynamic: Bundle {
        DynamicBundle.shared
    }
}

public extension Bundle {

    /// Returns a localized version of the string designated by the specified key.
    ///
    /// - Parameters:
    ///   - key: The key for a string in the specified table.
    ///   - value: The value to return if key is nil or not found in the table.
    ///   - table: The receiver's string table to search.
    /// - Returns: A localized version of the string, or the key itself if no translation is found.
    @inlinable
    func localized(_ key: String, value: String? = nil, table: String? = nil) -> String {
        localizedString(forKey: key, value: value, table: table)
    }

    /// Synchronously deserializes and extracts all raw entries from the primary strings file inside this bundle.
    ///
    /// - Returns: A dictionary containing localized key-value string mappings, or `nil` if the resource is missing.
    /// - Throws: An error if file reading or plist serialization fails.
    func fetchLocalizableStrings() throws -> [String: String]? {
        guard let fileURL = url(forResource: "Localizable", withExtension: "strings") else {
            return nil
        }
        let data = try Data(contentsOf: fileURL)
        let plist = try PropertyListSerialization.propertyList(from: data, format: .none)
        return plist as? [String: String]
    }
}

public extension String {

    /// Localizes the string using the specified bundle, table, and default value.
    ///
    /// - Parameters:
    ///   - bundle: The target bundle containing the strings file. Defaults to `.main`.
    ///   - value: The value to return if the key is not found in the table. Defaults to `nil`.
    ///   - table: The receiver's string table to search. Defaults to `nil` (loads from `Localizable.strings`).
    /// - Returns: A localized version of the string, or the key itself if no translation is found.
    @inlinable
    func localized(_ bundle: Bundle = .main, value: String? = nil, table: String? = nil) -> String {
        bundle.localized(self, value: value, table: table)
    }

    /// A fast computed shorthand property for standard localization via the main application bundle.
    ///
    /// ```swift
    /// let title = "welcome_message".localized
    /// ```
    @inlinable
    var localized: String {
        localized()
    }

    /// A computed shorthand property that leverages context-aware dynamic bundle resolution.
    ///
    /// This property automatically looks up the localization assets of whichever custom framework
    /// executes the statement, falling back safely to `.main` if the context cannot be verified.
    ///
    /// ### Performance Warning
    /// Avoid calling this property repeatedly inside high-frequency execution paths, such as
    /// `cellForRowAt:`, `collectionView(_:cellForItemAt:)`, loop structures, or custom layout pipelines.
    /// Although the underlying resolution layer caches framework bundles via atomic locks, the initial
    /// thread backtrace inspection (`Thread.callStackReturnAddresses`) incurs a significant runtime overhead.
    /// For performance-critical rendering paths, cache the localized string static instance statically
    /// or pass the target `Bundle` explicitly.
    ///
    /// ```swift
    /// let frameworkText = "feature_header".localizedDynamic
    /// ```
    var localizedDynamic: String {
        localized(.dynamic)
    }
}

// MARK: - Internal Dynamic Proxy Core

/// A private proxy class that overrides the standard Cocoa localization routing with thread-safe caching.
private final class DynamicBundle: Bundle, @unchecked Sendable {
    static let shared = DynamicBundle()

    /// An optimized, thread-safe cache backing storage mapping a DSO memory image base address directly to its resolved Bundle.
    private let lock = OSAllocatedUnfairLock<[UnsafeRawPointer: Bundle]>(initialState: [:])

    override func localizedString(forKey key: String, value: String?, table: String?) -> String {

        @inline(__always)
        func fallback() -> String {
            Bundle.main.localizedString(forKey: key, value: value, table: table)
        }

        let symbols = Thread.callStackReturnAddresses

        // Unify standard backtrace stack layout boundary checks
        guard symbols.count > 2,
              let callerAddress = UnsafeRawPointer(bitPattern: symbols[2].intValue) else {
            return fallback()
        }

        // Fast resolution of the caller's mach-o binary shared object metadata container
        var info = Dl_info()
        guard dladdr(callerAddress, &info) != 0,
                let dsoBaseAddress = info.dli_fbase else {
            return fallback()
        }

        // Atomic lock verification check for previously memoized framework bundles
        if let cachedBundle = lock.withLock({ $0[dsoBaseAddress] }) {
            return cachedBundle.localizedString(forKey: key, value: value, table: table)
        }

        // Fallback file system traversal block executing heavy asset initialization path
        if let callerBundle = Bundle(forDsoAddress: dsoBaseAddress, info: info) {
            lock.withLock { $0[dsoBaseAddress] = callerBundle }
            return callerBundle.localizedString(forKey: key, value: value, table: table)
        }

        return fallback()
    }
}

// MARK: - Backtrace Memory Inspection Bridge

private extension Bundle {

    /// Resolves and initialises a physical `Bundle` container mapped to a specific Dynamic Shared Object (DSO) file layout name handle.
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
