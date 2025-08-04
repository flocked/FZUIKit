//
//  CGKeyEventMonitor.swift
//
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import Combine

/// A keyboard shortcut monitor.
public final class CGKeyEventMonitor {
    
    /// Key event type.
    public enum KeyEventType: Int {
        /// Key down.
        case keyDown
        /// Key up.
        case keyUp
        /// Key down & up.
        case all
        
        fileprivate var monitors: [GlobalKeyMonitor] {
            switch self {
            case .keyDown: return [.keyDown]
            case .keyUp: return [.keyUp]
            case .all: return [.keyDown, .keyUp]
            }
        }
    }
    
    fileprivate var monitors: [GlobalKeyMonitor] {
        if shortcut.key != nil {
            return keyEventType.monitors
        } else if !shortcut.modifierFlags.isEmpty {
            return [.flags]
        }
        return []
    }
    
    /// The shortcut that is monitored.
    public var shortcut: KeyboardShortcut {
        didSet {
            guard oldValue != shortcut, isActive else { return }
            monitors.forEach({ $0.addMonitor(self) })
        }
    }
    
    /**
     The handler that is called when the shortcut is pressed.
     
     Return either the event, or `nil` to stop the dispatching of the event.
     */
    public var handler: (_ event: NSEvent) -> (NSEvent?) {
        didSet {
            guard isActive else { return }
            monitors.forEach({ $0.addMonitor(self) })
        }
    }
    
    /**
     Sets the handler that is called when the shortcut is pressed.
     
     Return either the event, or `nil` to stop the dispatching of the event.
     */
    @discardableResult
    public func handler(_ handler: @escaping (_ event: NSEvent) -> (NSEvent?)) -> Self {
        self.handler = handler
        return self
    }
    
    /// Sets the handler that is called when the shortcut is pressed.
    @discardableResult
    public func handler(_ handler: @escaping (_ event: NSEvent) -> ()) -> Self {
        self.handler = {
            handler($0)
            return $0
        }
        return self
    }
    
    /// A Boolean value indicating whether the monitor is active.
    public var isActive: Bool {
        get { _isActive }
        set {
            guard newValue != _isActive else { return }
            _isActive = monitors.map({ $0.activateMonitor(self, newValue) }).first ?? false
        }
    }
    
    private var _isActive = false
    
    /// Starts monitoring the keyboard shortcut.
    public func start() {
        isActive = true
    }
    
    /// Stops monitoring the keyboard shortcut.
    public func stop() {
        isActive = false
    }
            
    /// The key event type.
    public var keyEventType: KeyEventType {
        didSet {
            guard oldValue != keyEventType, isActive else { return }
            [GlobalKeyMonitor.keyDown, .keyUp, .flags].forEach({ $0.removeMonitor(self) })
            _isActive = monitors.map({ $0.activateMonitor(self, true) }).first ?? false
        }
    }
    
    /**
     Creates a keyboard monitor for the specified keyboard shortcut and handler.
     
     Return either the event to the handler, or `nil` to stop the dispatching of the event.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - keyEventType: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
        - handler: The handler that is called if the shortcut is pressed.
     */
    public init(shortcut: KeyboardShortcut, type keyEventType: KeyEventType = .keyDown, handler: @escaping (_ event: NSEvent) -> (NSEvent?)) {
        self.shortcut = shortcut
        self.keyEventType = keyEventType
        self.handler = handler
        self.start()
    }
    
    /**
     Creates a keyboard monitor for the specified keyboard shortcut and handler.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - keyEventType: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
        - handler: The handler that is called if the shortcut is pressed.
     */
    public init(shortcut: KeyboardShortcut, type keyEventType: KeyEventType = .keyDown, handler: @escaping (_ event: NSEvent) -> ()) {
        self.shortcut = shortcut
        self.keyEventType = keyEventType
        self.handler = {
            handler($0)
            return $0
        }
        self.isActive = true
    }
    
    /**
     Creates a key down monitor for the specified keyboard shortcut and handler.
     
     Return either the event to the handler, or `nil` to stop the dispatching of the event.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - handler: The handler that is called if the shortcut is pressed.
     */
    public static func keyDown(_ shortcut: KeyboardShortcut, handler: @escaping (_ event: NSEvent) -> (NSEvent?)) -> Self {
        Self(shortcut: shortcut, type: .keyDown, handler: handler)
    }
    
    /**
     Creates a key down monitor for the specified keyboard shortcut and handler.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - handler: The handler that is called if the shortcut is pressed.
     */
    public static func keyDown(_ shortcut: KeyboardShortcut, handler: @escaping (_ event: NSEvent) -> ()) -> Self {
        Self(shortcut: shortcut, type: .keyDown, handler: handler)
    }
    
    /**
     Creates a key up monitor for the specified keyboard shortcut and handler.
     
     Return either the event to the handler, or `nil` to stop the dispatching of the event.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - handler: The handler that is called if the shortcut is released.
     */
    public static func keyUp(_ shortcut: KeyboardShortcut, handler: @escaping (_ event: NSEvent) -> (NSEvent?)) -> Self {
        Self(shortcut: shortcut, type: .keyUp, handler: handler)
    }
    
    /**
     Creates a key up monitor for the specified keyboard shortcut and handler.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - handler: The handler that is called if the shortcut is released.
     */
    public static func keyUp(_ shortcut: KeyboardShortcut, handler: @escaping (_ event: NSEvent) -> ()) -> Self {
        Self(shortcut: shortcut, type: .keyUp, handler: handler)
    }
    
