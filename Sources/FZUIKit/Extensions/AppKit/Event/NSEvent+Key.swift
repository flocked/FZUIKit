//
//  NSEvent+Key.swift
//  FZUIKit
//
//  Created by Florian Zand on 22.05.26.
//

#if os(macOS)
import AppKit
import Carbon
import FZSwiftUtils

public extension NSEvent {
    /// The key associated with the event.
    var key: Key? {
        guard type == .keyDown || type == .keyUp else { return nil }
        return Key(rawValue: keyCode)
    }
    
    /// The key of a shortcut.
    struct Key: Hashable, ExpressibleByIntegerLiteral, CustomStringConvertible, Codable {
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
        
        /// Creates a key with the specified key equivalent.
        public init?(keyEquivalent: String) {
            guard !keyEquivalent.isEmpty else { return nil }
            guard let key = Self.allCases.first(where: { $0.keyEquivalent == keyEquivalent }) else { return nil }
            self = key
        }
        
        /// Creates a key with the specified string representation.
        public init?(stringRepresentation: String) {
            guard !stringRepresentation.isEmpty else { return nil }
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
        
        /// Apostrophe / quote  (')
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
        /// Section Sign (§)
        public static let sectionSign = Self(kVK_ISO_Section)
        /// Apostrophe / quote  (')
        public static let quote = Self.apostrophe
        
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
            case .sectionSign: return "§"
                
            default: return nil
            }
        }
        
        public static let allCases: [Self] = [.a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z, .number0, .number1, .number2, .number3, .number4, .number5, .number6, .number7, .number8, .number9, .keypad0, .keypad1, .keypad2, .keypad3, .keypad4, .keypad5, .keypad6, .keypad7, .keypad8, .keypad9, .keypadClear, .keypadDivide, .keypadEnter, .keypadEquals, .keypadMinus, .keypadPlus, .keypadDecimal, .keypadMultiply, .pageDown, .pageUp, .end, .home, .f1, .f2, .f3, .f4, .f5, .f6, .f7, .f8, .f9, .f10, .f11, .f12, .f13, .f14, .f15, .f16, .f17, .f18, .f19, .f20, .apostrophe, .backApostrophe, .backslash, .comma, .help, .forwardDelete, .delete, .equals, .escape, .leftBracket, .minus, .period, .return, .rightBracket, .semicolon, .slash, .space, .tab, .arrowDown, .arrowLeft, .arrowRight, .arrowUp, .enter, .mute, .volumeDown, .volumeUp, .sectionSign]
        
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
            case .sectionSign: return ["§"]
            default: return []
            }
        }
        
        public var description: String {
            stringRepresentations.first ?? "raw: \(rawValue)"
        }
    }
}

