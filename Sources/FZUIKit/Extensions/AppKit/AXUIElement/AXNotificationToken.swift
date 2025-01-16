//
//  AXNotificationToken.swift
//  
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Foundation

/**
 A token representing an observer for notifications.

 The notification is observed until you deallocate the token.
 */
public class AXNotificationToken: AXNotificationReceiver {
    /// The observed notification.
    public var notification: AXNotification {
        key.notification
    }
    
    /// The observed `AXUIElement`.
    public var element: AXUIElement? {
        key.source
    }
    
    /// A Boolean value indicating whether the observation is active.
    public var isActive: Bool {
        get { _isActive }
        set {
            guard newValue != isActive, let observer = observer else { return }
            if newValue {
                try? observer.register(self)
            } else {
                try? observer.deregister(self)

            }
        }
    }
    
    /// Invalidates the observation.
    public func invalidate() {
        guard _isActive else { return }
        try? observer?.deregister(self)
    }
    
    let key: AXNotificationKey
    let handler: (AXUIElement)->()
    weak var observer: AXNotificationObserver?
    var _isActive = false
    
    init(_ key: AXNotificationKey, observer: AXNotificationObserver, handler: @escaping (AXUIElement) -> Void) {
        self.key = key
        self.handler = handler
        self.observer = observer
    }
    
    func receive(target: AXUIElement) {
        handler(target)
    }
    
    deinit {
        invalidate()
    }
}
#endif
