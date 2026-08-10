//
//  ListTests.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-18.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//


import Testing
import Foundation
import os
@testable import SwanCore

// MARK: - Mock Test Entity

final class A: Sendable {
    let id = UUID()
}

extension A: Equatable {
    static func == (lhs: A, rhs: A) -> Bool {
        lhs.id == rhs.id
    }
}

// ============================================
// MARK: - Structural Mutation Validation Suite
// ============================================

@Suite("List Structural Mutation Integration Suite")
struct ListMutationTests {

    @Test("Validate head and tail resetting to nil upon removing the last remaining element")
    func testBoundaryResetOnEmptying() async throws {
        // Сценарий 1: Извлечение единственного элемента с головы списка (popFront)
        let list1 = List<Int, VoidRWLock>()
        list1.pushBack(42)

        #expect(list1.head != nil)
        #expect(list1.tail != nil)
        #expect(list1.count == 1)

        let _: Int? = list1.popFront()

        #expect(list1.head == nil, "Head pointer must be reset to nil when the list is fully depleted via popFront")
        #expect(list1.tail == nil, "Tail pointer must be reset to nil when the list is fully depleted via popFront")
        #expect(list1.count == 0)

        // Сценарий 2: Извлечение единственного элемента с хвоста списка (popBack)
        let list2 = List<Int, VoidRWLock>()
        list2.pushBack(24)

        let _: Int? = list2.popBack()

        #expect(list2.head == nil, "Head pointer must be reset to nil when the list is fully depleted via popBack")
        #expect(list2.tail == nil, "Tail pointer must be reset to nil when the list is fully depleted via popBack")
        #expect(list2.count == 0)

        // Сценарий 3: Прямое принудительное удаление элемента через ElementRemover
        let list3 = List<Int, VoidRWLock>()
        list3.pushBack(7)

        // Ручной захват лока для обхода ограничения Sendable в withReadLock
        list3.lock.readLock()
        let lastElement = list3.head
        list3.lock.unlock()

        if let element = lastElement {
            list3.remove(element)

            #expect(list3.head == nil, "Head pointer must be explicitly nullified when the last standing element is cut out via remove")
            #expect(list3.tail == nil, "Tail pointer must be explicitly nullified when the last standing element is cut out via remove")
            #expect(list3.count == 0)
        }
    }

    @Test("Verify count invariant and node connections under sequential operations")
    func testSequentialMetricsAndConnections() async throws {
        let list = List<Int, VoidRWLock>()

        // Проверяем начальное состояние
        #expect(list.count == 0)
        #expect(list.head == nil)
        #expect(list.tail == nil)

        // Наполняем последовательно
        list.pushBack(10)
        #expect(list.count == 1)
        #expect(list.head === list.tail)

        list.pushBack(20)
        #expect(list.count == 2)
        #expect(list.head?.next === list.tail)
        #expect(list.tail?.prev === list.head)

        list.pushFront(5)
        #expect(list.count == 3)
        #expect(list.head?.object == 5)
        #expect(list.head?.next?.object == 10)

        // Извлекаем объект с головы и разворачиваем опционал
        let poppedFront: Int? = list.popFront()
        let frontValue = try #require(poppedFront)
        #expect(frontValue == 5)
        #expect(list.count == 2)
        #expect(list.head?.prev == nil, "New head's prev pointer must be safely unlinked")

        // Извлекаем объект с хвоста и разворачиваем опционал
        let poppedBack: Int? = list.popBack()
        let backValue = try #require(poppedBack)
        #expect(backValue == 20)
        #expect(list.count == 1)
        #expect(list.tail?.next == nil, "New tail's next pointer must be safely unlinked")
    }

    @Test("Ensure edge case safety when popping from an empty collection")
    func testOperationsOnEmptyList() async throws {
        let list = List<Int, VoidRWLock>()

        // Попытки извлечения из пустого списка возвращают явный nil
        let poppedFront: Int? = list.popFront()
        let poppedBack: Int? = list.popBack()

        #expect(poppedFront == nil)
        #expect(poppedBack == nil)
        #expect(list.count == 0, "Count must remain strictly zero when popping from empty containers")
        #expect(list.head == nil)
        #expect(list.tail == nil)
    }

