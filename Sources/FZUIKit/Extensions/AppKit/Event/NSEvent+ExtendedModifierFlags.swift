//
//  NSEvent+ModifierFlags+.swift
//
//
//  Created by Florian Zand on 21.05.26.
//

#if os(macOS)
import AppKit
import Carbon.HIToolbox
import FZSwiftUtils

extension NSEvent {
    /// Modifier flags with support for left and right modifier keys.
    public struct ExtendedModifierFlags: OptionSet, Hashable, Sendable, CustomStringConvertible, CaseIterable {        
        
        // MARK: - Left / Right Modifiers
        
        /// The left Shift key.
        public static let shift = Self(rawValue: 1 << 0)
        /// The right Shift key.
        public static let rightShift = Self(rawValue: 1 << 1)
        /// The left Control key.
        public static let control = Self(rawValue: 1 << 2)
        /// The right Control key.
        public static let rightControl = Self(rawValue: 1 << 3)
        /// The left Option key.
        public static let option = Self(rawValue: 1 << 4)
        /// The right Option key.
        public static let rightOption = Self(rawValue: 1 << 5)
        /// The left Command key.
        public static let command = Self(rawValue: 1 << 6)
        /// The right Command key.
        public static let rightCommand = Self(rawValue: 1 << 7)
        
        // MARK: - Other Modifiers
        
        /// The Caps Lock key.
        public static let capsLock = Self(rawValue: 1 << 8)
        /// The Function key.
        public static let function = Self(rawValue: 1 << 9)
        /// The Help key.
        public static let help = Self(rawValue: 1 << 10)
        
        public static var allCases: [NSEvent.ExtendedModifierFlags] = [.shift, .rightShift, .control, .rightControl, .option, .rightOption, .command, .rightCommand, .capsLock, .function, .help]
        
        /// The raw value of the modifier flags.
        public let rawValue: UInt32
        
        /// Creates modifier flags from the specified raw value.
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
        
        public init(modifierFlags: NSEvent.ModifierFlags) {
            self = []
            if modifierFlags.contains(.command) { insert(.command) }
            if modifierFlags.contains(.control) { insert(.control) }
            if modifierFlags.contains(.shift) { insert(.shift) }
            if modifierFlags.contains(.option) { insert(.option) }
            if modifierFlags.contains(.help) { insert(.help) }
            if modifierFlags.contains(.function) { insert(.function) }
            if modifierFlags.contains(.capsLock) { insert(.capsLock) }
        }
        
        public init?(keyCode: UInt16) {
            switch keyCode {
            case UInt16(kVK_Shift):
                self = .shift
            case UInt16(kVK_RightShift):
                self = .rightShift
            case UInt16(kVK_Control):
                self = .control
            case UInt16(kVK_RightControl):
                self = .rightControl
            case UInt16(kVK_Option):
                self = .option
            case UInt16(kVK_RightOption):
                self = .rightOption
            case UInt16(kVK_Command):
                self = .command
            case UInt16(kVK_RightCommand):
                self = .rightCommand
            case UInt16(kVK_CapsLock):
                self = .capsLock
            case UInt16(kVK_Function):
                self = .function
            case UInt16(kVK_Help):
                self = .help
            default:
                return nil
            }
        }
        
        /// The virtual key codes represented by the modifier flags.
        public var keyCodes: [UInt16] {
            elements().compactMap({
                switch $0 {
                case .shift:
                    UInt16(kVK_Shift)
                case .rightShift:
                    UInt16(kVK_RightShift)
                case .control:
                    UInt16(kVK_Control)
                case .rightControl:
                    UInt16(kVK_RightControl)
                case .option:
                    UInt16(kVK_Option)
                case .rightOption:
                    UInt16(kVK_RightOption)
                case .command:
                    UInt16(kVK_Command)
                case .rightCommand:
                    UInt16(kVK_RightCommand)
                case .capsLock:
                    UInt16(kVK_CapsLock)
                case .function:
                    UInt16(kVK_Function)
                case .help:
                    UInt16(kVK_Help)
                default:
                    nil
                }
            })
        }
        
        /// The event modifier flags represented by the modifier key flags.
        public var modifierFlags: NSEvent.ModifierFlags {
            var flags: NSEvent.ModifierFlags = []
            
            if contains(.shift) || contains(.rightShift) {
                flags.insert(.shift)
            }
            if contains(.control) || contains(.rightControl) {
                flags.insert(.control)
            }
            if contains(.option) || contains(.rightOption) {
                flags.insert(.option)
            }
            if contains(.command) || contains(.rightCommand) {
                flags.insert(.command)
            }
            if contains(.capsLock) {
                flags.insert(.capsLock)
            }
            if contains(.function) {
                flags.insert(.function)
            }
            if contains(.help) {
                flags.insert(.help)
            }
            return flags
        }
        
        /// A textual representation of the modifier key flags.
        public var description: String {
            var descriptions: [String] = []
            if contains(.shift) {
                descriptions += ".shift"
            }
            if contains(.rightShift) {
                descriptions += ".rightShift"
            }
            if contains(.control) {
                descriptions += ".control"
            }
            if contains(.rightControl) {
                descriptions += ".rightControl"
            }
            if contains(.option) {
                descriptions += ".option"
            }
            if contains(.rightOption) {
                descriptions += ".rightOption"
            }
            if contains(.command) {
                descriptions += ".command"
            }
            if contains(.rightCommand) {
                descriptions += ".rightCommand"
            }
            if contains(.capsLock) {
                descriptions += ".capsLock"
            }
            if contains(.function) {
                descriptions += ".function"
            }
            if contains(.help) {
                descriptions += ".help"
            }
            return "[" + descriptions.joined(separator: ", ") + "]"
        }
    }
}

