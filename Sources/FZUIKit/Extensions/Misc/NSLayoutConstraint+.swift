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
    func constraint(equalTo anchor: NSLayoutAnchor<AnchorType>, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0, priority: NSUILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: constant).priority(priority).multiplier(multiplier)
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
    func constraint(equalTo anchor: NSLayoutAnchor<AnchorType>, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0, priority: NSUILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: constant).priority(priority).multiplier(multiplier)
    }
}

extension NSLayoutAnchor where AnchorType == NSLayoutDimension {
    /**
     Returns a constraint that defines one item’s attribute as equal to another item’s attribute plus a constant offset.

     - Parameters:
        - anchor: A layout anchor from a `UIView`, `NSView`, or `UILayoutGuide` object. You must use a subclass of NSLayoutAnchor that matches the current anchor. For example, if you call this method on an NSLayoutXAxisAnchor object, this parameter must be another NSLayoutXAxisAnchor.
        - multiplier: The multiplier of the constraint. The default value is `1.0`.
        - constant: The constant offset for the constraint.
        - priority: The priority of the constraint. The default value is `required`.

     - Returns: An `NSLayoutConstraint` object that defines an equal relationship between the attributes represented by the two layout anchors plus a constant offset.
     */
    func constraint(equalTo anchor: NSLayoutAnchor<AnchorType>, constant: CGFloat = 0.0, multiplier: CGFloat = 1.0, priority: NSUILayoutPriority = .required) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: constant).priority(priority).multiplier(multiplier)
    }
}

public extension NSLayoutConstraint {
    /// Sets the name that identifies the constraint.
    @discardableResult func identifier(_ identifier: String?) -> NSLayoutConstraint {
        self.identifier = identifier
        return self
    }

    /// Activates the constraint and returns itself.
    @discardableResult func activate() -> NSLayoutConstraint {
        activate(true)
    }

    /// Updates the active state of the constraint and returns itself.
    @discardableResult func activate(_ active: Bool) -> NSLayoutConstraint {
        isActive = active
        return self
    }

    /// Updates the priority of the constraint and returns itself.
    @discardableResult func priority(_ priority: NSUILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    /// Updates the constant of the constraint and returns itself.
    @discardableResult func constant(_ constant: CGFloat) -> NSLayoutConstraint {
        self.constant = constant
        return self
    }

    #if os(macOS)
    /// Updates the constant of the constraint and returns itself.
    @discardableResult func constant(_ constant: CGFloat, animated: Bool) -> NSLayoutConstraint {
        if animated {
            animator().constant = constant
        } else {
            self.constant = constant
        }
        return self
    }
    #endif

    /// Sets the constant multiplied with the attribute on the right side of the constraint as part of getting the modified attribute.
    @discardableResult
    func multiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        guard self.multiplier != multiplier, let firstItem = firstItem, secondItem != nil else { return self }
        let constraint = NSLayoutConstraint(item: firstItem, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant).priority(priority)
        let isActive = isActive
        self.isActive = false
        constraint.isActive = isActive
        return constraint
    }
}

extension NSUILayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: Float) {
        self.init(value)
    }
    
    public init(integerLiteral value: Int) {
        self.init(Float(value))
    }
}

public extension Collection where Element: NSLayoutConstraint {
    /// Activates the constraints and returns itself.
    @discardableResult func activate() -> Self {
        forEach { $0.activate() }
        return self
    }

    /// Updates the active state of the constraints and returns itself.
    @discardableResult func activate(_ active: Bool) -> Self {
        forEach { $0.activate(active) }
        return self
    }

    /// Updates the priority of the constraints and returns itself.
    @discardableResult func priority(_ priority: NSUILayoutPriority) -> Self {
        forEach { $0.priority(priority) }
        return self
    }

    /// Updates the constant multiplied with the attribute on the right side of the constraint as part of getting the modified attribute.
    @discardableResult func multiplier(_ multiplier: CGFloat) -> Self {
        forEach { $0.multiplier(multiplier) }
        return self
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ constant: CGFloat) -> Self {
        forEach { $0.constant(constant) }
        return self
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSUIEdgeInsets) -> Self {
        constant(insets.directional)
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSDirectionalEdgeInsets) -> Self {
        for constraint in self {
            switch constraint.firstAttribute {
            case .leading, .left: constraint.constant(insets.leading)
            case .trailing, .right: constraint.constant(-insets.trailing)
            case .top: constraint.constant(insets.top)
            case .bottom: constraint.constant(-insets.bottom)
            case .width: constraint.constant(-insets.width)
            case .height: constraint.constant(-insets.height)
            default: break
            }
        }
        return self
    }

