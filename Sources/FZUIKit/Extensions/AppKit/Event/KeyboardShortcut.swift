//
//  KeyboardShortcut.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import Carbon

extension NSButton {
    /// The button’s keyboard equivalent.
    public var keyboardShortcut: KeyboardShortcut {
        get { KeyboardShortcut(keyEquivalent: keyEquivalent, modifierFlags: keyEquivalentModifierMask) }
        set {
            keyEquivalent = newValue.key?.keyEquivalent ?? ""
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
        get { KeyboardShortcut(keyEquivalent: keyEquivalent, modifierFlags: keyEquivalentModifierMask) }
        set {
            keyEquivalent = newValue.key?.keyEquivalent ?? ""
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

/// A keyboard shortcut.
public struct KeyboardShortcut: Hashable, ExpressibleByStringLiteral, ExpressibleByNilLiteral, CustomStringConvertible, Codable {
    /// The key equivalent that the user presses in conjunction with any specified modifier keys to activate the shortcut.
    public var key: NSEvent.Key?
    
    static let none = Self(modifierFlags: [])
    
    /// The modifier keys that the user presses in conjunction with ``key` to activate the shortcut.
    public var modifierFlags: NSEvent.ModifierFlags = [] {
        didSet { modifierFlags = modifierFlags.monitor }
    }
    
    
    /// Creates a new keyboard shortcut with the given key and set of modifier flags.
    public init(key: NSEvent.Key, modifierFlags: NSEvent.ModifierFlags = []) {
        self.key = key
        self.modifierFlags = modifierFlags
    }
    
    /// Creates a keyboard shortcut with the specified modifier flags.
    public init(modifierFlags: NSEvent.ModifierFlags) {
        self.modifierFlags = modifierFlags
    }
    
    /// Creates a keyboard shortcut with the specified key equivalent and modifier flags.
    public init(keyEquivalent: String, modifierFlags: NSEvent.ModifierFlags = []) {
        self.key = NSEvent.Key(keyEquivalent: keyEquivalent) ??  NSEvent.Key(stringRepresentation: keyEquivalent)
        self.modifierFlags = modifierFlags
    }
    
    /// Creates a keyboard shortcut with the specified key equivalent.
    public init(stringLiteral value: String) {
        self = Self(keyEquivalent: value)
    }
    
    private init(key: NSEvent.Key?, modifierFlags: NSEvent.ModifierFlags) {
        self.key = key
        self.modifierFlags = modifierFlags
    }
    
    public init(nilLiteral: ()) {
        
    }
    
    private init(_ key: NSEvent.Key) {
        self.key = key
    }
    
    public var description: String {
        let keyString = key != nil ? "\(key!.description)" : "-"
        let flagsString = "\(modifierFlags)"
        return "(\(keyString), \(flagsString))"
    }
    
    func isMatching(_ event: NSEvent) -> Bool {
        event.keyCode == key?.rawValue ?? event.keyCode && event.modifierFlags.monitor == modifierFlags
    }
    
    func isMatching(_ event: CGEvent) -> Bool {
        event.keyCode == key?.rawValue ?? UInt16(event.keyCode) && event.flags.modifierFlags == modifierFlags
    }
    
    public static func + (lhs: Self, rhs: NSEvent.ModifierFlags) -> Self {
        Self(key: lhs.key, modifierFlags: lhs.modifierFlags + rhs)
    }
    
    public static func + (lhs: inout Self, rhs: NSEvent.ModifierFlags) {
        lhs.modifierFlags.insert(rhs)
    }

    // MARK: - Letters

    /// A
    public static let a = Self(.a)
    /// B
    public static let b = Self(.b)
    /// C
    public static let c = Self(.c)
    /// D
    public static let d = Self(.d)
    /// E
    public static let e = Self(.e)
    /// F
    public static let f = Self(.f)
    /// G
    public static let g = Self(.g)
    /// H
    public static let h = Self(.h)
    /// I
    public static let i = Self(.i)
    /// J
    public static let j = Self(.j)
    /// K
    public static let k = Self(.k)
    /// L
    public static let l = Self(.l)
    /// M
    public static let m = Self(.m)
    /// N
    public static let n = Self(.n)
    /// O
    public static let o = Self(.o)
    /// P
    public static let p = Self(.p)
    /// Q
    public static let q = Self(.q)
    /// R
    public static let r = Self(.r)
    /// S
    public static let s = Self(.s)
    /// T
    public static let t = Self(.t)
    /// U
    public static let u = Self(.u)
    /// V
    public static let v = Self(.v)
    /// W
    public static let w = Self(.w)
    /// X
    public static let x = Self(.x)
    /// Y
    public static let y = Self(.y)
    /// Z
    public static let z = Self(.z)

    // MARK: - Numbers

    /// 0
    public static let number0 = Self(.number0)
    /// 1
    public static let number1 = Self(.number1)
    /// 2
    public static let number2 = Self(.number2)
    /// 3
    public static let number3 = Self(.number3)
    /// 4
    public static let number4 = Self(.number4)
    /// 5
    public static let number5 = Self(.number5)
    /// 6
    public static let number6 = Self(.number6)
    /// 7
    public static let number7 = Self(.number7)
    /// 8
    public static let number8 = Self(.number8)
    /// 9
    public static let number9 = Self(.number9)

    // MARK: - Keypad

    /// Keypad 0
    public static let keypad0 = Self(.keypad0)
    /// Keypad 1
    public static let keypad1 = Self(.keypad1)
    /// Keypad 2
    public static let keypad2 = Self(.keypad2)
    /// Keypad 3
    public static let keypad3 = Self(.keypad3)
    /// Keypad 4
    public static let keypad4 = Self(.keypad4)
    /// Keypad 5
    public static let keypad5 = Self(.keypad5)
    /// Keypad 6
    public static let keypad6 = Self(.keypad6)
    /// Keypad 7
    public static let keypad7 = Self(.keypad7)
    /// Keypad 8
    public static let keypad8 = Self(.keypad8)
    /// Keypad 9
    public static let keypad9 = Self(.keypad9)
    /// Keypad Clear
    public static let keypadClear = Self(.keypadClear)
    /// Keypad Divide
    public static let keypadDivide = Self(.keypadDivide)
    /// Keypad Enter
    public static let keypadEnter = Self(.keypadEnter)
    /// Keypad Equals
    public static let keypadEquals = Self(.keypadEquals)
    /// Keypad Minus
    public static let keypadMinus = Self(.keypadMinus)
    /// Keypad Plus
    public static let keypadPlus = Self(.keypadPlus)
    /// Decimal (keypad .)
    public static let keypadDecimal = Self(.keypadDecimal)
    /// Multiply (keypad *)
    public static let keypadMultiply = Self(.keypadMultiply)

    // MARK: - Function Keys

    /// F1
    public static let f1 = Self(.f1)
    /// F2
    public static let f2 = Self(.f2)
    /// F3
    public static let f3 = Self(.f3)
    /// F4
    public static let f4 = Self(.f4)
    /// F5
    public static let f5 = Self(.f5)
    /// F6
    public static let f6 = Self(.f6)
    /// F7
    public static let f7 = Self(.f7)
    /// F8
    public static let f8 = Self(.f8)
    /// F9
    public static let f9 = Self(.f9)
    /// F10
    public static let f10 = Self(.f10)
    /// F11
    public static let f11 = Self(.f11)
    /// F12
    public static let f12 = Self(.f12)
    /// F13
    public static let f13 = Self(.f13)
    /// F14
    public static let f14 = Self(.f14)
    /// F15
    public static let f15 = Self(.f15)
    /// F16
    public static let f16 = Self(.f16)
    /// F17
    public static let f17 = Self(.f17)
    /// F18
    public static let f18 = Self(.f18)
    /// F19
    public static let f19 = Self(.f19)
    /// F20
    public static let f20 = Self(.f20)

    // MARK: - Symbols and Punctuation

    /// Apostrophe / quote  (')
    public static let apostrophe = Self(.apostrophe)
    /// Back Apostrophe (`)
    public static let backApostrophe = Self(.backApostrophe)
    /// Backslash (\)
    public static let backslash = Self(.backslash)
    /// Comma (,)
    public static let comma = Self(.comma)
    /// Delete (Backspace)
    public static let delete = Self(.delete)
    /// Equals (=)
    public static let equals = Self(.equals)
    /// Escape
    public static let escape = Self(.escape)
    /// Left Bracket ([)
    public static let leftBracket = Self(.leftBracket)
    /// Minus (-)
    public static let minus = Self(.minus)
    /// Period (.)
    public static let period = Self(.period)
    /// Return / Enter
    public static let `return` = Self(.return)
    /// Right Bracket (])
    public static let rightBracket = Self(.rightBracket)
    /// Semicolon (;)
    public static let semicolon = Self(.semicolon)
    /// Slash (/)
    public static let slash = Self(.slash)
    /// Space
    public static let space = Self(.space)
    /// Tab
    public static let tab = Self(.tab)

    // MARK: - Navigation

    /// Page Down
    public static let pageDown = Self(.pageDown)
    /// Page Up
    public static let pageUp = Self(.pageUp)
    /// End
    public static let end = Self(.end)
    /// Home
    public static let home = Self(.home)
    /// Arrow Down
    public static let arrowDown = Self(.arrowDown)
    /// Arrow Left
    public static let arrowLeft = Self(.arrowLeft)
    /// Arrow Right
    public static let arrowRight = Self(.arrowRight)
    /// Arrow Up
    public static let arrowUp = Self(.arrowUp)

    // MARK: - System

    /// Forward Delete
    public static let forwardDelete = Self(.forwardDelete)
    /// Help
    public static let help = Self(.help)
    /// Mute
    public static let mute = Self(.mute)
    /// Volume Down
    public static let volumeDown = Self(.volumeDown)
    /// Volume Up
    public static let volumeUp = Self(.volumeUp)
    /// Enter / Return
    public static let enter = Self(.enter)
    
    /// Section Sign (§)
    public static let sectionSign = Self(.sectionSign)
    /// Apostrophe / quote  (')
    public static let quote = Self(.quote)
    
    // MARK: - Modifier Flags
    
    /// Shift.
    public static let shift = Self(modifierFlags: .shift)
    /// Command.
    public static let command = Self(modifierFlags: .command)
    /// Option.
    public static let option = Self(modifierFlags: .option)
    /// Caps lock.
    public static let capsLock = Self(modifierFlags: .capsLock)
    /// Function.
    public static let function = Self(modifierFlags: .function)
    /// Numeric pad.
    public static let numericPad = Self(modifierFlags: .numericPad)
}

fileprivate extension NSEvent.ModifierFlags {
    var monitor: Self {
        intersection([.shift, .control, .command, .numericPad, .help, .option, .function, .capsLock])
    }
}

#endif
