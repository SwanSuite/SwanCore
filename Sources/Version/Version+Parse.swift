//
//  Version+Parse.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation

public extension Version {

    /// Parses any complex structured version string into a comprehensive, valid `Version` model instance.
    ///
    /// This intelligent parser uses sequential regular expression matching to safely extract semantic
    /// components, preventing common structural shifting bugs. It gracefully handles standard numbers,
    /// standalone build flags, and pre-release tag structures with either flat or separated iterations.
    ///
    /// ### Supported Input Layout Frameworks
    /// - **Standard Semantic**: `"1.2.3-beta.2"` -> `major: 1, minor: 2, patch: 3, identifier: .beta, version: 2`
    /// - **Flat Framework Branding**: `"v1.4rc3b12"` -> `major: 1, minor: 4, identifier: .releaseCandidate, version: 3, build: 12`
    /// - **Verbose Text**: `"version 2.0 (build 45)"` -> `major: 2, minor: 0, patch: nil, identifier: .release, build: 45`
    ///
    /// - Parameters:
    ///   - string: A raw version string container sequence compiled from bundle tags or external APIs.
    ///   - build: An optional string parameter that explicitly acts as an absolute override identifier for the technical compilation build field.
    /// - Returns: A fully synthesized `Version` instance reflecting the extracted semantic nodes.
    static func parse(_ string: String, build: String? = nil) -> Self? {
        // Регулярка ищет обязательную первую группу цифр ([0-9]+)
        let mainPattern = "^[a-zA-Z\\s:]*([0-9]+)(?:\\.([0-9]+))?(?:\\.([0-9]+))?(?:\\.([0-9]+))?(.*)"

        guard let regex = try? NSRegularExpression(pattern: mainPattern),
              nil != regex.firstMatch(in: string, range: NSRange(location: 0, length: (string as NSString).length)) else {
            // Если в строке вообще нет структуры версии (как в "not_a_version") — возвращаем nil!
            return nil
        }

        guard let regex = try? NSRegularExpression(pattern: mainPattern, options: [.caseInsensitive]) else {
            return .init(major: 0)
        }

        let nsString = string as NSString
        guard let match = regex.firstMatch(in: string, range: NSRange(location: 0, length: nsString.length)) else {
            return .init(major: 0)
        }

        // 1. Извлекаем базовые обязательные и опциональные числовые компоненты
        let major = UInt(nsString.substring(with: match.range(at: 1))) ?? 0

        var minor: UInt? = nil
        if match.range(at: 2).location != NSNotFound {
            minor = UInt(nsString.substring(with: match.range(at: 2)))
        }

        var patch: UInt? = nil
        if match.range(at: 3).location != NSNotFound {
            patch = UInt(nsString.substring(with: match.range(at: 3)))
        }

        // Четвертая группа цифр в старых форматах часто означала билд (например, 1.0.0.14)
        var buildComponent: UInt? = nil
        if match.range(at: 4).location != NSNotFound {
            buildComponent = UInt(nsString.substring(with: match.range(at: 4)))
        }

        // 2. Изолируем хвост строки для глубокого анализа предрелизов и маркеров сборки
        let suffixRange = match.range(at: 5)
        let suffix = suffixRange.location != NSNotFound ? nsString.substring(with: suffixRange).lowercased() : ""

        var preReleaseIdentifier: PreReleaseIdentifier = .release
        var preReleaseVersion: UInt? = nil

        // Поиск ключевых слов предрелиза в хвосте строки
        if suffix.contains("alpha") {
            preReleaseIdentifier = .alpha
        } else if suffix.contains("beta") {
            preReleaseIdentifier = .beta
        } else if suffix.contains("rc") || suffix.contains("releasecandidate") {
            preReleaseIdentifier = .releaseCandidate
        }

        // Если стадия предрелизная, выцепляем её числовую итерацию (поддерживает и rc3, и rc.3)
        if preReleaseIdentifier != .release {
            let prVersionPattern = "(?:alpha|beta|rc|releasecandidate)(?:\\.)?([0-9]+)"
            if let prRegex = try? NSRegularExpression(pattern: prVersionPattern),
               let prMatch = prRegex.firstMatch(in: suffix, range: NSRange(location: 0, length: (suffix as NSString).length)) {
                let numStr = (suffix as NSString).substring(with: prMatch.range(at: 1))
                preReleaseVersion = UInt(numStr)
            }
        }

        // Паттерн ищет: либо плюс, либо b/build, либо плюс с b/build, а затем группу цифр.
        let buildPattern = "(?:\\+|build|b)(?:\\s|\\.|build|b)*([0-9]+)"

        if let buildRegex = try? NSRegularExpression(pattern: buildPattern),
           let buildMatch = buildRegex.firstMatch(in: suffix, range: NSRange(location: 0, length: (suffix as NSString).length)) {
            let numStr = (suffix as NSString).substring(with: buildMatch.range(at: 1))
            buildComponent = UInt(numStr)
        }

        // Внешний переданный параметр build имеет наивысший приоритет
        if let buildOverride = build.flatMap(UInt.init) {
            buildComponent = buildOverride
        }

        return .init(
            major: major,
            minor: minor,
            patch: patch,
            preReleaseIdentifier: preReleaseIdentifier,
            preReleaseVersion: preReleaseVersion,
            build: buildComponent
        )
    }

    /// A shared thread-safe instance representing the active application host bundle runtime version metadata context.
    static let application: Self? = .parse(Bundle.appVersion, build: Bundle.appBuild)
}
