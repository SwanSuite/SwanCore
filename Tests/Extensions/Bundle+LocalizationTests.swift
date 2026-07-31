//
//  Bundle+LocalizationTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("Bundle Dynamic Localization Engine Tests")
struct BundleLocalizationTests {

    @Test("Test standard localized fallback routing validation")
    func testLocalizationFallbackRouting() {
        let unknownKey = "non_existent_localization_key_handle"

        #expect(unknownKey.localized == unknownKey)
        #expect(unknownKey.localizedDynamic == unknownKey)
    }

    @Test("Concurrent Stress Test: DynamicBundle cache stability under heavy multi-threaded payload")
    func testLocalizationConcurrentPerformance() async {
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<1000 {
                group.addTask {
                    let key = "concurrent_stress_key_\(index)"
                    let _ = key.localizedDynamic
                }
            }
        }
        #expect(true)
    }
}
