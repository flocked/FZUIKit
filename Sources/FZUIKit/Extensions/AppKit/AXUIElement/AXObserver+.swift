//
//  AXObserver+.swift
//
//
//  Created by Florian Zand on 16.01.25.
//

#if canImport(ApplicationServices) && os(macOS)
import Foundation
import ApplicationServices

public extension AXObserver {
    /// Registers the observer to receive notifications from the specified accessibility object.
    func add(notification: AXNotification, element: AXUIElement, context: AnyObject) throws {
        try DispatchQueue.main.syncSafely {
            let notification = notification.rawValue as CFString
            let context = Unmanaged.passUnretained(context).toOpaque()
            let result = AXObserverAddNotification(self, element, notification, context)
            if let error = AXError(code: result), case .notificationAlreadyRegistered = error {
                throw error
            }
        }
    }

    /// Removes the specified notification from the observer for the specified accessibility object.
    func remove(notification: AXNotification, element: AXUIElement) throws {
        try DispatchQueue.main.syncSafely {
            let notification = notification.rawValue as CFString
            let result = AXObserverRemoveNotification(self, element, notification)
            if let error = AXError(code: result), case .notificationNotRegistered = error {
                throw error
            }
        }
    }
}

#endif
