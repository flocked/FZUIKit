//
//  NSEvent+KeyCode.swift
//
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)

import AppKit
import Carbon
import Foundation

public extension NSEvent {
    static func keyCode(for string: String) -> (keyCode: UInt16, shift: Bool)? {
        if let found = NSEventKeyCodeMapping.first(where: { $0.value == string }) {
            return (keyCode: UInt16(found.key), shift: false)
        } else if let found = KeyCodeMapping.first(where: { $0.value.0 == string || $0.value.1 == string }) {
            if found.value.0 == string {
                return (keyCode: found.key, shift: false)
            } else {
                return (keyCode: found.key, shift: true)
            }
        }
        return nil
    }

    var readableModifierFlags: String {
        modifierFlags.description
    }

    var readableModifierFlagsCompact: String {
        modifierFlags.debugDescription
    }

    /// The key associated with the event.
    var key: Key? {
        guard type == .keyDown || type == .keyUp else { return nil }
        return Key(rawValue: keyCode)
    }

    var readableKeyCode: String {
        let rawKeyCharacter: String
        if let char = NSEvent.NSEventKeyCodeMapping[Int(keyCode)] {
            rawKeyCharacter = char
        } else {
            let inputSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource().takeUnretainedValue()
            if let layoutData = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData) {
                let dataRef = unsafeBitCast(layoutData, to: CFData.self)
                let keyLayout = unsafeBitCast(CFDataGetBytePtr(dataRef), to: UnsafePointer<UCKeyboardLayout>.self)
                var deadKeyState = UInt32(0)
                let maxLength = 4
                var actualLength = 0
                var actualString = [UniChar](repeating: 0, count: maxLength)
                let error = UCKeyTranslate(keyLayout,
                                           UInt16(keyCode),
                                           UInt16(kUCKeyActionDisplay),
                                           UInt32((0 >> 8) & 0xFF),
                                           UInt32(LMGetKbdType()),
                                           OptionBits(kUCKeyTranslateNoDeadKeysBit),
                                           &deadKeyState,
                                           maxLength,
                                           &actualLength,
                                           &actualString)
                if error == 0 {
                    rawKeyCharacter = String(utf16CodeUnits: &actualString, count: maxLength).uppercased()
                } else {
                    rawKeyCharacter = NSEvent.KeyCodeMapping[keyCode]?.0 ?? ""
                }
            } else {
                rawKeyCharacter = NSEvent.KeyCodeMapping[keyCode]?.0 ?? ""
            }
        }

        return rawKeyCharacter
    }
}


public extension NSEvent {
    static let NSEventKeyCodeMapping: [Int: String] = [
        kVK_F1: "F1",
        kVK_F2: "F2",
        kVK_F3: "F3",
        kVK_F4: "F4",
        kVK_F5: "F5",
        kVK_F6: "F6",
        kVK_F7: "F7",
        kVK_F8: "F8",
        kVK_F9: "F9",
        kVK_F10: "F10",
        kVK_F11: "F11",
        kVK_F12: "F12",
        kVK_F13: "F13",
        kVK_F14: "F14",
        kVK_F15: "F15",
        kVK_F16: "F16",
        kVK_F17: "F17",
        kVK_F18: "F18",
        kVK_F19: "F19",
        kVK_Space: "␣",
        kVK_Escape: "⎋",
        kVK_Delete: "⌦",
        kVK_ForwardDelete: "⌫",
        kVK_LeftArrow: "←",
        kVK_RightArrow: "→",
        kVK_UpArrow: "↑",
        kVK_DownArrow: "↓",
        kVK_Help: "",
        kVK_PageUp: "⇞",
        kVK_PageDown: "⇟",
        kVK_Tab: "⇥",
        kVK_Return: "⏎",
        kVK_ANSI_Keypad0: "0",
        kVK_ANSI_Keypad1: "1",
        kVK_ANSI_Keypad2: "2",
        kVK_ANSI_Keypad3: "3",
        kVK_ANSI_Keypad4: "4",
        kVK_ANSI_Keypad5: "5",
        kVK_ANSI_Keypad6: "6",
        kVK_ANSI_Keypad7: "7",
        kVK_ANSI_Keypad8: "8",
        kVK_ANSI_Keypad9: "9",
        kVK_ANSI_KeypadDecimal: ".",
        kVK_ANSI_KeypadMultiply: "*",
        kVK_ANSI_KeypadPlus: "+",
        kVK_ANSI_KeypadClear: "Clear",
        kVK_ANSI_KeypadDivide: "/",
        kVK_ANSI_KeypadEnter: "↩︎",
        kVK_ANSI_KeypadMinus: "-",
        kVK_ANSI_KeypadEquals: "=",
    ]

