//
//  NSView+KeybortShortcut.swift
//  
//
//  Created by Florian Zand on 11.04.25.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSButton {
    /// The button’s keyboard equivalent.
    public var keyboardShortcut: KeyboardShortcut {
        get { KeyboardShortcut(keyEquivalent, keyEquivalentModifierMask) }
        set {
            keyEquivalent = newValue.keyEquivalent
            keyEquivalentModifierMask = newValue.modifierFlags
        }
    }
    
    /// Sets the button’s keyboard equivalent.
    @discardableResult
    public func keyboardShortcut(_ shortcut: KeyboardShortcut) -> Self {
        keyboardShortcut = shortcut
        return self
    }
}

extension NSMenuItem {
    /// The menu item’s keyboard equivalent.
    public var keyboardShortcut: KeyboardShortcut {
        get { KeyboardShortcut(keyEquivalent, keyEquivalentModifierMask) }
        set {
            keyEquivalent = newValue.keyEquivalent
            keyEquivalentModifierMask = newValue.modifierFlags
        }
    }
    
    /// Sets the menu item’s keyboard equivalent.
    @discardableResult
    public func keyboardShortcut(_ shortcut: KeyboardShortcut) -> Self {
        keyboardShortcut = shortcut
        return self
    }
}
#endif