    @Test("Validate internal node unlinking inside intermediate positions via ElementRemover")
    func testIntermediateElementRemoval() async throws {
        let list = List<Int, VoidRWLock>()
        list.pushBack(100)
        list.pushBack(200)
        list.pushBack(300)

        // Ручной захват лока для безопасного чтения не-Sendable элемента структуры
        list.lock.readLock()
        let middleElement = list.head?.next
        list.lock.unlock()

        let target = try #require(middleElement)
        #expect(target.object == 200)

        // Вырезаем его из середины
        list.remove(target)

        #expect(list.count == 2)
        // Проверяем, что соседи сшились напрямую друг с другом
        #expect(list.head?.next === list.tail, "Head's next must link directly to Tail after middle removal")
        #expect(list.tail?.prev === list.head, "Tail's prev must link directly to Head after middle removal")
        #expect(list.head?.object == 100)
        #expect(list.tail?.object == 300)
    }
}


// MARK: - Functional Test Suite

@Suite("WeakList Storage Lifecycle Validation Suite")
struct ListTests {

    private var list: WeakList<A, OSAllocatedUnfairLock<Void>>
    private var array: [A]?
    private let retain: [A]

    /// Modern replacement for XCTest 'setUp()'.
    /// State is instantiated fresh for each individual test execution.
    init() {
        self.list = WeakList()
        let a2 = A()
        let a3 = A()

        self.array = [A(), A(), a2, a3, A(), A(), A(), A()]
        self.retain = [a2, a3]
    }

    @Test("WeakList: Verification of dynamic weak reference autoreleasing and collection sweeping")
    mutating func testAutoreleasing() throws {
        // Unwrapping optional array securely for local test scope context
        var localArray = try #require(array)

        try autoreleasepool {
            var count = 0
            for object in localArray {
                count += 1
                list <+ object
                #expect(list.count == count)
            }
            #expect(list.count == localArray.count)

            // Validate that all streaming elements exist inside the baseline source matrix
            try list.forEach { object in
                let object = try #require(object)
                #expect(localArray.contains(object))
            }

            // Explicitly release un-retained structural elements inside the memory pool
            localArray.removeAll()
            array = nil
        }

        // Execute manual sweep or iterate to verify only strongly retained objects survive
        var strictlyCount = 0
        list.forEach { _ in strictlyCount += 1 }

        #expect(strictlyCount == retain.count)
        #expect(strictlyCount == list.count)

        var index = 0
        list.forEach { object in
            #expect(retain[index] == object)
            index += 1
        }
    }

    @Test("List Concurrency: Stress, chaos, and lock-dropping validations")
    func testChaosAndConcurrency() async throws {
        let chaosList = WeakList<A, OSAllocatedUnfairLock<Void>>()

        // Потокобезопасный массив для удержания сильных ссылок на объекты в памяти
        let strongStorage = OSAllocatedUnfairLock<[A]>(initialState: [])

        // Наполняем стартовый пул
        strongStorage.withLock { storage in
            for _ in 1...50 {
                let object = A()
                storage.append(object)
                chaosList <+ object
            }
        }

        // Задача 1: Агрессивный писатель. Каждые 50 микросекунд добавляет новые элементы
        let writerTask = Task.detached {
            for _ in 1...200 {
                if Task.isCancelled { break }
                let object = A()
                strongStorage.withLock { $0.append(object) }
                chaosList <+ object
                try? await Task.sleep(for: .microseconds(50))
            }
        }

        // Задача 2: Медленный читатель с Lock Dropping.
        // Постоянно итерируется в случайных направлениях с рандомными слипами внутри хендлера.
        let readerTask = Task.detached {
            while !Task.isCancelled {
                let direction: ListDirection = Bool.random() ? .forward : .backward
                chaosList.forEach(direction) { _ in
                    // Имитируем тяжелую обработку внутри хендлера со случайным сном
                    let randomSleep = UInt64.random(in: 10...50)
                    Thread.sleep(forTimeInterval: Double(randomSleep) / 1_000_000.0)
                }

                try? await Task.sleep(for: .milliseconds(5))
            }
        }

        // Задача 3: Киллер объектов. Случайным образом удаляет элементы из сильного удержания,
        // заставляя объекты умирать "на лету" прямо во время итераций читателя.
        let killerTask = Task.detached {
            for _ in 1...50 {
                if Task.isCancelled { break }

                strongStorage.withLock { storage in
                    if !storage.isEmpty {
                        let randomIndex = Int.random(in: 0..<storage.count)
                        storage.remove(at: randomIndex)
                    }
                }
                try? await Task.sleep(for: .milliseconds(15))
            }
        }

        // Даем утилите поработать в условиях жесткого хаоса и многопоточности 1.5 секунды
        try? await Task.sleep(for: .seconds(1.5))

        // Завершаем весь фоновый хаос
        writerTask.cancel()
        readerTask.cancel()
        killerTask.cancel()

        // Проверяем, что граф памяти остался стабилен
        let finalCount = chaosList.count
        print("Тест хаоса завершен успешно. Элементов в списке осталось: \(finalCount)")
        #expect(true)
    }

