//
//  VersionFormatter.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

/// A high-performance, tokenized template compilation engine that formats
/// types conforming to ``VersionComponentProvider`` into stylized strings.
///
/// It utilizes structural character stream analysis to compile format strings into
/// an Abstract Syntax Tree (AST) at initialization time, ensuring optimal runtime layout execution.
public struct VersionFormatter: Sendable {

    /// The original raw format pattern string composition rules.
    public let format: String

    let astNodes: [AST.Node]

    /// Instantiates a structural formatting engine by compiling a tokenized design template.
    ///
    /// - Parameter format: A structured layout pattern string (e.g., `"v%MJ.%MN[.%P]"`).
    /// - Throws: A ``ValidationError`` if the pattern breaks layout rules or contains unbalanced brackets.
    public init(format: String) throws {
        self.format = format
        self.astNodes = try AST(format).nodes
    }

    // MARK: - Public Interface

    /// Translates a provider data container into a highly stylized text representation.
    ///
    /// - Parameter provider: Any model node instance exposing properties via the ``VersionComponentProvider`` interface.
    /// - Returns: A fully realized text layout string conforming to compiled format constraints.
    public func string(from provider: any VersionComponentProvider) -> String {
        return render(nodes: astNodes, from: provider)
    }
}

// MARK: - AST Tree Computation Renderer

private extension VersionFormatter {

    /// Linear node tree evaluator translating AST instructions into buffer allocations.
    func render(nodes: [AST.Node], from provider: any VersionComponentProvider) -> String {
        var outputBuffer = ""

        for node in nodes {
            switch node {
            case .text(let staticText):
                outputBuffer.append(staticText)

            case .token(let key):
                if let componentValue = provider.value(for: key) {
                    outputBuffer.append(componentValue.description)
                } else {
                    outputBuffer.append("0")
                }

            case .optionalBlock(let subNodes):
                if checkBlockActivity(subNodes, from: provider) {
                    outputBuffer.append(render(nodes: subNodes, from: provider))
                }

            case .select(let branches):
                // Evaluate each choice branch structure independently
                let matchingBranches = branches.filter { checkBlockActivity($0, from: provider) }

                // Strict One-Hot Validation rule: exactly one branch must be operational
                if matchingBranches.count == 1, let winningBranch = matchingBranches.first {
                    outputBuffer.append(render(nodes: winningBranch, from: provider))
                }
            }
        }

        return outputBuffer
    }

    /// Evaluates structural presence weights to decide whether an optional layer can survive (AND/OR logic).
    func checkBlockActivity(_ nodes: [AST.Node], from provider: any VersionComponentProvider) -> Bool {
        // Isolate immediately available tokens on the active structural level
        let localTokens = nodes.compactMap { node -> String? in
            if case .token(let tokenKey) = node { return tokenKey }
            return nil
        }

        if !localTokens.isEmpty {
            // ALL (AND) Strategy: All immediate flat tokens on this layer must actively exist (not nil)
            return localTokens.allSatisfy { provider.value(for: $0) != nil }
        } else {
            // ANY (OR) Strategy: Delegate active lifecycle authorization checks down to nested child nodes
            return nodes.contains { node in
                switch node {
                case .optionalBlock(let nestedNodes):
                    return checkBlockActivity(nestedNodes, from: provider)
                case .select(let subBranches):
                    return subBranches.contains { checkBlockActivity($0, from: provider) }
                default:
                    return false
                }
            }
        }
    }
}
