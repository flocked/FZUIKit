//
//  AppKitDisplayLink.swift
//
//
//  Created by Florian Zand on 04.12.23.
//

import AppKit
import QuartzCore
import SwiftUI

@available(macOS 14.0, *)
public final class AppKitDisplayLink {
    // Represents a frame that is about to be drawn
    public struct Frame {
        // The system timestamp for the frame to be drawn
        public var timestamp: TimeInterval
        
        // The duration between each display update
        public var duration: TimeInterval
    }
    
    /// The callback to call for each frame.
    public var onFrame: ((Frame) -> Void)?
    
    /// If the display link is paused or not.
    public var isPaused: Bool {
        get { displayLink.isPaused }
        set { displayLink.isPaused = newValue }
    }
    
    /// The preferred framerate range.
    public var preferredFrameRateRange: CAFrameRateRange {
        get { displayLink.preferredFrameRateRange }
        set { displayLink.preferredFrameRateRange = newValue }
    }
    
    /// The time interval between screen refresh updates.
    public var duration: CFTimeInterval {
        displayLink.duration
    }
    
    /// The time interval that represents when the last frame displayed.
    public var timestamp: CFTimeInterval {
        displayLink.timestamp
    }
    
    /// The time interval that represents when the next frame displays.
    public var targetTimestamp: CFTimeInterval {
        displayLink.targetTimestamp
    }
    
    /// The framesPerSecond of the displaylink.
    public var framesPerSecond: CGFloat {
        1 / (displayLink.targetTimestamp - displayLink.timestamp)
    }
    
    /// The CADisplayLink that powers this DisplayLink instance.
    internal let displayLink: CADisplayLink
    
    /// The target for the CADisplayLink (because CADisplayLink retains its target).
    internal let target = DisplayLinkTarget()
    
    /// Creates a new paused DisplayLink instance for the main window. Returns `nil` if there isn't a main screen.
    public convenience init?() {
        guard let screen = NSScreen.main else {
            return nil
        }
        self.init(screen: screen)
    }
    
    /// Creates a new paused DisplayLink instance for the specified screen.
    public init(screen: NSScreen) {
        displayLink = screen.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        target.callback = { [unowned self] frame in
            self.onFrame?(frame)
        }
    }
    
    /// Creates a new paused DisplayLink instance for the specified view. The displaylink will automatically track the display the view is on, and will be automatically suspended if it isn’t on a display.
    public init(view: NSView) {
        displayLink = view.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        target.callback = { [unowned self] frame in
            self.onFrame?(frame)
        }
    }
    
    /// Creates a new paused DisplayLink instance for the specified window. The displaylink will automatically track the display the window is on, and will be automatically suspended if it isn’t on a display.
    public init(window: NSWindow) {
        displayLink = window.displayLink(target: target, selector: #selector(DisplayLinkTarget.frame(_:)))
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        target.callback = { [unowned self] frame in
            self.onFrame?(frame)
        }
    }
    
    deinit {
        displayLink.invalidate()
    }
    
    /// The target for the CADisplayLink (because CADisplayLink retains its target).
    internal final class DisplayLinkTarget {
        /// The callback to call for each frame.
        var callback: ((Frame) -> Void)?
        
        /// Called for each frame from the CADisplayLink.
        @objc dynamic func frame(_ displayLink: CADisplayLink) {
            let frame = Frame(
                timestamp: displayLink.timestamp,
                duration: displayLink.duration
            )
            callback?(frame)
        }
    }
}