    fileprivate static let KeyCodeMapping: [UInt16: (String, String?)] = [
        0x00: ("a", "A"),
        0x01: ("s", "S"),
        0x02: ("d", "D"),
        0x03: ("f", "F"),
        0x04: ("h", "H"),
        0x05: ("g", "G"),
        0x06: ("z", "Z"),
        0x07: ("x", "X"),
        0x08: ("c", "C"),
        0x09: ("v", "V"),
        0x0B: ("b", "B"),
        0x0C: ("q", "Q"),
        0x0D: ("w", "W"),
        0x0E: ("e", "E"),
        0x0F: ("r", "R"),
        0x10: ("y", "Y"),
        0x11: ("t", "T"),
        0x12: ("1", "!"),
        0x13: ("2", "@"),
        0x14: ("3", "SHARP"),
        0x15: ("4", "$"),
        0x16: ("6", "^"),
        0x17: ("5", "%"),
        0x18: ("=", "+"),
        0x19: ("9", "("),
        0x1A: ("7", "&"),
        0x1B: ("-", "_"),
        0x1C: ("8", "*"),
        0x1D: ("0", ")"),
        0x1E: ("]", "}"),
        0x1F: ("o", "O"),
        0x20: ("u", "U"),
        0x21: ("[", "{"),
        0x22: ("i", "I"),
        0x23: ("p", "P"),
        0x25: ("l", "L"),
        0x26: ("j", "J"),
        0x27: ("'", "\""),
        0x28: ("k", "K"),
        0x29: (";", ":"),
        0x2A: ("\\", "|"),
        0x2B: (",", "<"),
        0x2C: ("/", "?"),
        0x2D: ("n", "N"),
        0x2E: ("m", "M"),
        0x2F: (".", ">"),
        0x32: ("`", "~"),
        0x41: ("KP_DEC", nil),
        0x43: ("*", nil),
        0x45: ("+", nil),
        // 0x47: ("KeypadClear", nil),
        0x4B: ("/", nil),
        0x4C: ("KP_ENTER", nil),
        0x4E: ("-", nil),
        0x51: ("=", nil),
        0x52: ("KP0", nil),
        0x53: ("KP1", nil),
        0x54: ("KP2", nil),
        0x55: ("KP3", nil),
        0x56: ("KP4", nil),
        0x57: ("KP5", nil),
        0x58: ("KP6", nil),
        0x59: ("KP7", nil),
        0x5B: ("KP8", nil),
        0x5C: ("KP9", nil),

        0x24: ("ENTER", nil),
        0x30: ("TAB", nil),
        0x31: ("SPACE", nil),
        0x33: ("BS", nil),
        0x35: ("ESC", nil),
        // 0x37: ("Command", nil),
        // 0x38: ("Shift", nil),
        // 0x39: ("CapsLock", nil),
        // 0x3A: ("Option", nil),
        // 0x3B: ("Control", nil),
        // 0x3C: ("RightShift", nil),
        // 0x3D: ("RightOption", nil),
        // 0x3E: ("RightControl", nil),
        // 0x3F: ("Function", nil),
        0x40: ("F17", nil),
        // 0x48: ("VolumeUp", nil),
        // 0x49: ("VolumeDown", nil),
        // 0x4A: ("Mute", nil),
        0x4F: ("F18", nil),
        0x50: ("F19", nil),
        0x5A: ("F20", nil),
        0x60: ("F5", nil),
        0x61: ("F6", nil),
        0x62: ("F7", nil),
        0x63: ("F3", nil),
        0x64: ("F8", nil),
        0x65: ("F9", nil),
        0x67: ("F11", nil),
        0x69: ("F13", nil),
        0x6A: ("F16", nil),
        0x6B: ("F14", nil),
        0x6D: ("F10", nil),
        0x6F: ("F12", nil),
        0x71: ("F15", nil),
        0x72: ("INS", nil),
        0x73: ("HOME", nil),
        0x74: ("PGUP", nil),
        0x75: ("DEL", nil),
        0x76: ("F4", nil),
        0x77: ("END", nil),
        0x78: ("F2", nil),
        0x79: ("PGDWN", nil),
        0x7A: ("F1", nil),
        0x7B: ("LEFT", nil),
        0x7C: ("RIGHT", nil),
        0x7D: ("DOWN", nil),
        0x7E: ("UP", nil),
        0x7F: ("POWER", nil), // This should be KeyCode::PC_POWER.
    ]

