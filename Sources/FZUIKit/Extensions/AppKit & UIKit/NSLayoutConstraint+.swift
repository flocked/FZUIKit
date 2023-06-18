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
    
    @discardableResult func activate() -> NSLayoutConstraint {
        return activate(true)
    }

    @discardableResult func activate(_ active: Bool) -> NSLayoutConstraint {
        self.isActive = active
        return self
    }
    
    @discardableResult func priority(_ priority: NSUILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    @discardableResult func constant(_ c: CGFloat) -> NSLayoutConstraint {
        self.constant = c
        return self
    }

}
