//
//  KeyboardShortcut.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A keyboard shortcut.
public struct KeyboardShortcut: Hashable, ExpressibleByNilLiteral, ExpressibleByStringLiteral {
    /// The key-equivalent character.
    public var keyEquivalent: String = "" {
        didSet { keyCode = Self.keyCodeMapping.first(where: {$0.value.contains(keyEquivalent)})?.key }
    }
    
    /// The key code of the shortcut.
    public private(set) var keyCode: Int? = nil
    
    /// The keyboard equivalent modifiers.
    public var modifierFlags: NSEvent.ModifierFlags = [] {
        didSet { flags = modifierFlags.cgEventFlags }
    }
    
    var flags: CGEventFlags = []

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
        self.keyCode = Self.keyCodeMapping.first(where: {$0.value.contains(keyEquivalent)})?.key
        defer { self.modifierFlags = modifierFlags }
    }
    
    public init(stringLiteral value: String) {
        self = Self(keyEquivalent: value)
    }
    
    public init(nilLiteral: ()) {
        
    }
    
    public static func + (lhs: Self, rhs: NSEvent.ModifierFlags) -> Self {
        .init(keyEquivalent: lhs.keyEquivalent, modifierFlags: lhs.modifierFlags + rhs)
    }
    
    public static func += (lhs: inout Self, rhs: NSEvent.ModifierFlags) {
        lhs.modifierFlags.insert(rhs)
    }

    init(_ keyEquivalent: String, _ flags: NSEvent.ModifierFlags = []) {
        self.keyEquivalent = keyEquivalent
        self.modifierFlags = flags
    }
    
    fileprivate static let keyCodeMapping: [Int: [String]] = [
        0x00: ["a"],
        0x01: ["s"],
        0x02: ["d"],
        0x03: ["f"],
        0x04: ["h"],
        0x05: ["g"],
        0x06: ["z"],
        0x07: ["x"],
        0x08: ["c"],
        0x09: ["v"],
        0x0B: ["b"],
        0x0C: ["q"],
        0x0D: ["w"],
        0x0E: ["e"],
        0x0F: ["r"],
        0x10: ["y"],
        0x11: ["t"],
        0x12: ["1", "!"],
        0x13: ["2", "@"],
        0x14: ["3", "sharp", "#"],
        0x15: ["4", "$"],
        0x16: ["6", "^"],
        0x17: ["5", "%"],
        0x18: ["=", "+"],
        0x19: ["9", "["],
        0x1A: ["7", "&"],
        0x1B: ["-", "_"],
        0x1C: ["8", "*"],
        0x1D: ["0", "]"],
        0x1E: ["]", "}"],
        0x1F: ["o"],
        0x20: ["u"],
        0x21: ["[", "{"],
        0x22: ["i"],
        0x23: ["p"],
        0x25: ["l"],
        0x26: ["j"],
        0x27: ["'", "\""],
        0x28: ["k"],
        0x29: [";", ":"],
        0x2A: ["\\", "|"],
        0x2B: [",", "<"],
        0x2C: ["/", "?"],
        0x2D: ["n"],
        0x2E: ["m"],
        0x2F: [".", ">"],
        0x32: ["`", "~"],
        0x41: ["kp_dec", "keypad decimal", "keypad dot"],
        0x43: ["*", "kp_multiply", "keypad multiply"],
        0x45: ["+", "kp_add", "keypad plus"],
        0x4B: ["/", "kp_divide", "keypad slash"],
        0x4C: ["kp_enter", "keypad enter"],
        0x4E: ["-", "kp_subtract", "keypad minus"],
        0x51: ["=", "kp_equals", "keypad equals"],
        0x52: ["kp0", "keypad 0"],
        0x53: ["kp1", "keypad 1"],
        0x54: ["kp2", "keypad 2"],
        0x55: ["kp3", "keypad 3"],
        0x56: ["kp4", "keypad 4"],
        0x57: ["kp5", "keypad 5"],
        0x58: ["kp6", "keypad 6"],
        0x59: ["kp7", "keypad 7"],
        0x5B: ["kp8", "keypad 8"],
        0x5C: ["kp9", "keypad 9"],
        0x24: ["enter", "return"],
        0x30: ["tab", "tabulator"],
        0x31: ["space", "spacebar"],
        0x33: ["bs", "backspace"],
        0x35: ["esc", "escape"],
        0x40: ["f17"],
        0x4F: ["f18"],
        0x50: ["f19"],
        0x5A: ["f20"],
        0x60: ["f5"],
        0x61: ["f6"],
        0x62: ["f7"],
        0x63: ["f3"],
        0x64: ["f8"],
        0x65: ["f9"],
        0x67: ["f11"],
        0x69: ["f13"],
        0x6A: ["f16"],
        0x6B: ["f14"],
        0x6D: ["f10"],
        0x6F: ["f12"],
        0x71: ["f15"],
        0x72: ["ins", "insert"],
        0x73: ["home"],
        0x74: ["pgup", "pageup", "page up"],
        0x75: ["del", "delete"],
        0x76: ["f4"],
        0x77: ["end"],
        0x78: ["f2"],
        0x79: ["pgdwn", "pagedown", "page down"],
        0x7A: ["f1"],
        0x7B: ["left"],
        0x7C: ["right"],
        0x7D: ["down"],
        0x7E: ["up"],
        0x7F: ["power", "eject"]
    ]
}
#endif
