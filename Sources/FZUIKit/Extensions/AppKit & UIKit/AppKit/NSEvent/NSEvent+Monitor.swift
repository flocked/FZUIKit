//
//  NSEvent+Monitor.swift
//
//
//  Created by Florian Zand on 08.09.22.
//  Copyright © 2022 MuffinStory. All rights reserved.
//

#if os(macOS)
import AppKit

public extension NSEvent {
    class Monitor {
        private var monitor: Any?
        private let mask: NSEvent.EventTypeMask
        private let type: MonitorType

        public var handler: (NSEvent?) -> Void

        public enum MonitorType {
            case global
            case local
        }

        public static func global(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent?) -> Void)) -> NSEvent.Monitor {
            return NSEvent.Monitor(mask: mask, type: .global, handler: handler)
        }

        public static func local(for mask: NSEvent.EventTypeMask, handler: @escaping ((NSEvent?) -> Void)) -> NSEvent.Monitor {
            return NSEvent.Monitor(mask: mask, type: .local, handler: handler)
        }

        public init(mask: NSEvent.EventTypeMask, type: MonitorType = .global, handler: @escaping ((NSEvent?) -> Void)) {
            self.mask = mask
            self.handler = handler
            self.type = type
        }

        deinit {
            stop()
        }

        private func internalHandler(_ event: NSEvent?) {
            handler(event)
        }

        private func internalLocalHandler(_ event: NSEvent) -> NSEvent? {
            handler(event)
            return event
        }

        private var isRunning: Bool {
            return (monitor != nil)
        }

        public func start() {
            if isRunning == false {
                switch type {
                case .global:
                    monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: internalHandler)
                case .local:
                    monitor = NSEvent.addLocalMonitorForEvents(matching: mask, handler: internalLocalHandler)
                }
            }
        }

        public func stop() {
            if isRunning, let monitor = monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
        }
    }
}

#endif
