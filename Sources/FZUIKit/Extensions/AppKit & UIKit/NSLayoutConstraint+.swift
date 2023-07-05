//
//  NSLayoutConstraint+.swift
//  
//
//  Some parts are taken from https://github.com/boinx/BXUIKit
//  Copyright ©2018 Peter Baumgartner. All rights reserved.

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

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

    /// Updates the constant of the constraint and returns itself.
    @discardableResult func constant(_ constant: CGFloat) -> NSLayoutConstraint {
        self.constant = constant
        return self
    }
}

public extension Collection where Element: NSLayoutConstraint {
    /// Activates the constraints and returns itself.
    @discardableResult func activate() -> Self  {
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
