//
//  DisplayLink+Combine.swift
//
//
//  Created by Florian Zand on 31.05.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import Combine
    import Foundation

    protocol DisplayLinkProvider: AnyObject {
        var isPaused: Bool { get set }
        var onFrame: ((DisplayLink.Frame) -> Void)? { get set }
    }

    /// A publisher that emits new values when the system is about to update the display.
    public final class DisplayLink: Publisher {
        public typealias Output = Frame
        public typealias Failure = Never

        fileprivate let platformDisplayLink: DisplayLinkProvider

        private var subscribers: [CombineIdentifier: AnySubscriber<Frame, Never>] = [:] {
            didSet {
              //  dispatchPrecondition(condition: .onQueue(.main))
                platformDisplayLink.isPaused = subscribers.isEmpty
           //     Swift.print("didSet", subscribers.isEmpty, platformDisplayLink.isPaused )
            }
        }

        fileprivate init(platformDisplayLink: DisplayLinkProvider) {
        //    dispatchPrecondition(condition: .onQueue(.main))
            self.platformDisplayLink = platformDisplayLink
            self.platformDisplayLink.onFrame = { [weak self] frame in
                self?.send(frame: frame)
            }
        }

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Frame {
         //   dispatchPrecondition(condition: .onQueue(.main))
            let typeErased = AnySubscriber(subscriber)
            let identifier = typeErased.combineIdentifier
            let subscription = Subscription(onCancel: { [weak self] in
                self?.cancelSubscription(for: identifier)
            })
            subscribers[identifier] = typeErased
            subscriber.receive(subscription: subscription)
        }

        private func cancelSubscription(for identifier: CombineIdentifier) {
          //  dispatchPrecondition(condition: .onQueue(.main))
            subscribers.removeValue(forKey: identifier)
        }

        private func send(frame: Frame) {
        //    dispatchPrecondition(condition: .onQueue(.main))
            let subscribers = subscribers.values
            subscribers.forEach {
                _ = $0.receive(frame) // Ignore demand
            }
        }
    }

    public extension DisplayLink {
        /// Represents a frame that is about to be drawn.
        struct Frame {
            /// The system timestamp for the frame to be drawn.
            public var timestamp: TimeInterval

            /// The duration between each display update.
            public var duration: TimeInterval
        }
    }

    public extension DisplayLink {
        @available(iOS 13.0, tvOS 13.0, macOS 10.15, *)
        convenience init() {
            self.init(platformDisplayLink: PlatformDisplayLink())
        }
    }

    #if os(macOS)
        @available(macOS 14.0, *)
        public extension DisplayLink {
            /// Creates a display link for the specified view, optionally with the specified preferred frame rate range. It will automatically track the display the view is on, and will be automatically suspended if it isn’t on a display.
            convenience init(view: NSView, preferredFrameRateRange: CAFrameRateRange? = nil) {
                self.init(platformDisplayLink: PlatformDisplayLinkMac(view: view, preferredFrameRateRange: preferredFrameRateRange))
            }

            /// Creates a display link for the specified window, optionally with the specified preferred frame rate range. It will automatically track the display the window is on, and will be automatically suspended if it isn’t on a display.
            convenience init(window: NSWindow, preferredFrameRateRange: CAFrameRateRange? = nil) {
                self.init(platformDisplayLink: PlatformDisplayLinkMac(window: window, preferredFrameRateRange: preferredFrameRateRange))
            }

            /// Creates a display link for the specified screen, optionally with the specified preferred frame rate range.
            convenience init(screen: NSScreen, preferredFrameRateRange: CAFrameRateRange? = nil) {
                self.init(platformDisplayLink: PlatformDisplayLinkMac(screen: screen, preferredFrameRateRange: preferredFrameRateRange))
            }

            /// Creates a display link for the main screen, optionally with the specified preferred frame rate range. Returns `nil` if there isn't a main screen.
            convenience init(preferredFrameRateRange: CAFrameRateRange? = nil) {
                if let preferredFrameRateRange = preferredFrameRateRange, let platformDisplayLink = PlatformDisplayLinkMac(preferredFrameRateRange: preferredFrameRateRange) {
                    self.init(platformDisplayLink: platformDisplayLink)
                } else {
                    self.init(platformDisplayLink: PlatformDisplayLink())
                }
            }
        }
    #endif

    public extension DisplayLink {
        static let shared = DisplayLink()
    }

    private extension DisplayLink {
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

    #if os(iOS) || os(tvOS)
        import QuartzCore
        import UIKit

        @available(iOS 15.0, tvOS 15.0, *)
        public extension DisplayLink {
            /// Creates a display link, optionally with the specified preferred frame rate range.
            convenience init(preferredFrameRateRange: CAFrameRateRange? = nil) {
                self.init(platformDisplayLink: PlatformDisplayLink(preferredFrameRateRange: preferredFrameRateRange))
            }
        }

        fileprivate extension DisplayLink {
            final class PlatformDisplayLink: DisplayLinkProvider {
                /// The handler that is called for each new frame on the display.
                var onFrame: ((Frame) -> Void)?

                /// A Boolean value that indicates whether the display link is paused or not.
                var isPaused: Bool {
                    get { displayLink.isPaused }
                    set { displayLink.isPaused = newValue }
                }

                /// The preferred framerate range.
                @available(iOS 15.0, tvOS 15.0, *)
                var preferredFrameRateRange: CAFrameRateRange {
                    get { displayLink.preferredFrameRateRange }
                    set { displayLink.preferredFrameRateRange = newValue }
                }
                
                /// The frames per second of the displaylink.
                var framesPerSecond: CGFloat {
                    1 / (displayLink.targetTimestamp - displayLink.timestamp)
                }

                let displayLink: CADisplayLink

                let target = DisplayLinkTarget()

                @available(iOS 15.0, tvOS 15.0, *)
                convenience init(preferredFrameRateRange: CAFrameRateRange? = nil) {
                    self.init()
                    if let preferredFrameRateRange = preferredFrameRateRange {
                        self.preferredFrameRateRange = preferredFrameRateRange
                    }
                }

                init() {
                    displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))

                    if #available(iOS 15.0, tvOS 15.0, *) {
                        let maximumFramesPerSecond = Float(UIScreen.main.maximumFramesPerSecond)
                        let highFPSEnabled = maximumFramesPerSecond > 60
                        let minimumFPS: Float = Swift.min(highFPSEnabled ? 80 : 60, maximumFramesPerSecond)
                        preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
                    }

                    displayLink.isPaused = true
                    displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
                    target.callback = { [unowned self] frame in
                        onFrame?(frame)
                    }
                }

                deinit {
                    displayLink.invalidate()
                }

                final class DisplayLinkTarget {
                    var callback: ((DisplayLink.Frame) -> Void)?

                    @objc dynamic func frame(_ displayLink: CADisplayLink) {
                        let frame = Frame(
                            timestamp: displayLink.timestamp,
                            duration: displayLink.duration
                        )
                        callback?(frame)
                    }
                }
            }
        }

    #elseif os(macOS)
        import AppKit
        import CoreVideo

        fileprivate extension DisplayLink {
            /// A timer object that allows your app to synchronize its drawing to the refresh rate of the display.
            final class PlatformDisplayLink: DisplayLinkProvider {
                /// The handler that is called for each new frame on the display.
                var onFrame: ((Frame) -> Void)?

                /// A Boolean value that indicates whether the display link is paused or not.
                var isPaused: Bool = true {
                    didSet {
                        guard isPaused != oldValue else { return }
                        if isPaused == true {
                            CVDisplayLinkStop(displayLink)
                        } else {
                            CVDisplayLinkStart(displayLink)
                        }
                    }
                }

                var displayLink: CVDisplayLink = {
                    var dl: CVDisplayLink?
                    CVDisplayLinkCreateWithActiveCGDisplays(&dl)
                    return dl!
                }()

                init() {
                    CVDisplayLinkSetOutputHandler(displayLink) { [weak self] _, inNow, inOutputTime, _, _ -> CVReturn in

                        let frame = Frame(
                            timestamp: inNow.pointee.timeInterval,
                            duration: inOutputTime.pointee.timeInterval - inNow.pointee.timeInterval
                        )

                        DispatchQueue.main.async {
                            self?.handle(frame: frame)
                        }

                        return kCVReturnSuccess
                    }
                }

                deinit {
                    isPaused = true
                }

                func handle(frame: Frame) {
                    guard isPaused == false else { return }
                    onFrame?(frame)
                }
            }

            /// A timer object that allows your app to synchronize its drawing to the refresh rate of the display.
            @available(macOS 14.0, *)
            final class PlatformDisplayLinkMac: DisplayLinkProvider {
                /// The handler that is called for each new frame on the display.
                public var onFrame: ((Frame) -> Void)?

                /// A Boolean value that indicates whether the display link is paused or not.
                public var isPaused: Bool {
                    get { displayLink.isPaused }
                    set { displayLink.isPaused = newValue }
                }

                /// The preferred framerate range.
                public var preferredFrameRateRange: CAFrameRateRange {
                    get { displayLink.preferredFrameRateRange }
                    set { displayLink.preferredFrameRateRange = newValue }
                }
                
                /// The frames per second of the displaylink.
                public var framesPerSecond: CGFloat {
                    1 / (displayLink.targetTimestamp - displayLink.timestamp)
                }

                let displayLink: CADisplayLink

                let target = DisplayLinkTarget()

                convenience init?(preferredFrameRateRange: CAFrameRateRange? = nil) {
                    guard let screen = NSScreen.main else {
                        return nil
                    }
                    self.init(screen: screen, preferredFrameRateRange: preferredFrameRateRange)
                }

                init(view: NSView, preferredFrameRateRange: CAFrameRateRange? = nil) {
                    displayLink = view.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
                    sharedInit(screen: view.window?.screen)
                    if let preferredFrameRateRange = preferredFrameRateRange {
                        self.preferredFrameRateRange = preferredFrameRateRange
                    }
                }

                init(window: NSWindow, preferredFrameRateRange: CAFrameRateRange? = nil) {
                    displayLink = window.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
                    sharedInit(screen: window.screen)
                    if let preferredFrameRateRange = preferredFrameRateRange {
                        self.preferredFrameRateRange = preferredFrameRateRange
                    }
                }

                init(screen: NSScreen, preferredFrameRateRange: CAFrameRateRange? = nil) {
                    displayLink = screen.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
                    sharedInit(screen: screen)
                    if let preferredFrameRateRange = preferredFrameRateRange {
                        self.preferredFrameRateRange = preferredFrameRateRange
                    }
                }

                /// Creates a new paused DisplayLink instance.
                convenience init?() {
                    guard let mainScreen = NSScreen.main else {
                        return nil
                    }
                    self.init(screen: mainScreen)
                }

                func sharedInit(screen: NSScreen?) {
                    if let screen = screen {
                        let maximumFramesPerSecond = Float(screen.maximumFramesPerSecond)
                        let highFPSEnabled = maximumFramesPerSecond > 60
                        let minimumFPS: Float = Swift.min(highFPSEnabled ? 80 : 60, maximumFramesPerSecond)
                        preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
                    }
                    displayLink.isPaused = true
                    displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)

                    target.callback = { [unowned self] frame in
                        onFrame?(frame)
                    }
                }

                deinit {
                    displayLink.invalidate()
                }

                final class DisplayLinkTarget {
                    var callback: ((DisplayLink.Frame) -> Void)?

                    @objc dynamic func frame(_ displayLink: CADisplayLink) {
                        let frame = Frame(
                            timestamp: displayLink.timestamp,
                            duration: displayLink.duration
                        )

                        callback?(frame)
                    }
                }
            }
        }
    #endif
#endif
