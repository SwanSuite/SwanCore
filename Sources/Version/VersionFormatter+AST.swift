//
//  VersionFormatter+AST.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//

extension VersionFormatter {
    /// Critical validation errors triggered during template syntax compilation.
    enum ValidationError: Error, CustomStringConvertible {
        /// Occurs when square brackets `[...]` are mismatched, unclosed, or orphaned.
        case unbalancedBrackets

        /// Occurs when an invalid token name configuration is provided after a `%` character.
        case invalidToken(String)

        public var description: String {
            switch self {
            case .unbalancedBrackets:
                return "Format compilation failed: Unbalanced or unclosed square brackets detected."
            case .invalidToken(let token):
                return "Format compilation failed: Invalid or unsupported token identifier '\(token)'."
            }
        }
    }
}

extension VersionFormatter {

    struct AST {
        /// Structural node element representations inside the pre-compiled template tree hierarchy.
        indirect enum Node: Sendable {
            /// Represents structural static text, including custom words, spacers, symbols, and punctuation.
            case text(String)

            /// Represents a key token string mapping dynamically to a component provider descriptor value.
            case token(String)

            /// Represents an optional boundary block evaluated via collective hierarchical presence metrics (AND/OR).
            case optionalBlock([Node])

            /// Represents a mutually exclusive selection framework executing the exactly-one choice sequence.
            case select([[Node]])
        }

        private var stream: [Character]
        private var index = 0

        /// The pre-compiled sequence of structural instructions for rapid linear evaluation.
        var nodes: [Node] = []

        init(_ format: String) throws {
            self.stream = Array(format)
            self.nodes = try processLevel(isNested: false)
            stream = []
        }


        /// Iterates through characters to build an array of nodes on the current nesting level.
        mutating func processLevel(isNested: Bool) throws -> [Node] {
            var segments: [[Node]] = [[]]
            var buffer = ""

            /// Flushes accumulated characters into a text node block.
            func flushBuffer() {
                if !buffer.isEmpty {
                    segments[segments.count - 1].append(.text(buffer))
                    buffer = ""
                }
            }

            while index < stream.count {
                let char = stream[index]

                switch char {
                case "[":
                    flushBuffer()
                    index += 1
                    let nestedBlockNodes = try processLevel(isNested: true)
                    segments[segments.count - 1].append(.optionalBlock(nestedBlockNodes))

                case "]":
                    if !isNested { throw ValidationError.unbalancedBrackets }
                    flushBuffer()
                    index += 1
                    return segments.count > 1 ? [.select(segments)] : segments.first~!

                case "|":
                    if !isNested {
                        buffer.append(char)
                        index += 1
                    } else {
                        flushBuffer()
                        index += 1
                        segments.append([])
                    }

                case "%":
                    flushBuffer()
                    index += 1

                    var tokenKey = ""
                    while index < stream.count && stream[index].isUppercase {
                        tokenKey.append(stream[index])
                        index += 1
                    }

                    if tokenKey.isEmpty { throw ValidationError.invalidToken("%") }
                    segments[segments.count - 1].append(.token(tokenKey))

                default:
                    buffer.append(char)
                    index += 1
                }
            }

            if isNested { throw ValidationError.unbalancedBrackets }
            flushBuffer()
            return segments.count > 1 ? [.select(segments)] : segments.first~!
        }
    }
}
