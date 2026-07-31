// swift-interface-format-version: 1.0
// swift-tools-version: 6.0
//
//  Package.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-31.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import PackageDescription

let package = Package(
    name: "SwanCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
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
            path: "Sources",
            swiftSettings: [
                .enableComingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwanCoreTests",
            dependencies: ["SwanCore"],
            path: "Tests",
            swiftSettings: [
                .enableComingFeature("StrictConcurrency")
            ]
        )
    ]
)
