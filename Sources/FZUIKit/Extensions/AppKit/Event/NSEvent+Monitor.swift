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

         Compared to `addGlobalMonitorForEvents`, it will automatically remove the monitor on deinit.

         Events are delivered asynchronously to your app and you can only observe the event; you cannot modify or otherwise prevent the event from being delivered to its original target application.

         Key-related events may only be monitored if accessibility is enabled or if your application is trusted for accessibility access (see `AXIsProcessTrusted()`).

         Note that your handler will not be called for events that are sent to your own application.

         - Parameters:
            - mask: An event mask specifying which events you wish to monitor. See NSEvent.EventTypeMask for possible values.
            - handler: The event handler block object. It is passed the event to monitor. You are unable to change the event, merely observe it.

         - Returns: The event monitor object.
         */
        static func globalMonitor(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> Void)) -> Monitor {
            Monitor.global(for: mask, handler: handler)
        }

        /**
         Returns a local event monitor for the specified mask which receives copies of events the system posts to this app prior to their dispatch.

         Compared to `addLocalMonitorForEvents`, it will automatically remove the monitor on deinit.

         Your handler will not be called for events that are consumed by nested event-tracking loops such as control tracking, menu tracking, or window dragging; only events that are dispatched through the applications `sendEvent(_:)` method will be passed to your handler.

         - Parameters:
            - mask: An event mask specifying which events you wish to monitor. See `NSEvent.EventTypeMask` for possible values.
            - handler: The event handler block object. It is passed the event to monitor. You can return the event unmodified, create and return a new `NSEvent` object, or return `nil` to stop the dispatching of the event.

         - Returns: The event monitor object.
         */
        static func localMonitor(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> (NSEvent?))) -> Monitor {
            Monitor.local(for: mask, handler: handler)
        }
    }

    public extension NSEvent {
        /// A local or global event monitor which calls a handler.
        /**
         A local or global event monitor which calls a handler.

         Compared to `addLocalMonitorForEvents` and `addGlobalMonitorForEvents`, it will automatically remove the monitor on deinit.
         */
        class Monitor {
            private let mask: NSEvent.EventTypeMask
            private var monitor: Any?
            private let handler: Any
            private let type: MonitorType

            private enum MonitorType: Int {
                case global
                case local
            }

            static func global(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> Void)) -> NSEvent.Monitor {
                NSEvent.Monitor(mask: mask, type: .global, handler: handler)
            }

            static func local(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent) -> (NSEvent?))) -> NSEvent.Monitor {
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

            private var isRunning: Bool {
                monitor != nil
            }

            /// Starts monitoring events.
            public func start() {
                if isRunning == false {
                    switch type {
                    case .global:
                        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> Void))
                    case .local:
                        monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: handler as! ((NSEvent) -> (NSEvent?)))
                    }
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
