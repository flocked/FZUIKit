//
//  NSEvent+Monitor.swift
//
//
//  Created by Florian Zand on 08.09.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSEvent {
    /**
     Returns a local event monitor for the specified mask and handler.
     
     The event monitor receives copies of events the system posts to this app prior to their dispatch.
     
     The handler will not be called for events that are consumed by nested event-tracking loops such as control tracking, menu tracking, or window dragging; only events that are dispatched through the applications `sendEvent(_:)` method will be passed to the handler.

     - Note: Compared to `addLocalMonitorForEvents(matching:handler:)`the monitor is automatically removed on deinit.
     
     - Parameters:
        - mask: An event mask specifying the events to monitor.
        - handler: The event handler that is called with the monitored event. You can return the event unmodified, create and return a new event, or return `nil` to stop the dispatching of the event.
     */
    static func localMonitor(for mask: EventTypeMask, handler: @escaping ((_ event: NSEvent) -> (NSEvent?))) -> Monitor {
        Monitor.local(for: mask, handler: handler)
    }
    
    /**
     Returns a global event monitor for the specified mask and handler.
     
     The event monitor receives copies of events the system posts to other applications.
     
     Events are delivered asynchronously to your app and you can only observe the event; you cannot modify or otherwise prevent the event from being delivered to its original target application.
     
     Key-related events may only be monitored if accessibility is enabled or if your application is trusted for accessibility access (see `AXIsProcessTrusted()`).
     
     Note that the handler will not be called for events that are sent to your own application.
     
     - Note: Compared to `addGlobalMonitorForEvents(matching:handler:)`the monitor is automatically removed on deinit.
     
     - Parameters:
        - mask: An event mask specifying the events to monitor.
        - handler: The handler that is called with the monitored event.
     */
    static func globalMonitor(for mask: EventTypeMask, handler: @escaping ((_ event: NSEvent) -> Void)) -> Monitor {
        Monitor.global(for: mask, handler: handler)
    }
    
    /**
     An event monitor which calls a handler.
     
     Compared to `addLocalMonitorForEvents(matching:handler:)` and `addGlobalMonitorForEvents(matching:handler:)`, the monitor is automatically removed on deinit.
     */
    class Monitor {
        /// An event mask specifying the events that are monitored.
        public let mask: NSEvent.EventTypeMask
        
        /// The monitor type.
        public let type: MonitorType
        
        private var monitor: Any?
        private let handler: Any
        private let id = UUID()
        
        /// The monitor type.
        public enum MonitorType: Int {
            /// An event monitor that receives copies of events the system posts to this app prior to their dispatch.
            case local
            /// An event monitor that receives copies of events the system posts to other applications.
            case global
        }
        
        /**
         Returns a local event monitor for the specified mask and handler.
         
         The event monitor receives copies of events the system posts to this app prior to their dispatch.
         
         The handler will not be called for events that are consumed by nested event-tracking loops such as control tracking, menu tracking, or window dragging; only events that are dispatched through the applications `sendEvent(_:)` method will be passed to the handler.
         
         - Note: Compared to `addLocalMonitorForEvents(matching:handler:)`the monitor is automatically removed on deinit.
         
         - Parameters:
            - mask: An event mask specifying the events to monitor.
            - handler: The event handler that is called with the monitored event. You can return the event unmodified, create and return a new event, or return `nil` to stop the dispatching of the event.
         */
        public static func local(for mask: EventTypeMask, handler: @escaping ((_ event: NSEvent) -> (NSEvent?))) -> Monitor {
            Monitor(mask: mask, type: .local, handler: handler)
        }
        
        /**
         Returns a global event monitor for the specified mask and handler.
         
         The event monitor receives copies of events the system posts to other applications.
         
         Events are delivered asynchronously to your app and you can only observe the event; you cannot modify or otherwise prevent the event from being delivered to its original target application.
         
         Key-related events may only be monitored if accessibility is enabled or if your application is trusted for accessibility access (see `AXIsProcessTrusted()`).
         
         Note that the handler will not be called for events that are sent to your own application.

         - Note: Compared to `addGlobalMonitorForEvents(matching:handler:)`the monitor is automatically removed on deinit.
         
         - Parameters:
            - mask: An event mask specifying the events to monitor.
            - handler: The handler that is called with the monitored event.
         */
        public static func global(for mask: EventTypeMask, handler: @escaping ((_ event: NSEvent) -> Void)) -> Monitor {
            Monitor(mask: mask, type: .global, handler: handler)
        }
        
        private init(mask: EventTypeMask, type: MonitorType = .local, handler: Any) {
            self.mask = mask
            self.handler = handler
            self.type = type
            start()
            Self.monitors[id] = .init(self)
        }
        
        deinit {
            Self.monitors[id] = nil
            stop()
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
        
        /// Starts monitoring events.
        public func start() {
            guard !isActive else { return }
            switch type {
            case .global:
                monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> Void))
            case .local:
                monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> (NSEvent?)))
            }
        }
        
        /// Stops monitoring events.
        public func stop() {
            guard let monitor = monitor else { return }
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        
        /**
         Activates all local event monitors.
         
         - Parameter mask: The mask of the monitors to activate, or `nil` to activate all.
         */
        public static func activateLocals(for mask: NSEvent.EventTypeMask? = nil) {
            if let mask = mask {
                localMonitors.filter({$0.mask == mask}).forEach({$0.isActive = true})
            } else {
                localMonitors.forEach({$0.isActive = true})
            }
        }
        
        /**
         Deactivates all local event monitors.
         
         - Parameter mask: The mask of the monitors to activate, or `nil` to activate all.
         */
        public static func deactivateLocals(for mask: NSEvent.EventTypeMask? = nil) {
            if let mask = mask {
                localMonitors.filter({$0.mask == mask}).forEach({$0.isActive = false})
            } else {
                localMonitors.forEach({$0.isActive = false})
            }
        }
        
        /**
         Activates all global event monitors.
         
         - Parameter mask: The mask of the monitors to activate, or `nil` to activate all.
         */
        public static func activateGlobals(for mask: NSEvent.EventTypeMask? = nil) {
            if let mask = mask {
                globalMonitors.filter({$0.mask == mask}).forEach({$0.isActive = true})
            } else {
                globalMonitors.forEach({$0.isActive = true})
            }
        }
        
        /**
         Deactivates all global event monitors.
         
         - Parameter mask: The mask of the monitors to activate, or `nil` to activate all.
         */
        public static func deactivateGlobals(for mask: NSEvent.EventTypeMask? = nil) {
            if let mask = mask {
                globalMonitors.filter({$0.mask == mask}).forEach({$0.isActive = false})
            } else {
                globalMonitors.forEach({$0.isActive = false})
            }
        }
        
        private static var monitors: [UUID: Weak<NSEvent.Monitor>] = [:]
        
        private static var localMonitors: [Monitor] {
            monitors.values.compactMap({$0.object}).filter({$0.type == .local})
        }
        
        private static var globalMonitors: [Monitor] {
            monitors.values.compactMap({$0.object}).filter({$0.type == .global})
        }
    }
}