    /**
     Creates a modifier flags monitor for the specified keyboard shortcut and handler.
     
     Return either the event to the handler, or `nil` to stop the dispatching of the event.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - keyEventType: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
        - handler: The handler that is called if the shortcut is released.
     */
    public static func flags(_ modifierFlags: NSEvent.ModifierFlags, type keyEventType: KeyEventType = .keyDown, handler: @escaping (_ event: NSEvent) -> (NSEvent?)) -> Self {
        Self(shortcut: .init(modifierFlags: modifierFlags), type: keyEventType, handler: handler)
    }
    
    /**
     Creates a modifier flags monitor for the specified keyboard shortcut and handler.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - keyEventType: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
        - handler: The handler that is called if the shortcut is released.
     */
    public static func flags(_ modifierFlags: NSEvent.ModifierFlags, type keyEventType: KeyEventType = .keyDown, handler: @escaping (_ event: NSEvent) -> ()) -> Self {
        Self(shortcut: .init(modifierFlags: modifierFlags), type: keyEventType, handler: handler)
    }

    deinit {
        stop()
    }
}

extension CGKeyEventMonitor {
    /// A keyboard event publisher which receives copies of events the system posts.
    public struct Publisher: Combine.Publisher {
        public typealias Output = NSEvent
        public typealias Failure = Never
        
        /// The keyboard shortcut monitored.
        public let shortcut: KeyboardShortcut
        
        /// The key event type monitored.
        public let keyEventType: KeyEventType
        
        /**
         Creates a event publisher for the specified keyboard shortcut which receives copies of events the system posts to this app prior to their dispatch.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
         */
        public init(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown) {
            self.shortcut = shortcut
            self.keyEventType = type
        }
        
        public func receive<S: Subscriber<Output, Failure>>(subscriber: S) {
            let subscription = Subscription(publisher: self, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
        
        final class Subscription<S: Subscriber<Output, Failure>>: Combine.Subscription {
            var subscriber: S?
            let monitor: CGKeyEventMonitor
            
            init(publisher: Publisher, subscriber: S) {
                self.subscriber = subscriber
                monitor = .init(shortcut: publisher.shortcut, type: publisher.keyEventType, handler: { event in
                    _ = subscriber.receive(event)
                })
            }
            
            func request(_ demand: Subscribers.Demand) { }
            
            func cancel() {
                monitor.isActive = false
                subscriber = nil
            }
        }
    }
}

fileprivate final class GlobalKeyMonitor {
    static let keyDown = GlobalKeyMonitor(.keyDown)
    static let keyUp = GlobalKeyMonitor(.keyUp)
    static let flags = GlobalKeyMonitor(.flagsChanged)
        
    private var monitors: OrderedDictionary<ObjectIdentifier, (shortcut: KeyboardShortcut, eventType: CGKeyEventMonitor.KeyEventType, handler: (NSEvent) -> (NSEvent?))> = [:]
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let eventType: CGEventType
    private let mask: CGEventTypeMask
    private var previousFlags: NSEvent.ModifierFlags = []
        
    private init(_ type: CGEventType) {
        self.eventType = type
        self.mask = CGEventTypeMask(type: type)
    }
        
    func start() {
        guard eventTap == nil else { return }
        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        previousFlags = NSEvent.modifierFlags
        eventTap = CGEvent.tapCreate(for: mask, tap: .cgSessionEventTap, userInfo: refcon) { _, type, event, refcon in
            guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
            let monitor = Unmanaged<GlobalKeyMonitor>.fromOpaque(refcon).takeUnretainedValue()
            guard type == monitor.eventType else { return Unmanaged.passUnretained(event) }
            guard let nsEvent = NSEvent(cgEvent: event) else { return Unmanaged.passUnretained(event) }
            let flags = nsEvent.modifierFlags.monitor
            if monitor.eventType == .flagsChanged {
                guard monitor.previousFlags != flags else { return Unmanaged.passUnretained(event) }
                defer { monitor.previousFlags = flags }
                for (shortcut, eventType, handler) in monitor.monitors.values {
                    switch eventType {
                    case .keyDown: guard monitor.previousFlags == shortcut.modifierFlags else { continue }
                    case .keyUp: guard flags == shortcut.modifierFlags else { continue }
                    case .all: guard monitor.previousFlags == shortcut.modifierFlags || flags == shortcut.modifierFlags else { continue }
                    }
                    guard handler(nsEvent) == nil else { continue }
                    return nil
                }
            } else {
                let keyCode = event.keyCode
                for (shortcut,_, handler) in monitor.monitors.values {
                    guard let _keyCode = shortcut.key?.rawValue, keyCode == _keyCode, flags == shortcut.modifierFlags, handler(nsEvent) == nil else { continue }
                    return nil
                }
            }
            return Unmanaged.passUnretained(event)
        }
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
        
    func activateMonitor( _ monitor: CGKeyEventMonitor, _ shouldActivate: Bool) -> Bool {
        shouldActivate ? addMonitor(monitor) : removeMonitor(monitor)
        return shouldActivate ? eventTap != nil : false
    }
        
    func addMonitor(_ monitor: CGKeyEventMonitor) {
        monitors[ObjectIdentifier(monitor)] = (monitor.shortcut, monitor.keyEventType, monitor.handler)
        start()
    }
        
    func removeMonitor(_ monitor: CGKeyEventMonitor) {
        monitors.removeValue(forKey: ObjectIdentifier(monitor))
        guard monitors.isEmpty else { return }
        stop()
    }
}

fileprivate extension NSEvent.ModifierFlags {
    var monitor: Self {
        intersection([.shift, .control, .command, .numericPad, .help, .option, .function, .capsLock])
    }
}

#endif
