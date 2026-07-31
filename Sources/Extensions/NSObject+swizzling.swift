//
//  NSObject+swizzling.swift
//  SwanCore
//
//  Created by Stanislav Pletnev on 2026-07-16.
//  Copyright © 2026 Anobisoft. Licensed under the MIT License.
//

import Foundation
import ObjectiveC

public extension NSObject {

    /// Exchanges the implementations of two instance methods (selectors) for this class environment profile at runtime.
    ///
    /// This utility wraps low-level Objective-C Runtime system APIs to perform Method Swizzling safely.
    /// It is commonly leveraged to inject custom behavior into system classes or hook dynamically into framework lifecycle events.
    ///
    /// - Parameters:
    ///   - origin: The selector pointing to the original method to be replaced.
    ///   - swizzl: The selector pointing to the new custom destination method to inject.
    ///
    /// - Note: Swizzling alters the shared method table for the target class globally. To prevent complex race conditions
    ///         and ensure system consistency, it is highly recommended to perform swizzling once and early in the
    ///         application lifecycle (e.g., inside application launch delegates or via thread-safe static initialization blocks).
    ///
    /// ### Example Usage:
    /// ```swift
    /// extension UIViewController {
    ///     static let swizzleViewWillAppear: Void = {
    ///         let original = #selector(viewWillAppear(_:))
    ///         let custom = #selector(custom_viewWillAppear(_:))
    ///         UIViewController.swizzle(original, custom)
    ///     }()
    /// }
    /// ```
    @inlinable
    static func swizzle(_ origin: Selector, _ swizzl: Selector) {
        guard
            let origin_method = class_getInstanceMethod(self, origin),
            let swizzl_method = class_getInstanceMethod(self, swizzl)
        else { return }
        method_exchangeImplementations(origin_method, swizzl_method)
    }
}
