//
//  ValidationToolbarItem.swift
//
//
//  Created by Florian Zand on 01.12.24.
//

#if os(macOS)
import AppKit

/// A toolbar item that validates.
open class ValidatableToolbarItem: NSToolbarItem {
    open override func validate() {
        if let control = self.view as? NSControl {
            let target: AnyObject
            if let action = self.action,
               let validator = NSApp.target(forAction: action, to: self.target, from: self) as AnyObject? {
                target = validator
            } else if let validator = control.target {
                target = validator
            } else {
                super.validate()
                return
            }
            
            let result: Bool
            if let target = target as? NSUserInterfaceValidations {
                result = target.validateUserInterfaceItem(self)
            } else {
                result = target.validateToolbarItem(self)
            }
            
            isEnabled = result
            control.isEnabled = result
        }
        
        super.validate()
        return
    }
}

/// A searchfield toolbar item that validates.
@available(OSX 11.0, *)
open class ValidatableSearchToolbarItem: NSSearchToolbarItem {

    open override func validate() {
        let target: AnyObject
        if let action = self.action,
           let validator = NSApp.target(forAction: action, to: self.target, from: self) as AnyObject? {
            target = validator
        } else if let validator = searchField.target {
            target = validator
        } else {
            super.validate()
            return
        }
        
        let result: Bool
        if let target = target as? NSUserInterfaceValidations {
            result = target.validateUserInterfaceItem(self)
        } else {
            result = target.validateToolbarItem(self)
        }
        
        isEnabled = result
        searchField.isEnabled = result
    }
}

/// A toolbar group item that validates.
open class ValidatableNSToolbarItemGroup: NSToolbarItemGroup {
    open override func validate() {
        if let control = self.view as? NSControl {
            let target: AnyObject
            if let action = self.action,
               let validator = NSApp.target(forAction: action, to: self.target, from: self) as AnyObject? {
                target = validator
            } else if let validator = control.target {
                target = validator
            } else {
                super.validate()
                return
            }
            
            let result: Bool
            if let target = target as? NSUserInterfaceValidations {
                result = target.validateUserInterfaceItem(self)
            } else {
                result = target.validateToolbarItem(self)
            }
            
            isEnabled = result
            control.isEnabled = result
            subitems.forEach({ $0.validate() })
        }
    }
}

#endif
