//
//  WeakDictionaryTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-17.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Testing
import Foundation
@testable import SwanCore

// Внутренний тестовый класс, так как значением должен быть AnyObject
private final class MockPayload {}

@Suite("WeakDictionary Storage & Eviction Tests")
struct WeakDictionaryTests {

    @Test("Test basic write, read, and explicit removal operations")
    func testBasicOperations() {
        var weakDict = WeakDictionary<String, MockPayload>()
        let payload = MockPayload()

        // Write & Read
        weakDict["test_key"] = payload
        #expect(weakDict["test_key"] === payload)

        // Explicit removal via nil assignment
        weakDict["test_key"] = nil
        #expect(weakDict["test_key"] == nil)

        // Explicit removal via method
        weakDict["another_key"] = MockPayload()
        weakDict.removeValue(forKey: "another_key")
        #expect(weakDict["another_key"] == nil)
    }

    @Test("Test weak references lifecycle and lazy key eviction rule")
    func testWeakReferenceLifecycle() {
        var weakDict = WeakDictionary<Int, MockPayload>()

        // Создаем область видимости, чтобы объект гарантированно уничтожился
        do {
            let temporaryPayload = MockPayload()
            weakDict[42] = temporaryPayload

            // Пока объект жив в рамках скоупа, словарь должен его отдавать
            #expect(weakDict[42] === temporaryPayload)
        }
        // Здесь temporaryPayload выходит из памяти и уничтожается,
        // так как словарь удерживает его слабой ссылкой (weak).

        // Проверяем, что словарь лениво вернул nil и очистил ноду под капотом
        #expect(weakDict[42] == nil)
    }
}
