//
//  NSLayoutConstraint+.swift
//  
//
//  Some parts are taken from https://github.com/boinx/BXUIKit
//  Copyright ©2018 Peter Baumgartner. All rights reserved.

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

public extension NSLayoutAnchor where AnchorType == NSLayoutXAxisAnchor {
    /**
     Returns a constraint that defines one item’s attribute as equal to another item’s attribute plus a constant offset.
     
     - Parameters:
        - anchor: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an NSLayoutXAxisAnchor object, this parameter must be another NSLayoutXAxisAnchor.
        - multiplier: The multiplier of the constraint. The default value is `1.0`.
        - constant: The constant offset for the constraint.
        - priority: The priority of the constraint. The default value is `required`.
     
     - Returns: An `NSLayoutConstraint` object that defines an equal relationship between the attributes represented by the two layout anchors plus a constant offset.
     */
    func constraint(equalTo anchor: NSLayoutAnchor<AnchorType>, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0, priority: NSUILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor)
        return NSLayoutConstraint(
            item: constraint.firstItem!,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: multiplier,
            constant: constant
        ).priority(priority)
    }
}

extension NSLayoutAnchor where AnchorType == NSLayoutYAxisAnchor {
    /**
     Returns a constraint that defines one item’s attribute as equal to another item’s attribute plus a constant offset.
     
     - Parameters:
        - anchor: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an NSLayoutXAxisAnchor object, this parameter must be another NSLayoutXAxisAnchor.
        - multiplier: The multiplier of the constraint. The default value is `1.0`.
        - constant: The constant offset for the constraint.
        - priority: The priority of the constraint. The default value is `required`.

     - Returns: An `NSLayoutConstraint` object that defines an equal relationship between the attributes represented by the two layout anchors plus a constant offset.
     */
    func constraint(equalTo anchor: NSLayoutAnchor<AnchorType>, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0, priority: NSUILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor)
        return NSLayoutConstraint(
            item: constraint.firstItem!,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: multiplier,
            constant: constant
        ).priority(priority)
    }
}

public extension NSLayoutConstraint {
    /// Activates the constraint and returns itself.
    @discardableResult func activate() -> NSLayoutConstraint {
        return activate(true)
    }

    /// Updates the active state of the constraint and returns itself.
    @discardableResult func activate(_ active: Bool) -> NSLayoutConstraint {
        self.isActive = active
        return self
    }

    /// Updates the priority of the constraint and returns itself.
    @discardableResult func priority(_ priority: NSUILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    #if os(macOS)
    /// Updates the constant of the constraint and returns itself.
    @discardableResult func constant(_ constant: CGFloat, animated: Bool = false) -> NSLayoutConstraint {
        if animated {
            self.animator().constant = constant
        } else {
            self.constant = constant
        }
        return self
    }
    #elseif canImport(UIKit)
    /// Updates the constant of the constraint and returns itself.
    @discardableResult func constant(_ constant: CGFloat) -> NSLayoutConstraint {
        self.constant = constant
        return self
    }
    #endif
}

public extension Collection where Element: NSLayoutConstraint {
    /// Activates the constraints and returns itself.
    @discardableResult func activate() -> Self {
        self.forEach({ $0.activate() })
        return self
    }

    /// Updates the active state of the constraints and returns itself.
    @discardableResult func activate(_ active: Bool) -> Self {
        self.forEach({ $0.activate(active) })
        return self
    }

    /// Updates the priority of the constraints and returns itself.
    @discardableResult func priority(_ priority: NSUILayoutPriority) -> Self {
        self.forEach({$0.priority(priority) })
        return self
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ constant: CGFloat) -> Self {
        self.forEach({$0.constant(constant) })
        return self
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSUIEdgeInsets) -> Self {
        self.constant(insets.directional)
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSDirectionalEdgeInsets) -> Self {
        self.leading?.constant(insets.leading)
        self.trailing?.constant(-insets.trailing)
        self.bottom?.constant(-insets.bottom)
        self.top?.constant(insets.top)
        self.width?.constant(-insets.width)
        self.height?.constant(-insets.height)
        return self
    }

    /// Updates the width and height constraint's constant to the size and returns itself.
    @discardableResult func constant(_ size: CGSize) -> Self {
        self.width?.constant(size.width)
        self.height?.constant(size.height)
        return self
    }

    #if os(macOS)
    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ constant: CGFloat, animated: Bool) -> Self {
        self.forEach({$0.constant(constant, animated: animated) })
        return self
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSUIEdgeInsets, animated: Bool) -> Self {
        self.constant(insets.directional, animated: animated)
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSDirectionalEdgeInsets, animated: Bool) -> Self {
        self.leading?.constant(insets.leading, animated: animated)
        self.trailing?.constant(-insets.trailing, animated: animated)
        self.bottom?.constant(-insets.bottom, animated: animated)
        self.top?.constant(insets.top, animated: animated)
        self.width?.constant(-insets.width, animated: animated)
        self.height?.constant(-insets.height, animated: animated)
        return self
    }

    /// Updates the width and height constraint's constant to the size and returns itself.
    @discardableResult func constant(_ size: CGSize, animated: Bool) -> Self {
        self.width?.constant(size.width, animated: animated)
        self.height?.constant(size.height, animated: animated)
        return self
    }
    #endif

    /*
    var insets: NSDirectionalEdgeInsets {
        get {
            var newInsets = NSDirectionalEdgeInsets()
            newInsets.leading = self.leading?.constant ?? 0
            newInsets.trailing = -(self.trailing?.constant ?? 0)
            newInsets.bottom = -(self.bottom?.constant ?? 0)
            newInsets.top = self.top?.constant ?? 0
            newInsets.width = -(self.width?.constant ?? 0)
            newInsets.height = -(self.height?.constant ?? 0)
            return newInsets
        }
        set {
            self.leading?.constant(newValue.leading)
            self.trailing?.constant(-newValue.trailing)
            self.bottom?.constant(-newValue.bottom)
            self.top?.constant(newValue.top)
            self.width?.constant(-newValue.width)
            self.height?.constant(-newValue.height)
        }
    }
    */

    /// The leading or left constraint.
    var leading: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .leading || $0.firstAttribute == .left}) }

    /// The trailing or right constraint.
    var trailing: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .trailing || $0.firstAttribute == .right}) }

    /// The top constraint.
    var top: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .top}) }

    /// The bottom constraint.
    var bottom: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .bottom}) }

    /// The width constraint.
    var width: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .width}) }

    /// The height constraint.
    var height: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .height}) }

    /// The centerX constraint.
    var centerX: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .centerX}) }

    /// The centerY constraint.
    var centerY: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .centerY}) }

    /// The lastBaseline constraint.
    var lastBaseline: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .lastBaseline}) }

    /// The firstBaseline constraint.
    var firstBaseline: NSLayoutConstraint? { self.first(where: {$0.firstAttribute == .firstBaseline}) }
}
#endif
