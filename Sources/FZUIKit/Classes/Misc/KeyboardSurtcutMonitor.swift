//
//  KeyboardSurtcutMonitor.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A keyboard shortcut monitor.
public final class CGKeyEventMonitor {
    public enum EventType {
        /// Key down.
        case keyDown
        /// Key up.
        case keyUp
        
        fileprivate var globalMonitor: GlobalKeyPressMonitor {
            self == .keyDown ? .sharedKeyDown : .sharedKeyUp
        }
    }
    
    /// The shortcut that is monitored.
    public var shortcut: KeyboardShortcut {
        didSet {
            guard oldValue != shortcut, isActive else { return }
            keyType.globalMonitor.updateMonitor(self)
        }
    }
    
    /// The handler that is called when the shortcut is pressed.
    public var handler: () -> Void {
        didSet {
            guard isActive else { return }
            keyType.globalMonitor.updateMonitor(self)
        }
    }
    
    /// A Boolean value that indicates whether the monitor is active.
    public var isActive = true {
        didSet {
            guard oldValue != isActive else { return }
            keyType.globalMonitor.updateMonitor(self)
        }
    }
    
    
    /// The key event type.
    public var keyType: EventType = .keyDown {
        didSet {
            guard oldValue != keyType, isActive else { return }
            oldValue.globalMonitor.removeMonitor(self)
            keyType.globalMonitor.updateMonitor(self)
        }
    }

    public init(shortcut: KeyboardShortcut, for keyType: EventType = .keyDown, handler: @escaping () -> Void) {
        self.shortcut = shortcut
        self.handler = handler
        self.keyType = keyType
        keyType.globalMonitor.updateMonitor(self)
    }
    
    /// A key down monitor for the specific keyboard shortfcut.
    public static func keyDown(_ shortcut: KeyboardShortcut, handler: @escaping () -> Void) -> Self {
        Self(shortcut: shortcut, for: .keyDown, handler: handler)
    }
    
    /// A key up monitor for the specific keyboard shortfcut.
    public static func keyUp(_ shortcut: KeyboardShortcut, handler: @escaping () -> Void) -> Self {
        Self(shortcut: shortcut, for: .keyDown, handler: handler)
    }

    deinit {
        isActive = false
    }
}

fileprivate final class GlobalKeyPressMonitor {
    static let sharedKeyDown = GlobalKeyPressMonitor(.keyDown)
    static let sharedKeyUp = GlobalKeyPressMonitor(.keyUp)

    private var monitors: OrderedDictionary<ObjectIdentifier, (KeyboardShortcut, () -> Void)> = [:]
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let eventType: CGEventType

    private init(_ type: CGKeyEventMonitor.EventType) {
        self.eventType = type == .keyUp ? .keyDown : .keyUp
    }

    func start() {
        guard eventTap == nil else { return }
        let eventMask = eventType == .keyDown ? CGEventMask(1 << CGEventType.keyDown.rawValue) : CGEventMask(1 << CGEventType.keyUp.rawValue)
        let callback: CGEventTapCallBack
        if eventType == .keyDown {
            callback = { _, type, event, refcon in
                guard type == .keyDown, let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }
                let monitor = Unmanaged<GlobalKeyPressMonitor>.fromOpaque(refcon).takeUnretainedValue()
                let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
                
                for (shortcut, handler) in monitor.monitors.values {
                    guard keyCode == shortcut.keyCode, event.flags.contains(shortcut.flags) else { continue }
                    handler()
                }
                return Unmanaged.passUnretained(event)
            }
        } else {
            callback = { _, type, event, refcon in
                guard type == .keyUp, let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }
                let monitor = Unmanaged<GlobalKeyPressMonitor>.fromOpaque(refcon).takeUnretainedValue()
                let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
                let flags = NSEvent.ModifierFlags(rawValue: UInt(event.flags.rawValue))
                for (_, (shortcut, handler)) in monitor.monitors {
                    if keyCode == shortcut.keyCode,
                       monitor.flagsMatch(flags, required: shortcut.modifierFlags) {
                        handler()
                    }
                }
                return Unmanaged.passUnretained(event)
            }
        }
        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: eventMask, callback: callback, userInfo: refcon)
        guard let eventTap = eventTap else {
            print("⚠️ Failed to create event tap. Enable Accessibility permissions.")
            return
        }
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
        runLoopSource = nil
        if let tap = eventTap {
            CFMachPortInvalidate(tap)
        }
        eventTap = nil
    }
    
    func updateMonitor(_ monitor: CGKeyEventMonitor) {
        monitor.isActive ? addMonitor(monitor) : removeMonitor(monitor)
    }
    
    func addMonitor(_ monitor: CGKeyEventMonitor) {
        monitors[ObjectIdentifier(monitor)] = (monitor.shortcut, monitor.handler)
        start()
    }
    
    func removeMonitor(_ monitor: CGKeyEventMonitor) {
        monitors.removeValue(forKey: ObjectIdentifier(monitor))
        if monitors.isEmpty {
            stop()
        }
    }
    
    let relevantFlags: NSEvent.ModifierFlags = [.command, .option, .control, .shift, .capsLock, .function]

    private func flagsMatch(_ actual: NSEvent.ModifierFlags, required: NSEvent.ModifierFlags) -> Bool {
        actual.intersection(relevantFlags) == required
    }
}

#endif
