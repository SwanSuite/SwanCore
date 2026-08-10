//
//  Bundle+UIKit.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-08-10.
//  Copyright © 2026 SwanSuite. Licensed under the MIT License.
//


#if os(iOS) || os(tvOS)

import UIKit

public extension Bundle {

    /// Dynamically resolves and retrieves the main system `Bundle` container instance associated with the native `UIKit` framework.
    ///
    /// This utility uses class-based reflection metadata lookup sequences targeting `UIApplication` to locate the native
    /// system framework resources. It serves as the core subsystem anchor required for automated system-level
    /// localization lookups (e.g., retrieving official system translations for buttons like "Cancel" or "Camera").
    ///
    /// ### Example Usage:
    /// ```swift
    /// let localizedCancel = "Cancel".localized(.UIKit)
    /// ```
    static let UIKit = Bundle(for: UIApplication.self)
}

#endif
