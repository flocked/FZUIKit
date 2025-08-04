//
//  DisplayLink.swift
//
//
//  Created by Florian Zand on 03.07.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(iOS 15.0, tvOS 15.0, macOS 14.0, *)
public class DisplayLink {
    /// Represents a frame that is about to be drawn.
    public struct Frame {
        /// The system timestamp for the frame to be drawn.
        public var timestamp: TimeInterval

        /// The duration between each display update.
        public var duration: TimeInterval
    }
    
    /// The handler that is called for each new frame on the display.
    public var onFrame: ((Frame) -> Void)

    /// A Boolean value indicating whether the display link is paused or not.
    public var isPaused: Bool {
        get { displayLink.isPaused }
        set { displayLink.isPaused = newValue }
    }

    /// The preferred framerate range.
    @available(iOS 15.0, tvOS 15.0, macOS 14.0, *)
    public var preferredFrameRateRange: CAFrameRateRange {
        get { displayLink.preferredFrameRateRange }
        set { displayLink.preferredFrameRateRange = newValue }
    }
    
    /// The frames per second of the displaylink.
    var framesPerSecond: CGFloat {
        1 / (displayLink.targetTimestamp - displayLink.timestamp)
    }
    
    let displayLink: CADisplayLink

    let target = DisplayLinkTarget()
    
    #if os(macOS)
    /// Creates a new paused DisplayLink instance for the main screen.
    public init?(preferredFrameRateRange: CAFrameRateRange? = nil, onFrame: @escaping ((_ frame: Frame) -> Void)) {
        guard let screen = NSScreen.main else {
            return nil
        }
        self.onFrame = onFrame
        displayLink = screen.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        sharedInit(screen: screen, frameRateRange: preferredFrameRateRange)
    }

    /// Creates a new paused DisplayLink instance for the specified view.
    public init(view: NSView, preferredFrameRateRange: CAFrameRateRange? = nil, onFrame: @escaping ((_ frame: Frame) -> Void)) {
        self.onFrame = onFrame
        displayLink = view.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        sharedInit(screen: view.window?.screen, frameRateRange: preferredFrameRateRange)
    }

    /// Creates a new paused DisplayLink instance for the specified window.
    public init(window: NSWindow, preferredFrameRateRange: CAFrameRateRange? = nil, onFrame: @escaping ((_ frame: Frame) -> Void)) {
        self.onFrame = onFrame
        displayLink = window.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        sharedInit(screen: window.screen, frameRateRange: preferredFrameRateRange)
    }

    /// Creates a new paused DisplayLink instance for the specified screen.
    public init(screen: NSScreen, preferredFrameRateRange: CAFrameRateRange? = nil, onFrame: @escaping ((_ frame: Frame) -> Void)) {
        self.onFrame = onFrame
        displayLink = screen.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        sharedInit(screen: screen, frameRateRange: preferredFrameRateRange)
    }
    
    private func sharedInit(screen: NSScreen?, frameRateRange: CAFrameRateRange?) {
        if let frameRateRange = frameRateRange {
            preferredFrameRateRange = frameRateRange
        } else if let screen = screen {
            let maximumFramesPerSecond = Float(screen.maximumFramesPerSecond)
            let highFPSEnabled = maximumFramesPerSecond > 60
            let minimumFPS: Float = Swift.min(highFPSEnabled ? 80 : 60, maximumFramesPerSecond)
            preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
        }
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        target.callback = { [unowned self] frame in
            self.onFrame(frame)
        }
    }
    
    deinit {
        displayLink.invalidate()
    }

    #else
    /// Creates a new paused DisplayLink instance.
    @available(iOS 15.0, tvOS 15.0, *)
    public convenience init(preferredFrameRateRange: CAFrameRateRange? = nil, onFrame: @escaping ((_ frame: Frame) -> Void)) {
        self.init(onFrame: onFrame)
        if let preferredFrameRateRange = preferredFrameRateRange {
            self.preferredFrameRateRange = preferredFrameRateRange
        } else {
            let maximumFramesPerSecond = Float(UIScreen.main.maximumFramesPerSecond)
            let highFPSEnabled = maximumFramesPerSecond > 60
            let minimumFPS: Float = Swift.min(highFPSEnabled ? 80 : 60, maximumFramesPerSecond)
            self.preferredFrameRateRange = .init(minimum: minimumFPS, maximum: maximumFramesPerSecond, preferred: maximumFramesPerSecond)
        }
    }

    /// Creates a new paused DisplayLink instance.
    public init(onFrame: @escaping ((_ frame: Frame) -> Void)) {
        displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        self.onFrame = onFrame
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        target.callback = { [unowned self] frame in
            self.onFrame(frame)
        }
    }
    #endif
    
    class DisplayLinkTarget {
        var callback: ((DisplayLink.Frame) -> Void)?

        #if os(macOS)
        @objc dynamic func frame(_ displayLink: CADisplayLink) {
            let frame = Frame(
                timestamp: displayLink.timestamp,
                duration: displayLink.duration
            )
            callback?(frame)
        }
        #else
        @objc dynamic func frame(_ displayLink: CADisplayLink) {
            let frame = Frame(
                timestamp: displayLink.timestamp,
                duration: displayLink.duration
            )
            callback?(frame)
        }
        #endif
    }
}

#endif
