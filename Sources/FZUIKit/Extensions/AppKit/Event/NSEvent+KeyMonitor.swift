//
//  NSEvent+KeyMonitor.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

#if os(macOS)

import AppKit

extension NSEvent {
    /**
     Returns a local keyboard monitor for the specified keyboard shortcut and handler.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - type: The key event type to monitor (either `keyDown` or `keyUp`).
        - handler: The handler that is called when the keyboard shortcut is pressed.
     */
    public static func localKeyMonitor(for shortcut: KeyboardShortcut, type: KeyboardMonitor.KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> (NSEvent?))) -> KeyboardMonitor {
        .local(for: shortcut, type: type, handler: handler)
    }
    
    /**
     Returns a global keyboard monitor for the specified keyboard shortcut and handler.
     
     - Parameters:
        - shortcut: The keyboard shortcut to monitor.
        - type: The key event type to monitor (either `keyDown` or `keyUp`).
        - handler: The handler that is called when the keyboard shortcut is pressed.
     */
    public static func globalKeyMonitor(for shortcut: KeyboardShortcut, type: KeyboardMonitor.KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> ())) -> KeyboardMonitor {
        .global(for: shortcut, type: type, handler: handler)
    }
    
    /// A keyboard monitor which calls a handler.
    public class KeyboardMonitor: NSObject {
        
        /// The keyboard shortcut monitored.
        public var shortcut: KeyboardShortcut
        
        /// The key event type monitored.
        public let keyEventType: KeyEventType
        
        /// The key event type.
        public enum KeyEventType {
            /// Key down.
            case keyDown
            /// Key up.
            case keyUp
        }
        
        private var monitor: Any?
        private let id = UUID()
        private let mask: EventTypeMask
        private var handler: Any!
        private let isLocal: Bool
        typealias LocalHandler = ((_ event: NSEvent) -> (NSEvent?))
        typealias GlobalHandler = ((_ event: NSEvent) -> ())
        
        /**
         Returns a local keyboard monitor for the specified keyboard shortcut and handler.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown` or `keyUp`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func local(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> (NSEvent?))) -> KeyboardMonitor {
            .init(for: shortcut, isLocal: true, type: type, handler: handler)
        }
        
        /**
         Returns a global keyboard monitor for the specified keyboard shortcut and handler.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown` or `keyUp`).
            - handler: The handler that is called when the keyboard shortcut is pressed.
         */
        public static func global(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown, handler: @escaping ((_ event: NSEvent) -> ())) -> KeyboardMonitor {
            .init(for: shortcut, isLocal: false, type: type, handler: handler)
        }
        
        private init(for shortcut: KeyboardShortcut, isLocal: Bool, type: KeyEventType, handler: Any) {
            self.shortcut = shortcut
            self.mask = type == .keyDown ? .keyDown : .keyUp
            self.isLocal = isLocal
            self.keyEventType = type
            super.init()
            
            if isLocal {
                let handler = handler as! ((_ event: NSEvent) -> (NSEvent?))
                let mapped: ((_ event: NSEvent) -> (NSEvent?)) = { [weak self] event in
                    guard let self = self else { return event }
                    guard event.keyCode == self.shortcut.keyCode ?? -1, event.modifierFlags.contains(self.shortcut.modifierFlags) else { return event }
                    return handler(event)
                }
                self.handler = mapped
            } else {
                let handler = handler as! ((_ event: NSEvent) -> ())
                let mapped: ((_ event: NSEvent) -> ()) = { [weak self] event in
                    guard let self = self else { return }
                    guard event.keyCode == self.shortcut.keyCode ?? -1, event.modifierFlags.contains(self.shortcut.modifierFlags) else { return }
                    handler(event)
                }
                self.handler = mapped
            }
            start()
        }
        
        /// A Boolean value that indicates whether the monitor is active.
        public var isActive: Bool {
            get { monitor != nil }
            set {
                if newValue {
                    start()
                } else {
                    stop()
                }
            }
        }
        
        /// Starts monitoring the keyboard shortcut.
        public func start() {
            guard !isActive else { return }
            if isLocal {
                monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> (NSEvent?)))
            } else {
                monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> Void))
            }
        }
        
        /// Stops monitoring the keyboard shortcut.
        public func stop() {
            guard let monitor = monitor else { return }
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}

#if canImport(Combine)
import Combine

extension NSEvent.KeyboardMonitor {
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
            - type: The key event type to monitor (either `keyDown` or `keyUp`).
         */
        public static func local(for shortcut: KeyboardShortcut, type: KeyEventType = .keyDown) -> Self {
            Self(for: shortcut, isLocal: true, type: type)
        }
        
        /**
         A global keyboard event publisher for the specified keyboard shortcut which receives copies of events the system posts to other applications.
         
         - Parameters:
            - shortcut: The keyboard shortcut to monitor.
            - type: The key event type to monitor (either `keyDown` or `keyUp`).
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
            let monitor: NSEvent.KeyboardMonitor
            
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
#endif

#endif
