//
//  TrackingArea.swift
//  TrackingArea
//
//  Adopted from:
//  Copyright © 2023 Darren Ford. All rights reserved.
//

#if os(macOS)
import AppKit

/// A tracking area that tracks a view
public class TrackingArea {
    /**
     One or more constants that specify the type of tracking area, the situations when the area is active, and special behaviors of the tracking area.
     */
    public var options: NSTrackingArea.Options {
        didSet {
            self.update()
        }
    }
    
    /**
     A rectangle that defines a region of the tracked view for tracking events related to mouse tracking and cursor updating. The specified rectangle should not exceed the view’s bounds rectangle.
     */
    public var trackingRect: CGRect? {
        didSet {
            self.update()
        }
    }

    /**
    - Parameters:
        - view: The view to add tracking to.
        - rect: The area inside the view to track. Defaults to the whole view (`view.bounds`).
    */
    public init(for view: NSView, rect: CGRect? = nil, options: NSTrackingArea.Options = []) {
        self.view = view
        self.trackingRect = rect
        self.options = options
    }

    /**
    Updates the tracking area.
    - Note: This should be called in your `NSView#updateTrackingAreas()` method.
    */
    public func update() {
        if let trackingArea = self.trackingArea {
            self.view?.removeTrackingArea(trackingArea)
        }
        
        if let view = self.view {
            let newTrackingArea = NSTrackingArea(
                rect: self.trackingRect ?? view.bounds,
                options: self.options,
                owner: self.view,
                userInfo: nil
            )
            
            view.addTrackingArea(newTrackingArea)
            self.trackingArea = newTrackingArea
        }
    }
    
    private weak var view: NSView?
    private var trackingArea: NSTrackingArea?
}

#endif