extension NSEvent {
    /// The modifier key flags represented by the event.
    public var extendedModifierFlags: ExtendedModifierFlags {
        ExtendedModifierFlags(keyCode: keyCode) ?? []
    }
    
    /**
     Creates and returns new flags changed events for the given modifier flags.
     
     - Parameters:
     - modifierFlags: The modifier flags of the events.
     - location: The cursor location on the screen.
     - Returns: The events for the specified modifier flags.
     */
    @_disfavoredOverload
    public static func flagsChanged(for modifierFlags: ExtendedModifierFlags, location: CGPoint = .zero) -> (down: [NSEvent], up: [NSEvent]) {
        var currentFlags: NSEvent.ModifierFlags = []
        let downEvents = modifierFlags.keyCodes.compactMap({
            currentFlags.insert(ExtendedModifierFlags(keyCode: $0)?.modifierFlags ?? [])
            return event(for: $0, modifierFlags: currentFlags)
        })
        let upEvents = modifierFlags.keyCodes.reversed().compactMap({
            currentFlags.remove(ExtendedModifierFlags(keyCode: $0)?.modifierFlags ?? [])
            return event(for: $0, modifierFlags: currentFlags)
        })
        return (downEvents, upEvents)
    }
    
    /**
     Creates and returns new flags changed events for the given modifier flags.
     
     - Parameters:
     - modifierFlags: The modifier flags of the events.
     - location: The cursor location on the screen.
     - Returns: The events for the specified modifier flags.
     */
    public static func flagsChanged(for modifierFlags: ModifierFlags, location: CGPoint = .zero) -> (down: [NSEvent], up: [NSEvent]) {
        flagsChanged(for: ExtendedModifierFlags(modifierFlags: modifierFlags), location: location)
    }
    
    /**
     Creates and returns new flags changed events for the given modifier flags in the specified window.
     
     - Parameters:
     - modifierFlags: The modifier flags of the events.
     - location: The cursor location in the window.
     - window: The window of the events.
     - Returns: The events for the specified modifier flags.
     */
    @_disfavoredOverload
    public static func flagsChanged(for modifierFlags: ExtendedModifierFlags, location: CGPoint, window: NSWindow) -> (down: [NSEvent], up: [NSEvent]) {
        var currentFlags: NSEvent.ModifierFlags = []
        let downEvents = modifierFlags.keyCodes.compactMap({
            currentFlags.insert(ExtendedModifierFlags(keyCode: $0)?.modifierFlags ?? [])
            return event(for: $0, modifierFlags: currentFlags, location: location, window: window)
        })
        let upEvents = modifierFlags.keyCodes.reversed().compactMap({
            currentFlags.remove(ExtendedModifierFlags(keyCode: $0)?.modifierFlags ?? [])
            return event(for: $0, modifierFlags: currentFlags, location: location, window: window)
        })
        return (downEvents, upEvents)
    }
    
    /**
     Creates and returns new flags changed events for the given modifier flags in the specified window.
     
     - Parameters:
     - modifierFlags: The modifier flags of the events.
     - location: The cursor location in the window.
     - window: The window of the events.
     - Returns: The events for the specified modifier flags.
     */
    public static func flagsChanged(for modifierFlags: ModifierFlags, location: CGPoint, window: NSWindow) -> (down: [NSEvent], up: [NSEvent]) {
        flagsChanged(for: ExtendedModifierFlags(modifierFlags: modifierFlags), location: location, window: window)
    }
    
    /**
     Creates and returns new flags changed events for the given modifier flags in the specified window.
     
     - Parameters:
     - modifierFlags: The modifier flags of the events.
     - location: The cursor location in the view.
     - view: The view of the events.
     - Returns: The events for the specified modifier flags.
     */
    @_disfavoredOverload
    public static func flagsChanged(for modifierFlags: ExtendedModifierFlags, location: CGPoint, view: NSView) -> (down: [NSEvent], up: [NSEvent]) {
        guard let window = view.window else { return ([], []) }
        return flagsChanged(for: modifierFlags, location: view.convert(location, to: nil), window: window)
    }
    
    /**
     Creates and returns new flags changed events for the given modifier flags in the specified window.
     
     - Parameters:
     - modifierFlags: The modifier flags of the events.
     - location: The cursor location in the view.
     - view: The view of the events.
     - Returns: The events for the specified modifier flags.
     */
    public static func flagsChanged(for modifierFlags: ModifierFlags, location: CGPoint, view: NSView) -> (down: [NSEvent], up: [NSEvent]) {
        flagsChanged(for: ExtendedModifierFlags(modifierFlags: modifierFlags), location: location, view: view)
    }
    
    private static func event(for keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, location: CGPoint = .zero, window: NSWindow? = nil) -> NSEvent? {
        guard let cgEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            return nil
        }
        cgEvent.flags = modifierFlags.cgEventFlags
        cgEvent.location = location
        guard let event = NSEvent(cgEvent: cgEvent) else {
            return nil
        }
        return NSEvent.keyEvent(with: event.type, location: location, modifierFlags: modifierFlags, timestamp: .now, windowNumber: window?.windowNumber ?? 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: keyCode) ?? event
    }
}
#endif