#if canImport(Combine)
import Combine

extension NSEvent {
    /// An event publisher which receives copies of events the system posts.
    public struct Publisher: Combine.Publisher {
        public typealias Output = NSEvent
        public typealias Failure = Never
        
        /// The event type mask.
        public let mask: NSEvent.EventTypeMask
        let isLocal: Bool
        
        public func receive<S: Subscriber<Output, Failure>>(subscriber: S) {
            let subscription = Subscription(mask: mask, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
        
        /**
         Returns a local event publisher for the specified mask which receives copies of events the system posts to this app prior to their dispatch.
         
         - Parameter mask: An event mask specifying the events to monitor.
         */
        public static func local(for mask: NSEvent.EventTypeMask) -> Self {
            .init(for: mask, isLocal: true)
        }
        
        /**
         Returns a global event publisher for the specified mask which receives copies of events the system posts to other applications.
         
         - Parameter mask: An event mask specifying the events to monitor.
         */
        public static func global(for mask: NSEvent.EventTypeMask) -> Self {
            .init(for: mask, isLocal: false)
        }
        
        init(for mask: NSEvent.EventTypeMask, isLocal: Bool = true) {
            self.mask = mask
            self.isLocal = isLocal
        }
        
        final class Subscription<S: Subscriber<Output, Failure>>: Combine.Subscription {
            var subscriber: S?
            let monitor: NSEvent.Monitor
            
            init(mask: NSEvent.EventTypeMask, subscriber: S, isLocal: Bool = true) {
                self.subscriber = subscriber
                self.monitor = isLocal ? .local(for: mask) { event in
                    _ = subscriber.receive(event)
                    return event
                } : .global(for: mask) { event in
                    _ = subscriber.receive(event)
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
