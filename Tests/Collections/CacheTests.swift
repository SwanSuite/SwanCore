//
//  CacheTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

@Suite("Cache Subscript Storage Tests")
struct CacheTests {

    @Test("Test basic subscript access: write, read, and delete")
    func testBasicSubscriptAccess() {
        let stringCache = Cache<String, NSString>()

        // 1. Проверяем запись и чтение
        stringCache["key_1"] = "SwanSuite_Value"
        #expect(stringCache["key_1"] == "SwanSuite_Value")

        // 2. Проверяем обновление значения
        stringCache["key_1"] = "Updated_Value"
        #expect(stringCache["key_1"] == "Updated_Value")

        // 3. Проверяем ручное удаление через nil
        stringCache["key_1"] = nil
        #expect(stringCache["key_1"] == nil)
    }

    @Test("Test cache clear method flushes store immediately")
    func testCacheClearBehavior() {
        let testCache = Cache<Int, NSString>()

        testCache[1] = "One"
        testCache[2] = "Two"

        testCache.clear()

        #expect(testCache[1] == nil)
        #expect(testCache[2] == nil)
    }
}