    /// Updates the width and height constraint's constant to the size and returns itself.
    @discardableResult func constant(_ size: CGSize) -> Self {
        for constraint in self {
            switch constraint.firstAttribute {
            case .width: constraint.constant(size.width)
            case .height: constraint.constant(size.height)
            default: break
            }
        }
        return self
    }

    #if os(macOS)
    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ constant: CGFloat, animated: Bool) -> Self {
        forEach { $0.constant(constant, animated: animated) }
        return self
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSUIEdgeInsets, animated: Bool) -> Self {
        constant(insets.directional, animated: animated)
    }

    /// Updates the constant of the constraints and returns itself.
    @discardableResult func constant(_ insets: NSDirectionalEdgeInsets, animated: Bool) -> Self {
        for constraint in self {
            switch constraint.firstAttribute {
            case .leading, .left: constraint.constant(insets.leading, animated: animated)
            case .trailing, .right: constraint.constant(-insets.trailing, animated: animated)
            case .top: constraint.constant(insets.top, animated: animated)
            case .bottom: constraint.constant(-insets.bottom, animated: animated)
            case .width: constraint.constant(-insets.width, animated: animated)
            case .height: constraint.constant(-insets.height, animated: animated)
            default: break
            }
        }
        return self
    }

    /// Updates the width and height constraint's constant to the size and returns itself.
    @discardableResult func constant(_ size: CGSize, animated: Bool) -> Self {
        for constraint in self {
            switch constraint.firstAttribute {
            case .width: constraint.constant(size.width, animated: animated)
            case .height: constraint.constant(size.height, animated: animated)
            default: break
            }
        }
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
    var leading: NSLayoutConstraint? { first(where: { $0.firstAttribute == .leading || $0.firstAttribute == .left }) }

    /// The trailing or right constraint.
    var trailing: NSLayoutConstraint? { first(where: { $0.firstAttribute == .trailing || $0.firstAttribute == .right }) }

    /// The top constraint.
    var top: NSLayoutConstraint? { first(where: { $0.firstAttribute == .top }) }

    /// The bottom constraint.
    var bottom: NSLayoutConstraint? { first(where: { $0.firstAttribute == .bottom }) }

    /// The width constraint.
    var width: NSLayoutConstraint? { first(where: { $0.firstAttribute == .width }) }

    /// The height constraint.
    var height: NSLayoutConstraint? { first(where: { $0.firstAttribute == .height }) }

    /// The centerX constraint.
    var centerX: NSLayoutConstraint? { first(where: { $0.firstAttribute == .centerX }) }

    /// The centerY constraint.
    var centerY: NSLayoutConstraint? { first(where: { $0.firstAttribute == .centerY }) }

    /// The firstBaseline constraint.
    var firstBaseline: NSLayoutConstraint? { first(where: { $0.firstAttribute == .firstBaseline }) }

    /// The lastBaseline constraint.
    var lastBaseline: NSLayoutConstraint? { first(where: { $0.firstAttribute == .lastBaseline }) }

    /// The leading or left constraints.
    internal var leadings: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .leading || $0.firstAttribute == .left })
    }

    /// The trailing or right constraints.
    internal var trailings: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .trailing || $0.firstAttribute == .right })
    }

    /// The top constraints.
    internal var tops: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .top })
    }

    /// The bottom constraints.
    internal var bottoms: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .bottom })
    }

    /// The width constraints.
    internal var widths: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .width })
    }

    /// The height constraints.
    internal var heights: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .height })
    }

    /// The centerX constraints.
    internal var centerXs: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .centerX })
    }

    /// The centerY constraints.
    internal var centerYs: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .centerY })
    }

    /// The firstBaseline constraints.
    internal var firstBaselines: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .firstBaseline })
    }

    /// The lastBaseline constraints.
    internal var lastBaselines: [NSLayoutConstraint] {
        filter({ $0.firstAttribute == .lastBaseline })
    }
}
#endif
