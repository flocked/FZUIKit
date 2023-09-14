//
//  DisplayLinkTimer+Publisher.swift
//
//
//  Created by Florian Zand on 14.10.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Combine
import CoreGraphics
import Foundation
import QuartzCore

public extension DisplayLinkTimer {
    static func publish(every interval: TimeInterval) -> DisplayLinkTimer.TimerPublisher {
        return DisplayLinkTimer.TimerPublisher(interval: interval)
    }
}

public extension DisplayLinkTimer {
    class TimerPublisher: ConnectablePublisher {
        public typealias Output = Date
        public typealias Failure = Never

        public var interval: TimeInterval

        public init(interval: TimeInterval) {
            self.interval = interval
        }

        internal var isConnected = false
        public func connect() -> Cancellable {
            isConnected = true
            startDisplayLink()
            let subscription = Subscription(onCancel: { [weak self] in
                self?.isConnected = false
                self?.stopDisplayLink()
            })

            return subscription
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Date == S.Input {
            dispatchPrecondition(condition: .onQueue(.main))

            let typeErased = AnySubscriber(subscriber)
            let identifier = typeErased.combineIdentifier
            let subscription = Subscription(onCancel: { [weak self] in
                self?.cancelSubscription(for: identifier)
            })
            subscribers[identifier] = typeErased
            subscriber.receive(subscription: subscription)
        }

        private func cancelSubscription(for identifier: CombineIdentifier) {
            dispatchPrecondition(condition: .onQueue(.main))
            subscribers.removeValue(forKey: identifier)
        }

        private func send(date: Date) {
            dispatchPrecondition(condition: .onQueue(.main))
            let subscribers = self.subscribers.values
            subscribers.forEach {
                _ = $0.receive(date) // Ignore demand
            }
        }

        private var subscribers: [CombineIdentifier: AnySubscriber<Date, Never>] = [:] {
            didSet {
                dispatchPrecondition(condition: .onQueue(.main))
                if subscribers.isEmpty {
                    stopDisplayLink()
                } else {
                    startDisplayLink()
                }
            }
        }

        private func stopDisplayLink() {
            displayLink?.cancel()
        }

        internal var isRunning = false
        private func startDisplayLink() {
            if displayLink == nil && isConnected {
                previousTimestamp = 0.0
                timeIntervalSinceLastFire = 0.0
                isRunning = false
                displayLink = DisplayLink.shared.sink(receiveValue: { [weak self] frame in
                    guard let self = self else { return }
                    if self.isRunning == false {
                        self.isRunning = true
                        self.previousTimestamp = frame.timestamp
                    }
                    let timeIntervalCount = frame.timestamp - self.previousTimestamp
                    self.timeIntervalSinceLastFire = self.timeIntervalSinceLastFire + timeIntervalCount
                    self.previousTimestamp = frame.timestamp
                    if self.timeIntervalSinceLastFire > self.interval {
                        self.timeIntervalSinceLastFire = 0.0
                        self.send(date: Date())
                    }
                })
            }
        }

        internal var displayLink: AnyCancellable? = nil
        internal var previousTimestamp: TimeInterval = 0.0
        internal var timeIntervalSinceLastFire: TimeInterval = 0.0
    }
}

private extension DisplayLinkTimer.TimerPublisher {
    final class Subscription: Combine.Subscription {
        var onCancel: () -> Void
        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }

        func request(_: Subscribers.Demand) {
            // Do nothing – subscribers can't impact how often the system draws frames.
        }

        func cancel() {
            onCancel()
        }
    }
}
#endif
