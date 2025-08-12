//
//  NSEvent+KeyMonitor.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)

import AppKit
import Combine
import FZSwiftUtils

extension NSEvent {
    /// A keyboard shortcut monitor.
    public class KeyMonitor: NSObject {
        
        /// The keyboard shortcut monitored.
        public var shortcut: KeyboardShortcut {
            get { _shortcut }
            set {
                name = nil
                _shortcut = newValue
            }
        }
        
        
        private var _shortcut: KeyboardShortcut {
            didSet { updateMonitor() }
        }
        
        /// The global name to observe to update the keyboard shortcut automatically.
        public var name: KeyboardShortcut.Name? {
            didSet {
                guard oldValue != name else { return }
                shortcutObservation = nil
                _shortcut = name?.shortcut ?? nil
                guard let name = name else { return }
                shortcutObservation = .init(KeyboardShortcut.didChangeKeyboardShortcutNotification) { [weak self] notification in
                    guard let self = self, (notification.object as? String) == name.rawValue else { return }
                    self._shortcut = name.shortcut ?? nil
                }
            }
        }
                
        /// The key event type monitored.
        public let keyEventType: KeyEventType
        
        /// The key event type.
        public enum KeyEventType {
            /// Key down.
            case keyDown
            /// Key up.
            case keyUp
            /// Key down & up.
            case all
            
            var mask: EventTypeMask {
                switch self {
                case .keyDown: return .keyDown
                case .keyUp: return .keyUp
                case .all: return [.keyDown, .keyUp]
                }
            }
        }
        
        private var monitor: Any?
        private let id = UUID()
        private var handler: Any!
        private let isLocal: Bool
        private var _isActive = false
        private var previousFlags: NSEvent.ModifierFlags = []
        private var shortcutObservation: NotificationToken?

