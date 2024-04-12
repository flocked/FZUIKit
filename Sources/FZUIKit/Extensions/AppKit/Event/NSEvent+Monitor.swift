//
//  NSEvent+Monitor.swift
//
//
//  Created by Florian Zand on 08.09.22.
//

#if os(macOS)
    import AppKit

    public extension NSEvent {
        /**
         Returns a global event monitor for the specified mask which receives copies of events the system posts to other applications.

         Events are delivered asynchronously to your app and you can only observe the event; you cannot modify or otherwise prevent the event from being delivered to its original target application.

         Key-related events may only be monitored if accessibility is enabled or if your application is trusted for accessibility access (see `AXIsProcessTrusted()`).

         Note that your handler will not be called for events that are sent to your own application.
         
         - Note: Compared to `addGlobalMonitorForEvents(matching:handler:)`,  it automatically removes the monitor on deinit.

         - Parameters:
            - mask: An event mask specifying which events you wish to monitor.
            - handler: The event handler. It is passed the event to monitor. You are unable to change the event, merely observe it.

         - Returns: The event monitor object.
         */
        static func monitorGlobal(_ mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> Void)) -> Monitor {
            Monitor.global(for: mask, handler: handler)
        }

        /**
         Returns a local event monitor for the specified mask which receives copies of events the system posts to this app prior to their dispatch.

         Your handler will not be called for events that are consumed by nested event-tracking loops such as control tracking, menu tracking, or window dragging; only events that are dispatched through the applications `sendEvent(_:)` method will be passed to your handler.
         
         - Note: Compared to `addLocalMonitorForEvents(matching:handler:)`,  it automatically removes the monitor on deinit.

         - Parameters:
            - mask: An event mask specifying which events you wish to monitor.
            - handler: The event handler. It is passed the event to monitor. You can return the event unmodified, create and return a new `NSEvent` object, or return `nil` to stop the dispatching of the event.

         - Returns: The event monitor object.
         */
        static func monitorLocal(_ mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> (NSEvent?))) -> Monitor {
            Monitor.local(for: mask, handler: handler)
        }

        /**
         An event monitor which calls a handler.

         Compared to `addLocalMonitorForEvents(matching:handler:)` and `addGlobalMonitorForEvents(matching:handler:)`, it automatically removes the monitor on deinit.
         */
        class Monitor {
            /// An event mask specifying the events that are monitored.
            public let mask: NSEvent.EventTypeMask
            
            /// The monitor type.
            public let type: MonitorType
            
            private var monitor: Any?
            private let handler: Any

            /// The monitor type.
            public enum MonitorType: Int {
                /// An event monitor that receives copies of events the system posts to other applications.
                case global
                /// An event monitor that receives copies of events the system posts to this app prior to their dispatch.
                case local
            }

            /**
             Returns a global event monitor for the specified mask which receives copies of events the system posts to other applications.

             Events are delivered asynchronously to your app and you can only observe the event; you cannot modify or otherwise prevent the event from being delivered to its original target application.

             Key-related events may only be monitored if accessibility is enabled or if your application is trusted for accessibility access (see `AXIsProcessTrusted()`).

             Note that your handler will not be called for events that are sent to your own application.
             
             - Note: Compared to `addGlobalMonitorForEvents(matching:handler:)`,  it automatically removes the monitor on deinit.

             - Parameters:
                - mask: An event mask specifying which events you wish to monitor.
                - handler: The event handler. It is passed the event to monitor. You are unable to change the event, merely observe it.

             - Returns: The event monitor object.
             */
            public static func global(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> Void)) -> NSEvent.Monitor {
                NSEvent.Monitor(mask: mask, type: .global, handler: handler)
            }

            /**
             Returns a local event monitor for the specified mask which receives copies of events the system posts to this app prior to their dispatch.

             Your handler will not be called for events that are consumed by nested event-tracking loops such as control tracking, menu tracking, or window dragging; only events that are dispatched through the applications `sendEvent(_:)` method will be passed to your handler.
             
             - Note: Compared to `addLocalMonitorForEvents(matching:handler:)`,  it automatically removes the monitor on deinit.

             - Parameters:he event unmodified, create and return a new `NSEvent` object, or return `nil` to stop the dispatching of the event.

             - Returns: The event monitor object.
             */
            public static func local(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> (NSEvent?))) -> NSEvent.Monitor {
                NSEvent.Monitor(mask: mask, type: .local, handler: handler)
            }

            private init(mask: NSEvent.EventTypeMask, type: MonitorType = .local, handler: Any) {
                self.mask = mask
                self.handler = handler
                self.type = type
                start()
            }

            deinit {
                stop()
            }

            /// A Boolean value that indicates whether the monitor is running.
            public var isRunning: Bool {
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
                guard !isRunning else { return }
                switch type {
                case .global:
                    monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> Void))
                case .local:
                    monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> (NSEvent?)))
                }
            }

            /// Stops monitoring events.
            public func stop() {
                if let monitor = monitor {
                    NSEvent.removeMonitor(monitor)
                    self.monitor = nil
                }
            }
        }
    }

#endif