/*
/// The key of an event.
public struct Key: RawRepresentable, Equatable, CustomStringConvertible, CaseIterable, Hashable, Codable, ExpressibleByIntegerLiteral {
    
    public let rawValue: UInt16
    
    /// 0
    public static let number0 = Self(29)
    /// 1
    public static let number1 = Self(18)
    /// 2
    public static let number2 = Self(19)
    /// 3
    public static let number3 = Self(20)
    /// 4
    public static let number4 = Self(21)
    /// 5
    public static let number5 = Self(23)
    /// 6
    public static let number6 = Self(22)
    /// 7
    public static let number7 = Self(26)
    /// 8
    public static let number8 = Self(28)
    /// 9
    public static let number9 = Self(25)
    
    /// A
    public static let a = Self(0)
    /// B
    public static let b = Self(11)
    /// C
    public static let c = Self(8)
    /// D
    public static let d = Self(2)
    /// E
    public static let e = Self(14)
    /// F
    public static let f = Self(3)
    /// G
    public static let g = Self(5)
    /// H
    public static let h = Self(4)
    /// I
    public static let i = Self(34)
    /// J
    public static let j = Self(38)
    /// K
    public static let k = Self(40)
    /// L
    public static let l = Self(37)
    /// M
    public static let m = Self(46)
    /// N
    public static let n = Self(45)
    /// O
    public static let o = Self(31)
    /// P
    public static let p = Self(35)
    /// Q
    public static let q = Self(12)
    /// R
    public static let r = Self(15)
    /// S
    public static let s = Self(1)
    /// T
    public static let t = Self(17)
    /// U
    public static let u = Self(32)
    /// V
    public static let v = Self(9)
    /// W
    public static let w = Self(13)
    /// X
    public static let x = Self(7)
    /// Y
    public static let y = Self(16)
    /// Z
    public static let z = Self(6)
    
    /// Section Sign
    public static let sectionSign = Self(10)
    
    /// Back apostrophe / Grave.
    public static let grave = Self(50)
    
    /// Minus
    public static let minus = Self(27)
    
    /// Equal
    public static let equals = Self(24)
    
    /// Left Square Bracket
    public static let leftSquareBracket = Self(33)
    
    /// Right Square Bracket
    public static let rightSquareBracket = Self(30)
    
    /// Semicolon
    public static let semicolon = Self(41)
    
    /// Quote / Apostrophe.
    public static let quote = Self(39)
    
    /// Comma
    public static let comma = Self(43)
    
    /// Period
    public static let period = Self(47)
    
    /// Slash
    public static let slash = Self(44)
    
    /// Backslash
    public static let backslash = Self(42)
    
    /// Keypad 0
    public static let keypad0 = Self(82)
    /// Keypad 1
    public static let keypad1 = Self(83)
    /// Keypad 2
    public static let keypad2 = Self(84)
    /// Keypad 3
    public static let keypad3 = Self(85)
    /// Keypad 4
    public static let keypad4 = Self(86)
    /// Keypad 5
    public static let keypad5 = Self(87)
    /// Keypad 6
    public static let keypad6 = Self(88)
    /// Keypad 7
    public static let keypad7 = Self(89)
    /// Keypad 8
    public static let keypad8 = Self(91)
    /// Keypad 9
    public static let keypad9 = Self(92)
    
    /// Keypad Decimal
    public static let keypadDecimal = Self(65)
    
    /// Keypad Multiply
    public static let keypadMultiply = Self(67)
    
    /// Keypad Plus
    public static let keypadPlus = Self(69)
    
    /// Keypad Divide
    public static let keypadDivide = Self(75)
    
    /// Keypad Minus
    public static let keypadMinus = Self(78)
    
    /// Keypad Equals
    public static let keypadEquals = Self(81)
    
    /// Keypad Clear
    public static let keypadClear = Self(71)
    
    /// Keypad Enter
    public static let keypadEnter = Self(76)
    
    /// Space
    public static let space = Self(49)
    
    /// Enter
    public static let enter = Self(36)
    
    /// Tab
    public static let tab = Self(48)
    
    /// Delete
    public static let delete = Self(51)
    
    /// Forward Delete
    public static let forwardDelete = Self(117)
    
    /// Linefeed
    public static let linefeed = Self(52)
    
    /// Escape
    public static let escape = Self(53)
    
    /// Command
    public static let command = Self(55)
    
    /// Shift
    public static let shift = Self(56)
    
    /// CapsLock
    public static let capsLock = Self(57)
    
    /// Option
    public static let option = Self(58)
    
    /// Control
    public static let control = Self(59)
    
    /// Right Shift
    public static let rightShift = Self(60)
    
    /// Right Option
    public static let rightOption = Self(61)
    
    /// Right Control
    public static let rightControl = Self(62)
    
    /// Right Control
    public static let rightCommand = Self(54)
    
    /// Right Command.
    public static let function = Self(63)
    
    /// F1
    public static let f1 = Self(122)
    /// F2
    public static let f2 = Self(120)
    /// F3
    public static let f3 = Self(99)
    /// F4
    public static let f4 = Self(118)
    /// F5
    public static let f5 = Self(96)
    /// F6
    public static let f6 = Self(97)
    /// F7
    public static let f7 = Self(98)
    /// F8
    public static let f8 = Self(100)
    /// F9
    public static let f9 = Self(101)
    /// F10
    public static let f10 = Self(109)
    /// F11
    public static let f11 = Self(103)
    /// F12
    public static let f12 = Self(111)
    /// F13
    public static let f13 = Self(105)
    /// F14
    public static let f14 = Self(107)
    /// F15
    public static let f15 = Self(113)
    /// F16
    public static let f16 = Self(106)
    /// F17
    public static let f17 = Self(64)
    /// F18
    public static let f18 = Self(79)
    /// F19
    public static let f19 = Self(80)
    /// F20
    public static let f20 = Self(90)
    
    /// Volume Up
    public static let volumeUp = Self(72)
    
    /// Volume Down
    public static let volumeDown = Self(73)
    
    /// Mute
    public static let mute = Self(74)
    
    /// Insert Help
    public static let insertHelp = Self(114)
    
    /// Home
    public static let home = Self(115)
    
    /// End
    public static let end = Self(119)
    
    /// Page Up
    public static let pageUp = Self(116)
    
    /// Page Down
    public static let pageDown = Self(121)
    
    /// Arrow Left
    public static let arrowLeft = Self(123)
    
    /// Arrow Right
    public static let arrowRight = Self(124)
    
    /// Arrow Down
    public static let arrowDown = Self(125)
    
    /// Arrow Up
    public static let arrowUp = Self(126)
    
    /// Power
    public static let power = Self(127)
    
    /// 0
    public static let d0 = Self.number0
    /// 1
    public static let d1 = Self.number1
    /// 2
    public static let d2 = Self.number2
    /// 3
    public static let d3 = Self.number3
    /// 4
    public static let d4 = Self.number4
    /// 5
    public static let d5 = Self.number5
    /// 6
    public static let d6 = Self.number6
    /// 7
    public static let d7 = Self.number7
    /// 8
    public static let d8 = Self.number8
    /// 9
    public static let d9 = Self.number9
    /// Quote / Apostrophe.
    public static let apostrophe = Self.quote
    /// Back apostrophe / Grave.
    public static let backApostrophe = Self.grave
    
    /*
    /// JIS yen.
    public static let jis_Yen = Self(93)
    /// JIS underscore.
    public static let jis_Underscore = Self(94)
    /// JIS keypad comma.
    public static let jis_KeypadComma = Self(95)
    /// JIS keypad eisu.
    public static let jis_Eisu = Self(102)
    /// JIS keypad kena.
    public static let jis_Kena = Self(104)
     */
    
    public static let allCases: [Self] = [.number0, .number1, .number2, .number3, .number4, .number5, .number6, .number7, .number8, .number9, .a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z, .sectionSign, .grave, .minus, .equals, .leftSquareBracket, .rightSquareBracket, .semicolon, .quote, .comma, .period, .slash, .backslash, .keypad0, .keypad1, .keypad2, .keypad3, .keypad4, .keypad5, .keypad6, .keypad7, .keypad8, .keypad9, .keypadDecimal, .keypadMultiply, .keypadPlus, .keypadDivide, .keypadMinus, .keypadEquals, .keypadClear, .keypadEnter, .space, .enter, .tab, .delete, .forwardDelete, .linefeed, .escape, .command, .shift, .capsLock, .option, .control, .rightShift, .rightOption, .rightControl, .rightCommand, .function, .f1, .f2, .f3, .f4, .f5, .f6, .f7, .f8, .f9, .f10, .f11, .f12, .f13, .f14, .f15, .f16, .f17, .f18, .f19, .f20, .volumeUp, .volumeDown, .mute, .insertHelp, .home, .end, .pageUp, .pageDown, .arrowLeft, .arrowRight, .arrowDown, .arrowUp, .power]
    
    public var description: String {
        characters.main
    }
    
    public var characters: (main: String, secondary: String?) {
        switch self {
        case .number0: return ("0", "}")
        case .number1: return ("1", "!")
        case .number2: return ("2", "⌫")
        case .number3: return ("3", "♯")
        case .number4: return ("4", "$")
        case .number5: return ("5", "%")
        case .number6: return ("6", "^")
        case .number7: return ("7", "&")
        case .number8: return ("8", "*")
        case .number9: return ("9", "{")
        case .a: return ("a", "A")
        case .b: return ("b", "B")
        case .c: return ("c", "C")
        case .d: return ("d", "D")
        case .e: return ("e", "E")
        case .f: return ("f", "F")
        case .g: return ("g", "G")
        case .h: return ("h", "H")
        case .i: return ("i", "I")
        case .j: return ("j", "J")
        case .k: return ("k", "K")
        case .l: return ("l", "L")
        case .m: return ("m", "M")
        case .n: return ("n", "N")
        case .o: return ("o", "O")
        case .p: return ("p", "P")
        case .q: return ("q", "Q")
        case .r: return ("r", "R")
        case .s: return ("s", "S")
        case .t: return ("t", "T")
        case .u: return ("u", "U")
        case .v: return ("v", "V")
        case .w: return ("w", "W")
        case .x: return ("x", "X")
        case .y: return ("y", "Y")
        case .z: return ("z", "Z")
        case .sectionSign: return ("§", nil)
        case .grave: return ("`", "∼")
        case .minus: return ("-", "_")
        case .equals: return ("=", "+")
        case .leftSquareBracket: return ("[", "{")
        case .rightSquareBracket: return ("]", "}")
        case .semicolon: return (";", ":")
        case .quote: return ("'", "\"")
        case .comma: return (",", "<")
        case .period: return (".", ">")
        case .slash: return ("/", "?")
        case .backslash: return ("\\", "|")
        case .keypad0: return ("Keypad0", nil)
        case .keypad1: return ("Keypad1", nil)
        case .keypad2: return ("Keypad2", nil)
        case .keypad3: return ("Keypad3", nil)
        case .keypad4: return ("Keypad4", nil)
        case .keypad5: return ("Keypad5", nil)
        case .keypad6: return ("Keypad6", nil)
        case .keypad7: return ("Keypad7", nil)
        case .keypad8: return ("Keypad8", nil)
        case .keypad9: return ("Keypad9", nil)
        case .keypadDecimal: return ("KeyPadDecimal", nil)
        case .keypadMultiply: return ("KeypadMultiply", "*")
        case .keypadPlus: return ("KeypadPlus", "+")
        case .keypadDivide: return ("KeypadDivide", "/")
        case .keypadMinus: return ("KeypadMinus", "-")
        case .keypadEquals: return ("KeypadEquals", "=")
        case .keypadClear: return ("KeypadClear", nil)
        case .keypadEnter: return ("KeypadEnter", "⌤")
        case .space: return ("Space", "␣")
        case .enter: return ("Enter", "⏎")
        case .tab: return ("Tab", "⇥")
        case .delete: return ("Delete", "⌦")
        case .forwardDelete: return ("ForwardDelete", "⌫")
        case .linefeed: return ("Linefeed", nil)
        case .escape: return ("Escape", "⎋")
        case .command: return ("Command", "⌘")
        case .shift: return ("Shift", "⇧")
        case .capsLock: return ("CapsLock", "⇪")
        case .option: return ("Option", "⌥")
        case .control: return ("Control", "⌃")
        case .rightShift: return ("RightShift", nil)
        case .rightOption: return ("RightOption", nil)
        case .rightControl: return ("RightControl", nil)
        case .rightCommand: return ("rightCommand", nil)
        case .function: return ("Function", "fn")
        case .f1: return ("F1", nil)
        case .f2: return ("F2", nil)
        case .f3: return ("F3", nil)
        case .f4: return ("F4", nil)
        case .f5: return ("F5", nil)
        case .f6: return ("F6", nil)
        case .f7: return ("F7", nil)
        case .f8: return ("F8", nil)
        case .f9: return ("F9", nil)
        case .f10: return ("F10", nil)
        case .f11: return ("F11", nil)
        case .f12: return ("F12", nil)
        case .f13: return ("F13", nil)
        case .f14: return ("F14", nil)
        case .f15: return ("F15", nil)
        case .f16: return ("F16", nil)
        case .f17: return ("F17", nil)
        case .f18: return ("F18", nil)
        case .f19: return ("F19", nil)
        case .f20: return ("F20", nil)
        case .volumeUp: return ("VolumeUp", nil)
        case .volumeDown: return ("VolumeDown", nil)
        case .mute: return ("Mute", nil)
        case .insertHelp: return ("Insert/Help", nil)
        case .home: return ("Home", "↖")
        case .end: return ("End", "↘")
        case .pageUp: return ("PageUp", "⇞")
        case .pageDown: return ("PageDown", "⇟")
        case .arrowLeft: return ("ArrowLeft", "←")
        case .arrowRight: return ("ArrowRight", "→")
        case .arrowDown: return ("ArrowDown", "↓")
        case .arrowUp: return ("ArrowUp", "↑")
        case .power: return ("Power", nil)
        default: return ("\(rawValue)", nil)
        }
    }
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    public init?(characters: String) {
        guard let key = Self.allCases.first(where: { $0.characters.main == characters })
            ?? Self.allCases.first(where: { $0.characters.secondary == characters })
        else {
            return nil
        }
        
        self = key
    }
    
    public init(integerLiteral value: UInt16) {
        self.rawValue = value
    }
}
*/

fileprivate extension String {
    init(unicodeInt: Int) {
        self = String(format: "%C", unicodeInt)
    }
}
#endif