        /**
         Returns a local keyboard monitor for the specified keyboard shortcut and handler.
         
         Return either the event to the handler, or `nil` to stop the dispatching of the event.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func local(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> (NSEvent?))) -> KeyMonitor {
            .init(for: shortcut, isLocal: true, type: type, handler: handler)
        }
        
        /**
         Returns a local keyboard monitor for the keyboard shortcut with the specified name and handler.
         
         Return either the event to the handler, or `nil` to stop the dispatching of the event.
         
         - Parameters:
            - name: The name of the keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func local(for name: KeyboardShortcut.Name, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> (NSEvent?))) -> KeyMonitor {
            .init(for: name, isLocal: true, type: type, handler: handler)
        }
        
        /**
         Returns a local keyboard monitor for the specified keyboard shortcut and handler.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func local(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> ())) -> KeyMonitor {
            let handler: ((_ event: NSEvent) -> (NSEvent?)) = {
                handler($0)
                return $0
            }
            return .init(for: shortcut, isLocal: true, type: type, handler: handler)
        }
        
        /**
         Returns a local keyboard monitor for the keyboard shortcut with the specified name and handler.
         
         - Parameters:
            - name: The name of the keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func local(for name: KeyboardShortcut.Name, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> ())) -> KeyMonitor {
            let handler: ((_ event: NSEvent) -> (NSEvent?)) = {
                handler($0)
                return $0
            }
            return .init(for: name, isLocal: true, type: type, handler: handler)
        }
        
        /**
         Returns a global keyboard monitor for the specified keyboard shortcut and handler.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func global(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> ())) -> KeyMonitor {
            .init(for: shortcut, isLocal: false, type: type, handler: handler)
        }
        
        /**
         Returns a global keyboard monitor for the keyboard shortcut with the specified name and handler.
         
         - Parameters:
            - name: The name of the keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func global(for name: KeyboardShortcut.Name, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> ())) -> KeyMonitor {
            .init(for: name, isLocal: false, type: type, handler: handler)
        }
        
        private convenience init(for name: KeyboardShortcut.Name, isLocal: Bool, type: KeyEventType, handler: Any) {
            self.init(for: name.shortcut ?? nil, isLocal: isLocal, type: type, handler: handler)
            defer { self.name = name }
        }
        
        private init(for shortcut: KeyboardShortcut, isLocal: Bool, type: KeyEventType, handler: Any) {
            self._shortcut = shortcut
            self.isLocal = isLocal
            self.keyEventType = type
            super.init()
            
            if isLocal {
                let handler = handler as! ((_ event: NSEvent) -> (NSEvent?))
                let mapped: ((_ event: NSEvent) -> (NSEvent?)) = { [weak self] event in
                    guard let self = self else { return event }
                    let modifierFlags = event.modifierFlags.monitor
                    defer { self.previousFlags = modifierFlags }
                    if self.shortcut.key == nil {
                        guard self.previousFlags != modifierFlags else { return event }
                        switch self.keyEventType {
                        case .keyDown:
                            guard modifierFlags == self.shortcut.modifierFlags else { return event }
                            return handler(event)
                        case .keyUp:
                            guard self.previousFlags == self.shortcut.modifierFlags else { return event }
                            return handler(event)
                        case .all:
                            guard self.previousFlags == self.shortcut.modifierFlags || modifierFlags == self.shortcut.modifierFlags else { return event }
                            return handler(event)
                        }
                    }
                    guard self.shortcut.isMatching(event) else { return event }
                    return handler(event)
                }
                self.handler = mapped
            } else {
                let handler = handler as! ((_ event: NSEvent) -> ())
                let mapped: ((_ event: NSEvent) -> ()) = { [weak self] event in
                    guard let self = self else { return }
                    let modifierFlags = event.modifierFlags.monitor
                    defer { self.previousFlags = modifierFlags }
                    if self.shortcut.key == nil {
                        guard self.previousFlags != modifierFlags else { return }
                        switch self.keyEventType {
                        case .keyDown:
                            guard modifierFlags == self.shortcut.modifierFlags else { return }
                            handler(event)
                        case .keyUp:
                            guard self.previousFlags == self.shortcut.modifierFlags else { return }
                            handler(event)
                        case .all:
                            guard self.previousFlags == self.shortcut.modifierFlags || modifierFlags == self.shortcut.modifierFlags else { return }
                            handler(event)
                        }
                    }
                    guard self.shortcut.isMatching(event) else { return }
                    handler(event)
                }
                self.handler = mapped
            }
            start()
        }
        
        /// A Boolean value indicating whether the monitor is active.
        public var isActive: Bool {
            get { _isActive }
            set { newValue ? start() : stop() }
        }
                
        /// Starts monitoring the keyboard shortcut.
        public func start() {
            guard !isActive else { return }
            _isActive = true
            updateMonitor()
        }
        
        private func updateMonitor() {
            guard isActive, shortcut.key != nil || !shortcut.modifierFlags.isEmpty else { return }
            removeMonitor()
            previousFlags = NSEvent.modifierFlags
            guard shortcut != .none else { return }
            let mask = shortcut.key != nil ? keyEventType.mask : .flagsChanged
            if isLocal {
                monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> (NSEvent?)))
            } else {
                monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> Void))
            }
        }
        
        /// Stops monitoring the keyboard shortcut.
        public func stop() {
            _isActive = false
            removeMonitor()
        }
        
        private func removeMonitor() {
            guard let monitor = monitor else { return }
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        
        deinit {
            stop()
        }
    }
}

extension NSEvent.KeyMonitor {
    /// A keyboard  event publisher which receives copies of events the system posts.
    public struct Publisher: Combine.Publisher {
        public typealias Output = NSEvent
        public typealias Failure = Never
        
        /// The keyboard shortcut monitored.
        public let shortcut: KeyboardShortcut
        
        /// The key event type monitored.
        public let keyEventType: KeyEventType
        
        let isLocal: Bool
        
        /**
         A local keyboard event publisher for the specified keyboard shortcut which receives copies of events the system posts to this app prior to their dispatch.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
         */
        public static func local(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown) -> Self {
            Self(for: shortcut, isLocal: true, type: type)
        }
        
        /**
         A global keyboard event publisher for the specified keyboard shortcut which receives copies of events the system posts to other applications.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown`, `keyUp` or `all`).
         */
        public static func global(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown) -> Self {
            Self(for: shortcut, isLocal: false, type: type)
        }
        
        private init(for shortcut: KeyboardShortcut, isLocal: Bool, type: KeyEventType) {
            self.shortcut = shortcut
            self.isLocal = isLocal
            self.keyEventType = type
        }
        
        public func receive<S: Subscriber<Output, Failure>>(subscriber: S) {
            let subscription = Subscription(publisher: self, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
        
        final class Subscription<S: Subscriber<Output, Failure>>: Combine.Subscription {
            var subscriber: S?
            let monitor: NSEvent.KeyMonitor
            
            init(publisher: Publisher, subscriber: S) {
                self.subscriber = subscriber
                if publisher.isLocal {
                    monitor = .local(for: publisher.shortcut, type: publisher.keyEventType) { event in
                        _ = subscriber.receive(event)
                        return event
                    }
                } else {
                    monitor = .global(for: publisher.shortcut, type: publisher.keyEventType) { event in
                        _ = subscriber.receive(event)
                    }
                }
                monitor.start()
            }
            
            func request(_ demand: Subscribers.Demand) { }
            
            func cancel() {
                monitor.stop()
                subscriber = nil
            }
        }
    }
}

fileprivate extension NSEvent.ModifierFlags {
    var monitor: Self {
        intersection([.shift, .control, .command, .numericPad, .help, .option, .function, .capsLock])
    }
}
#endif
