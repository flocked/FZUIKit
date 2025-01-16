//
//  AXNotificationObserver.swift
//
//
//  Created by Florian Zand on 15.01.25.
//

#if canImport(ApplicationServices)
import ApplicationServices
import Combine
import Foundation

/// Manages the notification subscriptions for the application with given `pid`.
final class AXNotificationObserver {
    /// Global shared observer instances per `pid`.
   private static var observers: [pid_t: AXNotificationObserver] = [:]

    /// Gets the shared observer for the application with given `pid`, creating it if needed.
    static func shared(for pid: pid_t) -> AXNotificationObserver {
        if let observer = observers[pid] {
            return observer
        } else {
            let observer = AXNotificationObserver(pid: pid)
            observers[pid] = observer
            return observer
        }
    }

    private let pid: pid_t

    private init(pid: pid_t) {
        self.pid = pid
    }

    deinit {
        if let obs = _observer {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(obs), .defaultMode)
        }
    }

    /// Returns a new publisher for a notification emitted by the given source `element`.
    func publisher(for notification: AXNotification, element: AXUIElement) -> AXNotificationPublisher {
        AXNotificationPublisher(observer: self, key: AXNotificationKey(notification: notification, source: element))
    }
    
    func observation(_ notification: AXNotification, element: AXUIElement, handler: @escaping (AXUIElement) -> Void) throws -> AXNotificationToken {
        let token = AXNotificationToken(.init(notification: notification, source: element), observer: self, handler: handler)
        try register(token)
        return token
    }

    // MARK: - Subscriptions

    private var subscriptions: [AXNotificationKey: NotificationSubscription] = [:]

    /// Registers a new `receiver`, creating a shared `NotificationSubscription` if needed.
    func register(_ receiver: any AXNotificationReceiver) throws {
        
        let subscription = subscriptions[receiver.key] ?? NotificationSubscription(key: receiver.key)
        subscriptions[receiver.key] = subscription
        if subscription.isEmpty {
            try observer().add(
                notification: receiver.key.notification,
                element: receiver.key.source,
                context: subscription
            )
        }
        subscription.add(receiver)
        receiver._isActive = true
    }

    /// Removes a `receiver` previously registered.
    func deregister(_ receiver: AXNotificationReceiver) throws {
        guard let subscription = subscriptions[receiver.key] else {
            assertionFailure("No subscription found")
            return
        }

        subscription.remove(receiver)
        receiver._isActive = false

        if subscription.isEmpty {
            try observer().remove(
                notification: receiver.key.notification,
                element: receiver.key.source
            )
        }
    }

    // MARK: - AXObserver

    /// Returns the `AXObserver` instance for this application, creating it if needed.
    private func observer() throws -> AXObserver {
        if let obs = _observer {
            return obs
        }

        let callback: AXObserverCallback = { _, element, _, refcon in
            precondition(refcon != nil)
            Unmanaged<NotificationSubscription>
                .fromOpaque(refcon!).takeUnretainedValue()
                .receive(target: element)
        }

        try AXObserverCreate(pid, callback, &_observer).throwIfError()
        
        /*
         let callback: AXObserverCallbackWithInfo = { _, element, _, userInfo, refcon in
             precondition(refcon != nil)
             Unmanaged<NotificationSubscription>
                 .fromOpaque(refcon!).takeUnretainedValue()
                 .receive(target: element)
         }

        // try AXObserverCreate(pid, callback, &_observer).throwIfError()
         try AXObserverCreateWithInfoCallback(pid, callback, &_observer).throwIfError()
         */

        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(_observer!), .defaultMode)
        return _observer!
    }

    private var _observer: AXObserver?
}

/// Identifies uniquely a `notification` with an associated `source` accessibility element.
struct AXNotificationKey: Hashable {
    let notification: AXNotification
    let source: AXUIElement
}

/// A global subscription to the notification identified with `key`.
///
/// It manages a list of `AXNotificationReceiver` representing individual publisher subscriptions.
private class NotificationSubscription {
    let key: AXNotificationKey
    var receivers: [any AXNotificationReceiver] = []

    init(key: AXNotificationKey) {
        self.key = key
    }

    var isEmpty: Bool {
        receivers.isEmpty
    }

    func add(_ receiver: any AXNotificationReceiver) {
        precondition(receiver.key == key)
        receivers.append(receiver)
    }

    func remove(_ receiver: any AXNotificationReceiver) {
        precondition(receiver.key == key)
        receivers.removeAll { ObjectIdentifier($0) == ObjectIdentifier(receiver) }
    }

    func receive(target: AXUIElement) {
        for receiver in receivers {
            receiver.receive(target: target)
        }
    }
}

/// Adapter protocol used to connect a `NotificationSubscription` with a publisher
/// subscription.
protocol AXNotificationReceiver: AnyObject {
    /// Notification key to observe.
    var key: AXNotificationKey { get }
 
    var _isActive: Bool { get set }

    /// Callback when the notification is received with the given `target` element.
    func receive(target: AXUIElement)
}

/// Combine publisher to observe `AXNotification` events.
struct AXNotificationPublisher: Publisher {
    public typealias Output = AXUIElement
    public typealias Failure = Error

    private let observer: AXNotificationObserver
    private let key: AXNotificationKey

    fileprivate init(observer: AXNotificationObserver, key: AXNotificationKey) {
        self.observer = observer
        self.key = key
    }

    public func receive<S>(
        subscriber: S
    ) where S: Subscriber, S.Input == AXUIElement, S.Failure == Error {
        let subscription = Subscription(observer: observer, key: key, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
        do {
            try observer.register(subscription)
        } catch {
            subscriber.receive(completion: .failure(error))
        }
    }

    private class Subscription<S: Subscriber>:
        AXNotificationReceiver,
        Combine.Subscription where S.Input == AXUIElement, S.Failure == Error {
        private let observer: AXNotificationObserver
        let key: AXNotificationKey
        private var subscriber: S?
        var _isActive = false

        init(observer: AXNotificationObserver, key: AXNotificationKey, subscriber: S) {
            self.observer = observer
            self.key = key
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            try? observer.deregister(self)
            subscriber = nil
        }

        func receive(target: AXUIElement) {
            _ = subscriber?.receive(target)
        }
    }
}


#endif

