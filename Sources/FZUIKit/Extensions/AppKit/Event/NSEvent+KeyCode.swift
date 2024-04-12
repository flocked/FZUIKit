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
            modifierFlags.readableString
        }

        var readableModifierFlagsCompact: String {
            modifierFlags.readableStringCompact
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

        enum KeyCode: UInt16, CaseIterable {
            case Zero = 29
            case One = 18
            case Two = 19
            case Three = 20
            case Four = 21
            case Five = 23
            case Six = 22
            case Seven = 26
            case Eight = 28
            case Nine = 25
            case a = 0
            case b = 11
            case c = 8
            case d = 2
            case e = 14
            case f = 3
            case g = 5
            case h = 4
            case i = 34
            case j = 38
            case k = 40
            case l = 37
            case m = 46
            case n = 45
            case o = 31
            case p = 35
            case q = 12
            case r = 15
            case s = 1
            case t = 17
            case u = 32
            case v = 9
            case w = 13
            case x = 7
            case y = 16
            case z = 6
            case SectionSign = 10
            case Grave = 50
            case Minus = 27
            case Equal = 24
            case LeftSquareBracket = 33
            case RightSquareBracket = 30
            case Semicolon = 41
            case Quote = 39
            case Comma = 43
            case Period = 47
            case Slash = 44
            case Backslash = 42
            case Keypad0 = 82
            case Keypad1 = 83
            case Keypad2 = 84
            case Keypad3 = 85
            case Keypad4 = 86
            case Keypad5 = 87
            case Keypad6 = 88
            case Keypad7 = 89
            case Keypad8 = 91
            case Keypad9 = 92
            case KeyPadDecimal = 65
            case KeypadMultiply = 67
            case KeypadPlus = 69
            case KeypadDivide = 75
            case KeypadMinus = 78
            case KeypadEquals = 81
            case KeypadClear = 71
            case KeypadEnter = 76
            case Space = 49
            case Enter = 36
            case Tab = 48
            case Delete = 51
            case ForwardDelete = 117
            case Linefeed = 52
            case Escape = 53
            case Command = 55
            case Shift = 56
            case CapsLock = 57
            case Option = 58
            case Control = 59
            case RightShift = 60
            case RightOption = 61
            case RightControl = 62
            case Function = 63
            case F1 = 122
            case F2 = 120
            case F3 = 99
            case F4 = 118
            case F5 = 96
            case F6 = 97
            case F7 = 98
            case F8 = 100
            case F9 = 101
            case F10 = 109
            case F11 = 103
            case F12 = 111
            case F13 = 105
            case F14 = 107
            case F15 = 113
            case F16 = 106
            case F17 = 64
            case F18 = 79
            case F19 = 80
            case F20 = 90
            case VolumeUp = 72
            case VolumeDown = 73
            case Mute = 74
            case InsertHelp = 114
            case Home = 115
            case End = 119
            case PageUp = 116
            case PageDown = 121
            case ArrowLeft = 123
            case ArrowRight = 124
            case ArrowDown = 125
            case ArrowUp = 126
            case Power = 127

            public var string: (main: String, secondary: String?) {
                switch self {
                case .Zero: return ("0", "}")
                case .One: return ("1", "!")
                case .Two: return ("2", "⌫")
                case .Three: return ("3", "♯")
                case .Four: return ("4", "$")
                case .Five: return ("5", "%")
                case .Six: return ("6", "^")
                case .Seven: return ("7", "&")
                case .Eight: return ("8", "*")
                case .Nine: return ("9", "{")
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
                case .SectionSign: return ("§", nil)
                case .Grave: return ("`", "∼")
                case .Minus: return ("-", "_")
                case .Equal: return ("=", "+")
                case .LeftSquareBracket: return ("[", "{")
                case .RightSquareBracket: return ("]", "}")
                case .Semicolon: return (";", ":")
                case .Quote: return ("'", "\"")
                case .Comma: return (",", "<")
                case .Period: return (".", ">")
                case .Slash: return ("/", "?")
                case .Backslash: return ("\\", "|")
                case .Keypad0: return ("Keypad0", nil)
                case .Keypad1: return ("Keypad1", nil)
                case .Keypad2: return ("Keypad2", nil)
                case .Keypad3: return ("Keypad3", nil)
                case .Keypad4: return ("Keypad4", nil)
                case .Keypad5: return ("Keypad5", nil)
                case .Keypad6: return ("Keypad6", nil)
                case .Keypad7: return ("Keypad7", nil)
                case .Keypad8: return ("Keypad8", nil)
                case .Keypad9: return ("Keypad9", nil)
                case .KeyPadDecimal: return ("KeyPadDecimal", nil)
                case .KeypadMultiply: return ("KeypadMultiply", nil)
                case .KeypadPlus: return ("KeypadPlus", nil)
                case .KeypadDivide: return ("KeypadDivide", nil)
                case .KeypadMinus: return ("KeypadMinus", nil)
                case .KeypadEquals: return ("KeypadEquals", nil)
                case .KeypadClear: return ("KeypadClear", nil)
                case .KeypadEnter: return ("KeypadEnter", nil)
                case .Space: return ("Space", nil)
                case .Enter: return ("Enter", nil)
                case .Tab: return ("Tab", nil)
                case .Delete: return ("Delete", nil)
                case .ForwardDelete: return ("ForwardDelete", nil)
                case .Linefeed: return ("Linefeed", nil)
                case .Escape: return ("Escape", nil)
                case .Command: return ("Command", nil)
                case .Shift: return ("Shift", nil)
                case .CapsLock: return ("CapsLock", nil)
                case .Option: return ("Option", nil)
                case .Control: return ("Control", nil)
                case .RightShift: return ("RightShift", nil)
                case .RightOption: return ("RightOption", nil)
                case .RightControl: return ("RightControl", nil)
                case .Function: return ("Function", nil)
                case .F1: return ("F1", nil)
                case .F2: return ("F2", nil)
                case .F3: return ("F3", nil)
                case .F4: return ("F4", nil)
                case .F5: return ("F5", nil)
                case .F6: return ("F6", nil)
                case .F7: return ("F7", nil)
                case .F8: return ("F8", nil)
                case .F9: return ("F9", nil)
                case .F10: return ("F10", nil)
                case .F11: return ("F11", nil)
                case .F12: return ("F12", nil)
                case .F13: return ("F13", nil)
                case .F14: return ("F14", nil)
                case .F15: return ("F15", nil)
                case .F16: return ("F16", nil)
                case .F17: return ("F17", nil)
                case .F18: return ("F18", nil)
                case .F19: return ("F19", nil)
                case .F20: return ("F20", nil)
                case .VolumeUp: return ("VolumeUp", nil)
                case .VolumeDown: return ("VolumeDown", nil)
                case .Mute: return ("Mute", nil)
                case .InsertHelp: return ("Insert/Help", nil)
                case .Home: return ("Home", nil)
                case .End: return ("End", nil)
                case .PageUp: return ("PageUp", nil)
                case .PageDown: return ("PageDown", nil)
                case .ArrowLeft: return ("ArrowLeft", nil)
                case .ArrowRight: return ("ArrowRight", nil)
                case .ArrowDown: return ("ArrowDown", nil)
                case .ArrowUp: return ("ArrowUp", nil)
                case .Power: return ("Power", nil)
                }
            }
        }
    }

public extension NSEvent.ModifierFlags {
    var readableStringCompact: String {
        ([
            (.capsLock, "⇪"),
            (.shift, "⇧"),
            (.control, "⌃"),
            (.option, "⌥"),
            (.command, "⌘"),
        ] as [(NSEvent.ModifierFlags, String)])
            .map { self.contains($0.0) ? $0.1 : "" }
            .joined()
    }

    var readableString: String {
        ([
            (.capsLock, "⇪"),
            (.shift, "⇧"),
            (.control, "⌃"),
            (.option, "⌥"),
            (.command, "⌘"),
            (.numericPad, "numeric pad"),
            (.help, "help"),
            (.function, "fn"),
        ] as [(NSEvent.ModifierFlags, String)])
            .map { self.contains($0.0) ? $0.1 : "" }
            .joined(separator: ", ")
    }
}


#endif
