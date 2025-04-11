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

public struct KeyboardShortcut: ExpressibleByNilLiteral, ExpressibleByStringLiteral {
    /// The key-equivalent character.
    public var keyEquivalent: String = ""
    
    /// The keyboard equivalent modifiers.
    public var modifierFlags: NSEvent.ModifierFlags = []

    /// a
    public static let a = Self("a")
    /// b
    public static let b = Self("b")
    /// c
    public static let c = Self("c")
    /// d
    public static let d = Self("d")
    /// e
    public static let e = Self("e")
    /// f
    public static let f = Self("f")
    /// g
    public static let g = Self("g")
    /// h
    public static let h = Self("h")
    /// i
    public static let i = Self("i")
    /// j
    public static let j = Self("j")
    /// k
    public static let k = Self("k")
    /// l
    public static let l = Self("l")
    /// m
    public static let m = Self("m")
    /// n
    public static let n = Self("n")
    /// o
    public static let o = Self("o")
    /// p
    public static let p = Self("p")
    /// q
    public static let q = Self("q")
    /// r
    public static let r = Self("r")
    /// s
    public static let s = Self("s")
    /// t
    public static let t = Self("t")
    /// u
    public static let u = Self("u")
    /// v
    public static let v = Self("v")
    /// w
    public static let w = Self("w")
    /// x
    public static let x = Self("x")
    /// y
    public static let y = Self("y")
    /// z
    public static let z = Self("z")

    /// 0
    public static let zero = Self("0")
    /// 1
    public static let one = Self("1")
    /// 2
    public static let two = Self("2")
    /// 3
    public static let three = Self("3")
    /// 4
    public static let four = Self("4")
    /// 5
    public static let five = Self("5")
    /// 6
    public static let six = Self("6")
    /// 7
    public static let seven = Self("7")
    /// 8
    public static let eight = Self("8")
    /// 9
    public static let nine = Self("9")

    /// Space
    public static let space = Self(" ")
    /// Return/Enter
    public static let returnKey = Self("\r") // or "\n"
    /// Tab
    public static let tab = Self("\t")
    /// Delete/Backspace
    public static let delete = Self("\u{8}")
    /// Escape
    public static let escape = Self("\u{1B}")
    /// Arrow up
    public static let upArrow = Self("\u{F700}")
    /// Arrow down
    public static let downArrow = Self("\u{F701}")
    /// Arrow left
    public static let leftArrow = Self("\u{F702}")
    /// Arrow right
    public static let rightArrow = Self("\u{F703}")
    /// Plus
    public static let plus = Self("+")
    /// Minus
    public static let minus = Self("-")
    /// Equals
    public static let equals = Self("=")
    /// Period
    public static let period = Self(".")
    /// Comma
    public static let comma = Self(",")
    /// Slash
    public static let slash = Self("/")
    /// Backslash
    public static let backslash = Self("\\")
    /// Semicolon
    public static let semicolon = Self(";")
    /// Quote
    public static let quote = Self("'")
    /// Open bracket
    public static let openBracket = Self("[")
    /// Close bracket
    public static let closeBracket = Self("]")
    /// Backtick/Grave
    public static let backtick = Self("`")
    /// Less than
    public static let lessThan = Self("<")
    /// Greater than
    public static let greaterThan = Self(">")

    /// F1
    public static let f1 = Self("\u{F704}")
    /// F2
    public static let f2 = Self("\u{F705}")
    /// F3
    public static let f3 = Self("\u{F706}")
    /// F4
    public static let f4 = Self("\u{F707}")
    /// F5
    public static let f5 = Self("\u{F708}")
    /// F6
    public static let f6 = Self("\u{F709}")
    /// F7
    public static let f7 = Self("\u{F70A}")
    /// F8
    public static let f8 = Self("\u{F70B}")
    /// F9
    public static let f9 = Self("\u{F70C}")
    /// F10
    public static let f10 = Self("\u{F70D}")
    /// F11
    public static let f11 = Self("\u{F70E}")
    /// F12
    public static let f12 = Self("\u{F70F}")
    
    /// No keyboard shortcut.
    public static let none = Self("")
    
    public init(keyEquivalent: String, modifierFlags: NSEvent.ModifierFlags = []) {
        self.keyEquivalent = keyEquivalent
        self.modifierFlags = modifierFlags
    }
    
    public init(stringLiteral value: String) {
        self = Self(keyEquivalent: value)
    }
    
    public init(nilLiteral: ()) {
        
    }
    
    public static func + (lhs: Self, rhs: NSEvent.ModifierFlags) -> Self {
        .init(keyEquivalent: lhs.keyEquivalent, modifierFlags: lhs.modifierFlags + rhs)
    }

    init(_ keyEquivalent: String, _ flags: NSEvent.ModifierFlags = []) {
        self.keyEquivalent = keyEquivalent
        self.modifierFlags = flags
    }
}

#endif
