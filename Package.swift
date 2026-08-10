// swift-interface-format-version: 1.0
// swift-tools-version: 6.0
//
//  Package.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-31.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import PackageDescription

let package = Package(
    name: "SwanCore",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "SwanCore",
            targets: ["SwanCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwanCore",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SwanCoreTests",
            dependencies: ["SwanCore"],
            path: "Tests"
        )
    ]
)
