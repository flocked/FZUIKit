//
//  NSEvent+ModifierFlags.swift
//  FZUIKit
//
//  Created by Florian Zand on 22.05.26.
//

#if os(macOS)
import AppKit

extension NSEvent.ModifierFlags: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible, Swift.Hashable, Swift.Encodable, Swift.Decodable {
    /// A `CGEventFlags` representation of the modifier flags.
    public var cgEventFlags: CGEventFlags {
        var flags: CGEventFlags = []
        if contains(.shift) { flags.insert(.maskShift) }
        if contains(.control) { flags.insert(.maskControl) }
        if contains(.command) { flags.insert(.maskCommand) }
        if contains(.numericPad) { flags.insert(.maskNumericPad) }
        if contains(.help) { flags.insert(.maskHelp) }
        if contains(.option) { flags.insert(.maskAlternate) }
        if contains(.function) { flags.insert(.maskSecondaryFn) }
        if contains(.capsLock) { flags.insert(.maskAlphaShift) }
        return flags
    }
    
    public var description: String {
        var components: [String] = []
        if contains(.control)    { components.append(".control") }
        if contains(.option)     { components.append(".option") }
        if contains(.shift)      { components.append(".shift") }
        if contains(.command)    { components.append(".command") }
        if contains(.capsLock)   { components.append(".capsLock") }
        if contains(.function)   { components.append(".function") }
        if contains(.numericPad) { components.append(".numericPad") }
        if contains(.help)   { components.append(".help") }
        return "[\(components.joined(separator: ", "))]"
    }
    
    public var debugDescription: String {
        var components: [String] = []
        if contains(.control)    { components.append("⌃") }
        if contains(.option)     { components.append("⌥") }
        if contains(.shift)      { components.append("⇧") }
        if contains(.command)    { components.append("⌘") }
        if contains(.capsLock)   { components.append("⇪") }
        if contains(.function)   { components.append("Fn") }
        if contains(.numericPad) { components.append("NumericPad") }
        if contains(.help) { components.append("❓") }
        return "[\(components.joined(separator: ", "))]"
    }
    
    /// A Boolean value indicating whether the flags contain [.command](https://developer.apple.com/documentation/appkit/nsevent/modifierflags-swift.struct/command).
    var hasCommand: Bool {
        contains(.command)
    }
    
    /// A Boolean value indicating whether the flags contain [.option](https://developer.apple.com/documentation/appkit/nsevent/modifierflags-swift.struct/option).
    var hasOption: Bool {
        contains(.option)
    }
    
    /// A Boolean value indicating whether the flags contain [.control](https://developer.apple.com/documentation/appkit/nsevent/modifierflags-swift.struct/control).
    var hasControl: Bool {
        contains(.control)
    }
    
    /// A Boolean value indicating whether the flags contain [.shift](https://developer.apple.com/documentation/appkit/nsevent/modifierflags-swift.struct/shift).
    var hasShift: Bool {
        contains(.shift)
    }
    
    /// A Boolean value indicating whether the flags contain [.capsLock](https://developer.apple.com/documentation/appkit/nsevent/modifierflags-swift.struct/capsLock).
    var hasCapsLock: Bool {
        contains(.capsLock)
    }
    
    /// A Boolean value indicating whether the flags contain [.function](https://developer.apple.com/documentation/appkit/nsevent/modifierflags-swift.struct/function).
    var hsaFunction: Bool {
        contains(.function)
    }
    
    /// A Boolean value indicating whether the flags contain [.help](https://developer.apple.com/documentation/appkit/nsevent/modifierflags-swift.struct/help).
    var hasHelp: Bool {
        contains(.help)
    }
    
    /// A Boolean value indicating whether the flags is empty.
    var hasNone: Bool {
        intersection(.deviceIndependentFlagsMask).isEmpty
    }
}

#endif
