//
//  String+localizedDynamic.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-31.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation
import os

public extension String {
    @inlinable
    var localized: String {
        Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }

    func localized(_ bundle: Bundle = .main, value: String? = nil, table: String? = nil) -> String {
        bundle.localized(self, value: value, table: table)
    }

    func localized(
        _ bundle: Bundle = .main,
        value: String? = nil,
        table: String? = nil,
        locale: Locale = .current,
        with arguments: CVarArg...
    ) -> String {
        bundle.localized(self, value: value, table: table, locale: locale, with: arguments)
    }

    var localizedDynamic: String {
        localizedDynamic()
    }

    func localizedDynamic(value: String? = nil, table: String? = nil, with arguments: CVarArg...) -> String {
        return localized(.resolveBundle(), value: value, table: table, with: arguments)
    }
}

