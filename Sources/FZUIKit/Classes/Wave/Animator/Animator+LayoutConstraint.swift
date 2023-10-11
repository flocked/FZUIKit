//
//  Animator+LayoutConstraint.swift
//
//
//  Created by Florian Zand on 29.09.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSLayoutConstraint: Animatable { }

extension Animator where Object: NSLayoutConstraint {
    /// The constant of the layout constraint.
    public var constant: CGFloat {
        get { value(for: \.constant) }
        set { setValue(newValue, for: \.constant) }
    }
}

#endif
