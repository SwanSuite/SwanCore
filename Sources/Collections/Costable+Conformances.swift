//
//  Costable+Conformances.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-17.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

// MARK: - String

extension String: Costable {

    /// Returns the precise memory cost of the string layout based on its total UTF-8 byte count.
    public var cost: Int {
        utf8.count
    }
}

// MARK: - Array

extension Array: Costable {

    /// Returns the true uncompressed byte memory footprint allocated by the array sequence buffer in RAM.
    public var cost: Int {
        count * MemoryLayout<Element>.stride
    }
}

// MARK: - Dictionary

extension Dictionary: Costable {

    /// Returns the true uncompressed byte memory footprint allocated by the dictionary storage bucket tree in RAM.
    public var cost: Int {
        count * (MemoryLayout<Key>.stride + MemoryLayout<Value>.stride)
    }
}

// MARK: - Data

extension Data: Costable {

    /// Returns the exact layout size of the binary data buffer frame in bytes.
    public var cost: Int {
        count
    }
}

extension NSData: Costable {

    /// Automatically returns the underlying byte length memory footprint as its allocation cost metric.
    public var cost: Int {
        length
    }
}
