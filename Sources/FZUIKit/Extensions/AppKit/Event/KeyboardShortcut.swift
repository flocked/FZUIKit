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
    public var key: Key?
    
    static let none = Self(modifierFlags: [])
    
    /// The modifier keys that the user presses in conjunction with ``key` to activate the shortcut.
    public var modifierFlags: NSEvent.ModifierFlags = [] {
        didSet { modifierFlags = modifierFlags.monitor }
    }
    
    
    /// Creates a new keyboard shortcut with the given key and set of modifier flags.
    public init(key: Key, modifierFlags: NSEvent.ModifierFlags = []) {
        self.key = key
        self.modifierFlags = modifierFlags
    }
    
    /// Creates a keyboard shortcut with the specified modifier flags.
    public init(modifierFlags: NSEvent.ModifierFlags) {
        self.modifierFlags = modifierFlags
    }
    
    /// Creates a keyboard shortcut with the specified key equivalent and modifier flags.
    public init(keyEquivalent: String, modifierFlags: NSEvent.ModifierFlags = []) {
        self.key = Key(keyEquivalent: keyEquivalent) ?? Key(stringRepresentation: keyEquivalent)
        self.modifierFlags = modifierFlags
    }
    
    /// Creates a keyboard shortcut with the specified key equivalent.
    public init(stringLiteral value: String) {
        self = Self(keyEquivalent: value)
    }
    
    private init(key: Key?, modifierFlags: NSEvent.ModifierFlags) {
        self.key = key
        self.modifierFlags = modifierFlags
    }
    
    public init(nilLiteral: ()) {
        
    }
    
    private init(_ key: Key) {
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

    /// Apostrophe (')
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

extension KeyboardShortcut {
    /// The key of a shortcut.
    public struct Key: Hashable, ExpressibleByIntegerLiteral, CustomStringConvertible, Codable {
        /// The key code.
        public let rawValue: UInt16
        
        /// Creates a key with the specified key code.
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        /// Creates a key with the specified key code.
        public init(integerLiteral value: UInt16) {
            self.rawValue = value
        }
        
        public init?(keyEquivalent: String) {
            guard let key = Self.allCases.first(where: { $0.keyEquivalent == keyEquivalent }) else { return nil }
            self = key
        }
        
        public init?(stringRepresentation: String) {
            let string = stringRepresentation.lowercased()
            guard let key = Self.allCases.first(where: { key in key.stringRepresentations.contains(where: { $0.lowercased() == string}) }) else { return nil }
            self = key
        }
        
        private init(_ rawValue: Int) {
            self.rawValue = UInt16(rawValue)
        }
        
        /// A
        public static let a = Self(kVK_ANSI_A)
        /// B
        public static let b = Self(kVK_ANSI_B)
        /// C
        public static let c = Self(kVK_ANSI_C)
        /// D
        public static let d = Self(kVK_ANSI_D)
        /// E
        public static let e = Self(kVK_ANSI_E)
        /// F
        public static let f = Self(kVK_ANSI_F)
        /// G
        public static let g = Self(kVK_ANSI_G)
        /// H
        public static let h = Self(kVK_ANSI_H)
        /// I
        public static let i = Self(kVK_ANSI_I)
        /// J
        public static let j = Self(kVK_ANSI_J)
        /// K
        public static let k = Self(kVK_ANSI_K)
        /// L
        public static let l = Self(kVK_ANSI_L)
        /// M
        public static let m = Self(kVK_ANSI_M)
        /// N
        public static let n = Self(kVK_ANSI_N)
        /// O
        public static let o = Self(kVK_ANSI_O)
        /// P
        public static let p = Self(kVK_ANSI_P)
        /// Q
        public static let q = Self(kVK_ANSI_Q)
        /// R
        public static let r = Self(kVK_ANSI_R)
        /// S
        public static let s = Self(kVK_ANSI_S)
        /// T
        public static let t = Self(kVK_ANSI_T)
        /// U
        public static let u = Self(kVK_ANSI_U)
        /// V
        public static let v = Self(kVK_ANSI_V)
        /// W
        public static let w = Self(kVK_ANSI_W)
        /// X
        public static let x = Self(kVK_ANSI_X)
        /// Y
        public static let y = Self(kVK_ANSI_Y)
        /// Z
        public static let z = Self(kVK_ANSI_Z)
        
        /// 0
        public static let number0 = Self(kVK_ANSI_0)
        /// 1
        public static let number1 = Self(kVK_ANSI_1)
        /// 2
        public static let number2 = Self(kVK_ANSI_2)
        /// 3
        public static let number3 = Self(kVK_ANSI_3)
        /// 4
        public static let number4 = Self(kVK_ANSI_4)
        /// 5
        public static let number5 = Self(kVK_ANSI_5)
        /// 6
        public static let number6 = Self(kVK_ANSI_6)
        /// 7
        public static let number7 = Self(kVK_ANSI_7)
        /// 8
        public static let number8 = Self(kVK_ANSI_8)
        /// 9
        public static let number9 = Self(kVK_ANSI_9)
        
        /// Keypad 0
        public static let keypad0 = Self(kVK_ANSI_Keypad0)
        /// Keypad 1
        public static let keypad1 = Self(kVK_ANSI_Keypad1)
        /// Keypad 2
        public static let keypad2 = Self(kVK_ANSI_Keypad2)
        /// Keypad 3
        public static let keypad3 = Self(kVK_ANSI_Keypad3)
        /// Keypad 4
        public static let keypad4 = Self(kVK_ANSI_Keypad4)
        /// Keypad 5
        public static let keypad5 = Self(kVK_ANSI_Keypad5)
        /// Keypad 6
        public static let keypad6 = Self(kVK_ANSI_Keypad6)
        /// Keypad 7
        public static let keypad7 = Self(kVK_ANSI_Keypad7)
        /// Keypad 8
        public static let keypad8 = Self(kVK_ANSI_Keypad8)
        /// Keypad 9
        public static let keypad9 = Self(kVK_ANSI_Keypad9)
        /// Keypad Clear
        public static let keypadClear = Self(kVK_ANSI_KeypadClear)
        /// Keypad Divide
        public static let keypadDivide = Self(kVK_ANSI_KeypadDivide)
        /// Keypad Enter
        public static let keypadEnter = Self(kVK_ANSI_KeypadEnter)
        /// Keypad Equals
        public static let keypadEquals = Self(kVK_ANSI_KeypadEquals)
        /// Keypad Minus
        public static let keypadMinus = Self(kVK_ANSI_KeypadMinus)
        /// Keypad Plus
        public static let keypadPlus = Self(kVK_ANSI_KeypadPlus)
        /// Keypad Decimal (Dot)
        public static let keypadDecimal = Self(kVK_ANSI_KeypadDecimal)
        /// Keypad Multiply
        public static let keypadMultiply = Self(kVK_ANSI_KeypadMultiply)
        
        /// Page Down
        public static let pageDown = Self(kVK_PageDown)
        /// Page Up
        public static let pageUp = Self(kVK_PageUp)
        /// End
        public static let end = Self(kVK_End)
        /// Home
        public static let home = Self(kVK_Home)
        
        /// F1
        public static let f1 = Self(kVK_F1)
        /// F2
        public static let f2 = Self(kVK_F2)
        /// F3
        public static let f3 = Self(kVK_F3)
        /// F4
        public static let f4 = Self(kVK_F4)
        /// F5
        public static let f5 = Self(kVK_F5)
        /// F6
        public static let f6 = Self(kVK_F6)
        /// F7
        public static let f7 = Self(kVK_F7)
        /// F8
        public static let f8 = Self(kVK_F8)
        /// F9
        public static let f9 = Self(kVK_F9)
        /// F10
        public static let f10 = Self(kVK_F10)
        /// F11
        public static let f11 = Self(kVK_F11)
        /// F12
        public static let f12 = Self(kVK_F12)
        /// F13
        public static let f13 = Self(kVK_F13)
        /// F14
        public static let f14 = Self(kVK_F14)
        /// F15
        public static let f15 = Self(kVK_F15)
        /// F16
        public static let f16 = Self(kVK_F16)
        /// F17
        public static let f17 = Self(kVK_F17)
        /// F18
        public static let f18 = Self(kVK_F18)
        /// F19
        public static let f19 = Self(kVK_F19)
        /// F20
        public static let f20 = Self(kVK_F20)
        
        /// Apostrophe (')
        public static let apostrophe = Self(kVK_ANSI_Quote)
        /// Back Apostrophe (`)
        public static let backApostrophe = Self(kVK_ANSI_Grave)
        /// Backslash (\)
        public static let backslash = Self(kVK_ANSI_Backslash)
        /// Comma (,)
        public static let comma = Self(kVK_ANSI_Comma)
        /// Help
        public static let help = Self(kVK_Help)
        /// Forward Delete
        public static let forwardDelete = Self(kVK_ForwardDelete)
        /// Delete (Backspace)
        public static let delete = Self(kVK_Delete)
        /// Equals (=)
        public static let equals = Self(kVK_ANSI_Equal)
        /// Escape
        public static let escape = Self(kVK_Escape)
        /// Left Bracket ([)
        public static let leftBracket = Self(kVK_ANSI_LeftBracket)
        /// Minus (-)
        public static let minus = Self(kVK_ANSI_Minus)
        /// Period (.)
        public static let period = Self(kVK_ANSI_Period)
        /// Return / Enter
        public static let `return` = Self(kVK_Return)
        /// Right Bracket (])
        public static let rightBracket = Self(kVK_ANSI_RightBracket)
        /// Semicolon (;)
        public static let semicolon = Self(kVK_ANSI_Semicolon)
        /// Slash (/)
        public static let slash = Self(kVK_ANSI_Slash)
        /// Space
        public static let space = Self(kVK_Space)
        /// Tab
        public static let tab = Self(kVK_Tab)
        
        /// Down Arrow
        public static let arrowDown = Self(kVK_DownArrow)
        /// Left Arrow
        public static let arrowLeft = Self(kVK_LeftArrow)
        /// Right Arrow
        public static let arrowRight = Self(kVK_RightArrow)
        /// Up Arrow
        public static let arrowUp = Self(kVK_UpArrow)
        
        /// Enter / Return
        public static let enter = Self(kVK_Return)
                
        /// Mute
        public static let mute = Self(kVK_Mute)
        /// Volume Down
        public static let volumeDown = Self(kVK_VolumeDown)
        /// Volume Up
        public static let volumeUp = Self(kVK_VolumeUp)
        
        /// Command.
        public static let command = Self(kVK_Command)
        /// Shift.
        public static let shift = Self(kVK_Shift)
        /// Caps lock.
        public static let capsLock = Self(kVK_CapsLock)
        /// Option.
        public static let option = Self(kVK_Option)
        /// Control.
        public static let control = Self(kVK_Control)
        /// Right command.
        public static let rightCommand = Self(kVK_RightCommand)
        /// Right shift.
        public static let rightShift = Self(kVK_RightShift)
        /// Right option.
        public static let rightOption = Self(kVK_RightOption)
        /// Right control.
        public static let rightControl = Self(kVK_RightControl)
        /// Function.
        public static let function = Self(kVK_Function)
        
        static let modifierFlags: [Self] = [.command, .shift, .capsLock, .option, .control, .rightCommand, .rightShift, .rightOption, .rightControl, .function]
        
        /// A string representation of the key used for `NSMenuItem` and `NSButton` [keyEquivalent](https://developer.apple.com/documentation/appkit/nsmenuitem/keyequivalent).
        public var keyEquivalent: String? {
            switch self {
            // Letters
            case .a: return "a"
            case .b: return "b"
            case .c: return "c"
            case .d: return "d"
            case .e: return "e"
            case .f: return "f"
            case .g: return "g"
            case .h: return "h"
            case .i: return "i"
            case .j: return "j"
            case .k: return "k"
            case .l: return "l"
            case .m: return "m"
            case .n: return "n"
            case .o: return "o"
            case .p: return "p"
            case .q: return "q"
            case .r: return "r"
            case .s: return "s"
            case .t: return "t"
            case .u: return "u"
            case .v: return "v"
            case .w: return "w"
            case .x: return "x"
            case .y: return "y"
            case .z: return "z"
                
            // Numbers
            case .number0: return "0"
            case .number1: return "1"
            case .number2: return "2"
            case .number3: return "3"
            case .number4: return "4"
            case .number5: return "5"
            case .number6: return "6"
            case .number7: return "7"
            case .number8: return "8"
            case .number9: return "9"
                
            // Function keys
            case .f1: return String(unicodeInt: NSF1FunctionKey)
            case .f2: return String(unicodeInt: NSF2FunctionKey)
            case .f3: return String(unicodeInt: NSF3FunctionKey)
            case .f4: return String(unicodeInt: NSF4FunctionKey)
            case .f5: return String(unicodeInt: NSF5FunctionKey)
            case .f6: return String(unicodeInt: NSF6FunctionKey)
            case .f7: return String(unicodeInt: NSF7FunctionKey)
            case .f8: return String(unicodeInt: NSF8FunctionKey)
            case .f9: return String(unicodeInt: NSF9FunctionKey)
            case .f10: return String(unicodeInt: NSF10FunctionKey)
            case .f11: return String(unicodeInt: NSF11FunctionKey)
            case .f12: return String(unicodeInt: NSF12FunctionKey)
            case .f13: return String(unicodeInt: NSF13FunctionKey)
            case .f14: return String(unicodeInt: NSF14FunctionKey)
            case .f15: return String(unicodeInt: NSF15FunctionKey)
            case .f16: return String(unicodeInt: NSF16FunctionKey)
            case .f17: return String(unicodeInt: NSF17FunctionKey)
            case .f18: return String(unicodeInt: NSF18FunctionKey)
            case .f19: return String(unicodeInt: NSF19FunctionKey)
            case .f20: return String(unicodeInt: NSF20FunctionKey)
                
            // Special keys
            case .space: return " "
            case .delete: return String(unicodeInt: NSBackspaceCharacter)
            case .forwardDelete: return String(unicodeInt: NSDeleteCharacter)
            case .arrowLeft: return String(unicodeInt: NSLeftArrowFunctionKey)
            case .arrowRight: return String(unicodeInt: NSRightArrowFunctionKey)
            case .arrowUp: return String(unicodeInt: NSUpArrowFunctionKey)
            case .arrowDown: return String(unicodeInt: NSDownArrowFunctionKey)
            case .end: return String(unicodeInt: NSEndFunctionKey)
            case .home: return String(unicodeInt: NSHomeFunctionKey)
            case .escape: return String(unicodeInt: 0x1B) // Or "\u{1b}"
            case .pageDown: return String(unicodeInt: NSPageDownFunctionKey)
            case .pageUp: return String(unicodeInt: NSPageUpFunctionKey)
            case .return: return String(unicodeInt: NSCarriageReturnCharacter)
            case .enter: return String(unicodeInt: NSEnterCharacter)
            case .tab: return String(unicodeInt: NSTabCharacter)
            case .help: return String(unicodeInt: NSHelpFunctionKey)
                
            case .apostrophe: return "'"
            case .backApostrophe: return "`"
            case .backslash: return "\\"
            case .comma: return ","
            case .equals: return "="
            case .leftBracket: return "["
            case .minus: return "-"
            case .period: return "."
            case .rightBracket: return "]"
            case .semicolon: return ";"
            case .slash: return "/"
            case .keypadDecimal: return "."
            case .keypadEnter: return String(unicodeInt: NSEnterCharacter)
            case .keypadClear: return String(unicodeInt: NSClearDisplayFunctionKey)
            case .keypadMultiply: return "*"
            case .keypadPlus: return "+"
            case .keypadMinus: return "-"
            case .keypadDivide: return "/"
            case .keypadEquals: return "="
                
            case .keypad0: return "0"
            case .keypad1: return "1"
            case .keypad2: return "2"
            case .keypad3: return "3"
            case .keypad4: return "4"
            case .keypad5: return "5"
            case .keypad6: return "6"
            case .keypad7: return "7"
            case .keypad8: return "8"
            case .keypad9: return "9"
                
            default: return nil
            }
        }
        
        public static let allCases: [Self] = [.a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z, .number0, .number1, .number2, .number3, .number4, .number5, .number6, .number7, .number8, .number9, .keypad0, .keypad1, .keypad2, .keypad3, .keypad4, .keypad5, .keypad6, .keypad7, .keypad8, .keypad9, .keypadClear, .keypadDivide, .keypadEnter, .keypadEquals, .keypadMinus, .keypadPlus, .keypadDecimal, .keypadMultiply, .pageDown, .pageUp, .end, .home, .f1, .f2, .f3, .f4, .f5, .f6, .f7, .f8, .f9, .f10, .f11, .f12, .f13, .f14, .f15, .f16, .f17, .f18, .f19, .f20, .apostrophe, .backApostrophe, .backslash, .comma, .help, .forwardDelete, .delete, .equals, .escape, .leftBracket, .minus, .period, .return, .rightBracket, .semicolon, .slash, .space, .tab, .arrowDown, .arrowLeft, .arrowRight, .arrowUp, .enter, .mute, .volumeDown, .volumeUp]
        
        /// An array of string representations for the key.
        /// This can include official names, common abbreviations, and Unicode symbols.
        public var stringRepresentations: [String] {
            switch self {
            // Letters
            case .a: return ["a"]
            case .s: return ["s"]
            case .d: return ["d"]
            case .f: return ["f"]
            case .h: return ["h"]
            case .g: return ["g"]
            case .z: return ["z"]
            case .x: return ["x"]
            case .c: return ["c"]
            case .v: return ["v"]
            case .b: return ["b"]
            case .q: return ["q"]
            case .w: return ["w"]
            case .e: return ["e"]
            case .r: return ["r"]
            case .y: return ["y"]
            case .t: return ["t"]
            case .p: return ["p"]
            case .l: return ["l"]
            case .j: return ["j"]
            case .k: return ["k"]
            case .n: return ["n"]
            case .m: return ["m"]
            case .o: return ["o"]
            case .u: return ["u"]
            case .i: return ["i"]
                    
            // Numbers
            case .number0: return ["0", ")"]
            case .number1: return ["1", "!"]
            case .number2: return ["2", "@"]
            case .number3: return ["3", "#"]
            case .number4: return ["4", "$"]
            case .number5: return ["5", "%"]
            case .number6: return ["6", "^"]
            case .number7: return ["7", "&"]
            case .number8: return ["8", "*"]
            case .number9: return ["9", "("]
                    
            // Keypad
            case .keypad0: return ["keypad 0", "kp0", "0"]
            case .keypad1: return ["keypad 1", "kp1", "1"]
            case .keypad2: return ["keypad 2", "kp2", "2"]
            case .keypad3: return ["keypad 3", "kp3", "3"]
            case .keypad4: return ["keypad 4", "kp4", "4"]
            case .keypad5: return ["keypad 5", "kp5", "5"]
            case .keypad6: return ["keypad 6", "kp6", "6"]
            case .keypad7: return ["keypad 7", "kp7", "7"]
            case .keypad8: return ["keypad 8", "kp8", "8"]
            case .keypad9: return ["keypad 9", "kp9", "9"]
            case .keypadClear: return ["Clear", "kp_clear"]
            case .keypadDivide: return ["/", "kp_divide", "keypad slash"]
            case .keypadEnter: return ["Enter", "kp_enter", "keypad enter", "⏎"]
            case .keypadEquals: return ["=", "kp_equals", "keypad equals"]
            case .keypadMinus: return ["-", "kp_subtract", "keypad minus"]
            case .keypadPlus: return ["+", "kp_add", "keypad plus"]
            case .keypadDecimal: return [".", "kp_dec", "keypad decimal", "keypad dot"]
            case .keypadMultiply: return ["*", "kp_multiply", "keypad multiply"]

            // Function Keys
            case .f1: return ["F1"]
            case .f2: return ["F2"]
            case .f3: return ["F3"]
            case .f4: return ["F4"]
            case .f5: return ["F5"]
            case .f6: return ["F6"]
            case .f7: return ["F7"]
            case .f8: return ["F8"]
            case .f9: return ["F9"]
            case .f10: return ["F10"]
            case .f11: return ["F11"]
            case .f12: return ["F12"]
            case .f13: return ["F13"]
            case .f14: return ["F14"]
            case .f15: return ["F15"]
            case .f16: return ["F16"]
            case .f17: return ["F17"]
            case .f18: return ["F18"]
            case .f19: return ["F19"]
            case .f20: return ["F20"]

            // Special Keys
            case .space: return ["Space", "Spacebar", "␣"]
            case .delete: return ["Delete", "Backspace", "⌫"]
            case .forwardDelete: return ["Delete Forward", "⌦"]
            case .`return`: return ["Return", "Enter", "⏎", "↩"]
            case .tab: return ["Tab", "⇥"]
            case .escape: return ["Escape", "Esc", "⎋"]
            case .help: return ["Help", "?"]
            case .home: return ["Home", "↖"]
            case .end: return ["End", "↘"]
            case .pageUp: return ["Page Up", "PgUp", "⇞"]
            case .pageDown: return ["Page Down", "PgDn", "⇟"]
            case .arrowUp: return ["Up Arrow", "↑", "Up"]
            case .arrowDown: return ["Down Arrow", "↓", "Down"]
            case .arrowLeft: return ["Left Arrow", "←", "Left"]
            case .arrowRight: return ["Right Arrow", "→", "Right"]
                    
            // Punctuation & Symbols
            case .apostrophe: return ["'", "\""]
            case .backApostrophe: return ["`", "~"]
            case .backslash: return ["\\", "|"]
            case .comma: return [",", "<"]
            case .equals: return ["=", "+"]
            case .leftBracket: return ["[", "{"]
            case .minus: return ["-", "_"]
            case .period: return [".", ">"]
            case .rightBracket: return ["]", "}"]
            case .semicolon: return [";", ":"]
            case .slash: return ["/", "?"]

            // Media Keys
            case .mute: return ["Mute", "Mute Volume"]
            case .volumeDown: return ["Volume Down", "VolumeDown"]
            case .volumeUp: return ["Volume Up", "VolumeUp"]
            case .command, .rightCommand: return ["Command", "⌘"]
            case .shift, .rightShift: return ["Shift", "⇧"]
            case .option, .rightOption: return ["Option", "⌥"]
            case .control, .rightControl: return ["Control", "⌃"]
            case .function: return ["Function", "fn"]
            case .capsLock: return ["CapsLock", "⇪"]
            default: return []
            }
        }
        
        public var description: String {
            stringRepresentations.first ?? "raw: \(rawValue)"
        }
    }
}

fileprivate extension NSEvent.ModifierFlags {
    var monitor: Self {
        intersection([.shift, .control, .command, .numericPad, .help, .option, .function, .capsLock])
    }
}

fileprivate extension String {
    init(unicodeInt: Int) {
        self = String(format: "%C", unicodeInt)
    }
}

#endif
