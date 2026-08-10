//
//  VersionFormatter+Presets.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//


extension VersionFormatter {

    /// The default global formatting layout employed by the framework hierarchy. Maps onto `.medium`.
    public static let `default`: VersionFormatter = .medium

    /// A minimalistic layout focusing strictly on dominant primary release increments.
    public static let short = try! VersionFormatter(format: "%MJ[.%MN][.%P]")

    /// A highly advanced, compact framework layout evaluating mutual exclusivity via selection branches.
    public static let medium = try! VersionFormatter(format: "%MJ.%MN[.%P][[-%SI[.%SV]]|[ b%B]]")

    /// A formal engineering deployment description structure incorporating explicit textual spacing tokens.
    public static let long = try! VersionFormatter(format: "version %MJ.%MN.%P[-%SI[.%SV]][ build %B]")

    /// Adheres strictly to the official canonical Semantic Versioning 2.0.0 environment specification framework.
    public static let semVer = try! VersionFormatter(format: "%MJ.%MN.%P[-%SI[.%SV]][+b%B]")

    /// A standard fallback layout engine targeting default monolithic Apple application target bundle configurations.
    public static let appleBundle = try! VersionFormatter(format: "%MJ.%MN.%P")
}