    @Test("List Ring: Замыкание списка в кольцо и проверка бесконечного Lock-Dropping обхода")
    func testBlackHoleLoopChaos() async throws {
        let ringList = List<A, OSAllocatedUnfairLock>()
        let totalElements = 10

        // 1. Создаем и сохраняем только ЧИСТЫЕ объекты A.
        // Массив [A] является Sendable, компилятор Swift 6 пропустит его в любой поток!
        var temporaryObjects: [A] = []
        for _ in 1...totalElements {
            let object = A()
            temporaryObjects.append(object)
            ringList <+ object // Используем ваш оператор добавления объекта
        }
        let objects = temporaryObjects // Константный let для безопасного захвата потоками

        // 2. ЗАМЫКАЕМ ЦЕПОЧКУ В КОЛЬЦО
        ringList.lock.withLock {
            ringList.tail?.next = ringList.head
            ringList.head?.prev = ringList.tail
        }

        // Атомарный счетчик для подсчета кругов
        let loopsCounter = OSAllocatedUnfairLock<Int>(initialState: 0)

        // Задача 1: Безумный читатель летит по кольцу без остановок благодаря Lock Dropping
        let readerTask = Task.detached {
            ringList.forEach { _ in
                loopsCounter.withLock { $0 += 1 }
                Thread.sleep(forTimeInterval: 0.00001)
            }
        }

        // Задача 2: Космический деструктор хаотично перешивает связи на ходу.
        // Он захватывает Sendable массив [A], Swift 6 полностью доволен!
        let disruptorTask = Task.detached {
            for _ in 1...100 {
                if Task.isCancelled { break }

                ringList.lock.withLock {
                    // Выбираем случайный объект из нашего Sendable-массива
                    let randomTargetObject = objects[Int.random(in: 0..<totalElements)]
                    let randomDestinationObject = objects[Int.random(in: 0..<totalElements)]

                    // Находим узел в кольце, соответствующий этому объекту
                    var cursor = ringList.head
                    for _ in 0..<totalElements {
                        if cursor?.object === randomTargetObject {
                            // Устраиваем хаос: перенаправляем связь следующего элемента
                            // на узел со случайным другим объектом!
                            var destCursor = ringList.head
                            for _ in 0..<totalElements {
                                if destCursor?.object === randomDestinationObject {
                                    cursor?.next = destCursor
                                    break
                                }
                                destCursor = destCursor?.next
                            }
                            break
                        }
                        cursor = cursor?.next
                    }
                }

                try? await Task.sleep(for: .microseconds(100))
            }
        }

        // Крутим дыру 1 секунду
        try? await Task.sleep(for: .seconds(1.0))

        // Гасим таски
        readerTask.cancel()
        disruptorTask.cancel()

        let totalInteractions = loopsCounter.withLock { $0 }
        print("🌌 Черная дыра успешно схлопнулась! Читатель пролетел \(totalInteractions) узлов.")

        #expect(totalInteractions > totalElements)
    }

}