    /// They key of an event.
    enum Key: UInt16, CaseIterable, Hashable, Codable {
        /// 0
        case zero = 29
        /// 1
        case one = 18
        /// 2
        case two = 19
        /// 3
        case three = 20
        /// 4
        case four = 21
        /// 5
        case five = 23
        /// 6
        case six = 22
        /// 7
        case seven = 26
        /// 8
        case eight = 28
        /// 9
        case nine = 25
        /// A
        case a = 0
        /// B
        case b = 11
        /// C
        case c = 8
        /// D
        case d = 2
        /// E
        case e = 14
        /// F
        case f = 3
        /// G
        case g = 5
        /// H
        case h = 4
        /// I
        case i = 34
        /// J
        case j = 38
        /// K
        case k = 40
        /// L
        case l = 37
        /// M
        case m = 46
        /// N
        case n = 45
        /// O
        case o = 31
        /// P
        case p = 35
        /// Q
        case q = 12
        /// R
        case r = 15
        /// S
        case s = 1
        /// T
        case t = 17
        /// U
        case u = 32
        /// V
        case v = 9
        /// W
        case w = 13
        /// X
        case x = 7
        /// Y
        case y = 16
        /// Z
        case z = 6
        /// Section Sign
        case sectionSign = 10
        /// Grave
        case grave = 50
        /// Minus
        case minus = 27
        /// Equal
        case equal = 24
        /// Left Square Bracket
        case leftSquareBracket = 33
        /// Right Square Bracket
        case rightSquareBracket = 30
        /// Semicolon
        case semicolon = 41
        /// Quote
        case quote = 39
        /// Comma
        case comma = 43
        /// Period
        case period = 47
        /// Slash
        case slash = 44
        /// Backslash
        case backslash = 42
        /// Keypad 0
        case keypad0 = 82
        /// Keypad 1
        case keypad1 = 83
        /// Keypad 2
        case keypad2 = 84
        /// Keypad 3
        case keypad3 = 85
        /// Keypad 4
        case keypad4 = 86
        /// Keypad 5
        case keypad5 = 87
        /// Keypad 6
        case keypad6 = 88
        /// Keypad 7
        case keypad7 = 89
        /// Keypad 8
        case keypad8 = 91
        /// Keypad 9
        case keypad9 = 92
        /// Keypad Decimal
        case keyPadDecimal = 65
        /// Keypad Multiply
        case keypadMultiply = 67
        /// Keypad Plus
        case keypadPlus = 69
        /// Keypad Divide
        case keypadDivide = 75
        /// Keypad Minus
        case keypadMinus = 78
        /// Keypad Equals
        case keypadEquals = 81
        /// Keypad Clear
        case keypadClear = 71
        /// Keypad Enter
        case keypadEnter = 76
        /// Space
        case space = 49
        /// Enter
        case enter = 36
        /// Tab
        case tab = 48
        /// Delete
        case delete = 51
        /// Forward Delete
        case forwardDelete = 117
        /// Linefeed
        case linefeed = 52
        /// Escape
        case escape = 53
        /// Command
        case command = 55
        /// Shift
        case shift = 56
        /// CapsLock
        case capsLock = 57
        /// Option
        case option = 58
        /// Control
        case control = 59
        /// Right Shift
        case rightShift = 60
        /// Right Option
        case rightOption = 61
        /// Right Control
        case rightControl = 62
        /// Function
        case function = 63
        /// F1
        case f1 = 122
        /// F2
        case f2 = 120
        /// F3
        case f3 = 99
        /// F4
        case f4 = 118
        /// F5
        case f5 = 96
        /// F6
        case f6 = 97
        /// F7
        case f7 = 98
        /// F8
        case f8 = 100
        /// F9
        case f9 = 101
        /// F10
        case f10 = 109
        /// F11
        case f11 = 103
        /// F12
        case f12 = 111
        /// F13
        case f13 = 105
        /// F14
        case f14 = 107
        /// F15
        case f15 = 113
        /// F16
        case f16 = 106
        /// F17
        case f17 = 64
        /// F18
        case f18 = 79
        /// F19
        case f19 = 80
        /// F20
        case f20 = 90
        /// Volume Up
        case volumeUp = 72
        /// Volume Down
        case volumeDown = 73
        /// Mute
        case mute = 74
        /// Insert Help
        case insertHelp = 114
        /// Home
        case home = 115
        /// End
        case end = 119
        /// Page Up
        case pageUp = 116
        /// Page Down
        case pageDown = 121
        /// Arrow Left
        case arrowLeft = 123
        /// Arrow Right
        case arrowRight = 124
        /// Arrow Down
        case arrowDown = 125
        /// Arrow Up
        case arrowUp = 126
        /// Power
        case power = 127

