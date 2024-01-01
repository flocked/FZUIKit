//
//  NSUIView+isEnabled.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// A type that can be enabled.
public protocol Enablable: NSUIView {
    /// A Boolean value that indicates whether the view is enabled.
    var isEnabled: Bool { get set }
}

extension NSUIView: Enablable {}

public extension Enablable where Self: NSUIView {
    /// A Boolean value that indicates whether the view is enabled.
    var isEnabled: Bool {
        get { !subviews.compactMap { $0.isEnabled }.contains(false) }
        set { subviews.forEach { $0.isEnabled = newValue }  }
    }
}

#endif
