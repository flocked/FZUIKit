//
//  CGKeyEventMonitor.swift
//
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A keyboard shortcut monitor.
public final class CGKeyEventMonitor {
    public enum KeyEventType {
        /// Key down.
        case keyDown
        /// Key up.
        case keyUp
        
        fileprivate var globalMonitor: GlobalKeyPressMonitor {
            self == .keyDown ? .keyDown : .keyUp
        }
    }
    
    /// The shortcut that is monitored.
    public var shortcut: KeyboardShortcut {
        didSet {
            guard oldValue != shortcut, isActive else { return }
            keyEventType.globalMonitor.updateMonitor(self)
        }
    }
    
    /// The handler that is called when the shortcut is pressed.
    public var handler: () -> Void {
        didSet {
            guard isActive else { return }
            keyEventType.globalMonitor.updateMonitor(self)
        }
    }
    
    /// A Boolean value that indicates whether the monitor is active.
    public var isActive = true {
        didSet {
            guard oldValue != isActive else { return }
            keyEventType.globalMonitor.updateMonitor(self)
        }
    }
    
    
    /// The key event type.
    public var keyEventType: KeyEventType = .keyDown {
        didSet {
            guard oldValue != keyEventType, isActive else { return }
            oldValue.globalMonitor.removeMonitor(self)
            keyEventType.globalMonitor.updateMonitor(self)
        }
    }

    public init(shortcut: KeyboardShortcut, for keyEventType: KeyEventType = .keyDown, handler: @escaping () -> Void) {
        self.shortcut = shortcut
        self.handler = handler
        self.keyEventType = keyEventType
        keyEventType.globalMonitor.updateMonitor(self)
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
    static let keyDown = GlobalKeyPressMonitor(.keyDown)
    static let keyUp = GlobalKeyPressMonitor(.keyUp)

    private var monitors: OrderedDictionary<ObjectIdentifier, (KeyboardShortcut, () -> Void)> = [:]
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let eventType: CGEventType

    private init(_ type: CGKeyEventMonitor.KeyEventType) {
        self.eventType = type == .keyDown ? .keyDown : .keyUp
    }

    func start() {
        guard eventTap == nil else { return }
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon = refcon else {
                return Unmanaged.passUnretained(event)
            }
            let monitor = Unmanaged<GlobalKeyPressMonitor>.fromOpaque(refcon).takeUnretainedValue()
            guard type == monitor.eventType else { return Unmanaged.passUnretained(event) }
            let keyCode = event.keyCode
            for (shortcut, handler) in monitor.monitors.values {
                guard keyCode == shortcut.keyCode, event.flags.contains(shortcut.flags) else { continue }
                handler()
            }
            return Unmanaged.passUnretained(event)
        }
        let eventMask = CGEventMask(1 << (eventType == .keyDown ? CGEventType.keyDown : .keyUp).rawValue)
        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: eventMask, callback: callback, userInfo: refcon)
        guard let eventTap = eventTap else {
            print("Failed to create event tap. Enable Accessibility permissions.")
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
        guard monitors.isEmpty else { return }
        stop()
    }
}

#endif