        /// 0
        public static let d0 = Self.zero
        /// 1
        public static let d1 = Self.one
        /// 2
        public static let d2 = Self.two
        /// 3
        public static let d3 = Self.three
        /// 4
        public static let d4 = Self.four
        /// 5
        public static let d5 = Self.five
        /// 6
        public static let d6 = Self.six
        /// 7
        public static let d7 = Self.seven
        /// 8
        public static let d8 = Self.eight
        /// 9
        public static let d9 = Self.nine

        public var characters: (main: String, secondary: String?) {
            switch self {
            case .zero: return ("0", "}")
            case .one: return ("1", "!")
            case .two: return ("2", "⌫")
            case .three: return ("3", "♯")
            case .four: return ("4", "$")
            case .five: return ("5", "%")
            case .six: return ("6", "^")
            case .seven: return ("7", "&")
            case .eight: return ("8", "*")
            case .nine: return ("9", "{")
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
            case .equal: return ("=", "+")
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
            case .keyPadDecimal: return ("KeyPadDecimal", nil)
            case .keypadMultiply: return ("KeypadMultiply", nil)
            case .keypadPlus: return ("KeypadPlus", nil)
            case .keypadDivide: return ("KeypadDivide", nil)
            case .keypadMinus: return ("KeypadMinus", nil)
            case .keypadEquals: return ("KeypadEquals", nil)
            case .keypadClear: return ("KeypadClear", nil)
            case .keypadEnter: return ("KeypadEnter", nil)
            case .space: return ("Space", nil)
            case .enter: return ("Enter", nil)
            case .tab: return ("Tab", nil)
            case .delete: return ("Delete", nil)
            case .forwardDelete: return ("ForwardDelete", nil)
            case .linefeed: return ("Linefeed", nil)
            case .escape: return ("Escape", nil)
            case .command: return ("Command", nil)
            case .shift: return ("Shift", nil)
            case .capsLock: return ("CapsLock", nil)
            case .option: return ("Option", nil)
            case .control: return ("Control", nil)
            case .rightShift: return ("RightShift", nil)
            case .rightOption: return ("RightOption", nil)
            case .rightControl: return ("RightControl", nil)
            case .function: return ("Function", nil)
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
            case .home: return ("Home", nil)
            case .end: return ("End", nil)
            case .pageUp: return ("PageUp", nil)
            case .pageDown: return ("PageDown", nil)
            case .arrowLeft: return ("ArrowLeft", nil)
            case .arrowRight: return ("ArrowRight", nil)
            case .arrowDown: return ("ArrowDown", nil)
            case .arrowUp: return ("ArrowUp", nil)
            case .power: return ("Power", nil)
            }
        }
    }
}

extension NSEvent {
    static func characters(for keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags = []) -> String? {
        let maxNameLength = 4
        var nameBuffer = [UniChar](repeating: 0, count : maxNameLength)
        var nameLength = 0

        var flags: UInt32 = 0
        if modifierFlags.contains(.shift)    { flags |= UInt32(shiftKey >> 8) }
        if modifierFlags.contains(.option)   { flags |= UInt32(optionKey >> 8) }
        if modifierFlags.contains(.control)  { flags |= UInt32(controlKey >> 8) }
        if modifierFlags.contains(.command)  { flags |= UInt32(cmdKey >> 8) }
        if modifierFlags.contains(.capsLock) { flags |= UInt32(alphaLock >> 8) }
        var deadKeys: UInt32 = 0
        let keyboardType = UInt32(LMGetKbdType())
        let source = TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue()
        guard let ptr = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
            Swift.print("Could not get keyboard layout data")
            return nil
        }
        let layoutData = Unmanaged<CFData>.fromOpaque(ptr).takeUnretainedValue() as Data
        let dataRef = unsafeBitCast(layoutData, to: CFData.self)
        // let keyLayout = unsafeBitCast(CFDataGetBytePtr(dataRef), to: UnsafePointer<UCKeyboardLayout>.self)
        let osStatus = layoutData.withUnsafeBytes {
            UCKeyTranslate($0.bindMemory(to: UCKeyboardLayout.self).baseAddress, keyCode, UInt16(kUCKeyActionDown), flags, keyboardType, UInt32(kUCKeyTranslateNoDeadKeysMask), &deadKeys, maxNameLength, &nameLength, &nameBuffer)
        }
        guard osStatus == noErr else {
            Swift.print("KeyCode: \(keyCode) Status: \(osStatus)")
            return nil
        }
        return  String(utf16CodeUnits: nameBuffer, count: nameLength)
    }
}


#endif
