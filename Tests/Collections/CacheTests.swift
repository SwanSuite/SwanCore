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

struct TestModel: Sendable {
    let payload: String
    init(_ payload: String) { self.payload = payload }
}

@Suite("Cache Subscript Storage Tests")
struct CacheTests {

    @Test("Test basic subscript access: write, read, and delete")
    func testBasicSubscriptAccess() {
        // Используем нашу Sendable-модель вместо NSString
        let stringCache = Cache<String, TestModel>()

        // 1. Проверяем запись и чтение
        stringCache["key_1"] = TestModel("SwanSuite_Value")
        #expect(stringCache["key_1"]?.payload == "SwanSuite_Value")

        // 2. Проверяем обновление значения
        stringCache["key_1"] = TestModel("Updated_Value")
        #expect(stringCache["key_1"]?.payload == "Updated_Value")

        // 3. Проверяем ручное удаление через nil
        stringCache["key_1"] = nil
        #expect(stringCache["key_1"] == nil)
    }

    @Test("Test cache clear method flushes store immediately")
    func testCacheClearBehavior() {
        let testCache = Cache<Int, TestModel>()

        testCache[1] = TestModel("One")
        testCache[2] = TestModel("Two")

        testCache.clear()

        #expect(testCache[1] == nil)
        #expect(testCache[2] == nil)
    }
}
