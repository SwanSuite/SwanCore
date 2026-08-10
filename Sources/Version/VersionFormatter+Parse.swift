//
//  VersionFormatter+Parse.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

import Foundation

public extension VersionFormatter {

    /// Parses a target text stream matching the internal AST compiled schema configuration.
    ///
    /// - Parameter string: The raw text stream component to scan.
    /// - Returns: A token dictionary containing captured values, or `nil` if the structure breaks layout rules.
    func parse(_ string: String) -> [String: String]? {
        var remainder = string[...]
        var tokens: [String: String] = [:]

        guard matchAndExtract(nodes: astNodes, from: &remainder, into: &tokens) else { return nil }

        // Validation constraint: structural parser must consume the entire string sequence safely
        return remainder.isEmpty ? tokens : nil
    }

    // MARK: - Private Parser State Machine

    private func matchAndExtract(nodes: [AST.Node], from stream: inout Substring, into tokens: inout [String: String]) -> Bool {
        let rollbackStream = stream
        let rollbackTokens = tokens

        for node in nodes {
            switch node {
            case .text(let targetText):
                if stream.hasPrefix(targetText) {
                    stream.removeFirst(targetText.count)
                } else {
                    stream = rollbackStream; tokens = rollbackTokens
                    return false
                }

            case .token(let key):
                // Scan continuous characters until a delimiter or block boundary is reached
                var valueString = ""
                while let char = stream.first, char.isLetter || char.isNumber {
                    valueString.append(stream.removeFirst())
                }
                if valueString.isEmpty {
                    stream = rollbackStream; tokens = rollbackTokens
                    return false
                }
                tokens[key] = valueString

            case .optionalBlock(let subNodes):
                // Optional blocks are safe to fail; execution rolls back locally if unfulfilled
                var localStream = stream
                var localTokens = tokens
                if matchAndExtract(nodes: subNodes, from: &localStream, into: &localTokens) {
                    stream = localStream
                    tokens = localTokens
                }

            case .select(let branches):
                var branchMatched = false
                // Evaluate alternative choice paths using the exactly-one execution pattern
                for branch in branches {
                    var localStream = stream
                    var localTokens = tokens
                    if matchAndExtract(nodes: branch, from: &localStream, into: &localTokens), localStream.count < stream.count {
                        stream = localStream
                        tokens = localTokens
                        branchMatched = true
                        break
                    }
                }
                if !branchMatched {
                    stream = rollbackStream; tokens = rollbackTokens
                    return false
                }
            }
        }
        return true
    }
}

