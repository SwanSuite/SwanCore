//
//  Bundle+Metadata.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

public extension Bundle {

    // MARK: - Static Application Metadata Short-hands

    /// The executable name of the main application target.
    ///
    /// Resolves to an empty string if the executable key is missing from the `Info.plist`.
    /// ```swift
    /// print(Bundle.appExecutable) // e.g., "SwanKitDemo"
    /// ```
    @inlinable
    static var appExecutable: String {
        main.executable~!
    }

    /// The basic bundle name of the main application target (`CFBundleName`).
    ///
    /// Resolves to an empty string if the name key is missing from the `Info.plist`.
    /// ```swift
    /// print(Bundle.appName) // e.g., "SwanKit"
    /// ```
    @inlinable
    static var appName: String {
        main.name~!
    }

    /// The user-visible display name of the main application target (`CFBundleDisplayName`).
    ///
    /// Falls back to the basic bundle name (`appName`), and then to an empty string if completely unresolved.
    /// ```swift
    /// print(Bundle.appDisplayName) // e.g., "SwanKit Framework"
    /// ```
    @inlinable
    static var appDisplayName: String {
        main.displayName~!
    }

    /// The marketing version string of the main application target (`CFBundleShortVersionString`).
    ///
    /// Resolves to an empty string if the short version key is missing from the `Info.plist`.
    /// ```swift
    /// print(Bundle.appVersion) // e.g., "1.0.3"
    /// ```
    @inlinable
    static var appVersion: String {
        main.shortVersion~!
    }

    /// The build number string of the main application target (`CFBundleVersion`).
    ///
    /// Resolves to an empty string if the build number key is missing from the `Info.plist`.
    /// ```swift
    /// print(Bundle.appBuild) // e.g., "42"
    /// ```
    @inlinable
    static var appBuild: String {
        main.buildNumber~!
    }

    // MARK: - Dynamic Bundle Instance Properties

    /// The executable binary name of this bundle instance (`kCFBundleExecutableKey`).
    @inlinable
    var executable: String? {
        infoDictionary?[kCFBundleExecutableKey as String] as? String
    }

    /// The bundle name of this bundle instance (`kCFBundleNameKey`).
    @inlinable
    var name: String? {
        infoDictionary?[kCFBundleNameKey as String] as? String
    }

    /// The preferred localized or user-visible display name of this bundle instance.
    ///
    /// Searches for `CFBundleDisplayName` and falls back to the default bundle `name` if not specified.
    @inlinable
    var displayName: String? {
        infoDictionary?["CFBundleDisplayName"] as? String ?? name
    }

    /// The user-visible release or marketing version string of this bundle instance (`CFBundleShortVersionString`).
    @inlinable
    var shortVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    /// The internal build version number string of this bundle instance (`kCFBundleVersionKey`).
    @inlinable
    var buildNumber: String? {
        infoDictionary?[kCFBundleVersionKey as String] as? String
    }
}
