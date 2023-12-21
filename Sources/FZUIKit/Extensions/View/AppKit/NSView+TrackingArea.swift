//
//  NSView+TrackingArea.swift
//
//
//  Adopted from:
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  Created by Florian Zand on 19.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSView {
    /// A tracking area that tracks a view
    public class TrackingArea {
        /// One or more constants that specify the type of tracking area, the situations when the area is active, and special behaviors of the tracking area.
        public var options: NSTrackingArea.Options {
            didSet {
                self.update()
            }
        }
        
        /// A rectangle that defines a region of the tracked view for tracking events related to mouse tracking and cursor updating. The specified rectangle should not exceed the view’s bounds rectangle.
        public var trackingRect: CGRect? {
            didSet {
                self.update()
            }
        }

        /**
        Creates a tracking area.
         
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
         
        - Note: This should be called in your `updateTrackingAreas()` method.
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

    /**
     The options for creating a tracking area for the view.  The default value is `nil`.
     
     Providing a non `nil` option will add a tracking area that tracks the view with the options and adds a default implementation for `updateTrackingAreas()`.
     */
    public var trackingAreaOptions: NSTrackingArea.Options? {
        get { getAssociatedValue(key: "trackingAreaOptions", object: self, initialValue: nil ) }
        set {
            set(associatedValue: newValue, key: "trackingAreaOptions", object: self)
            updateTrackingArea()
        }
    }
    
    var trackingArea: TrackingArea {
        get { getAssociatedValue(key: "trackingArea", object: self, initialValue: TrackingArea(for: self, options: trackingAreaOptions ?? []) ) }
    }
    
    var didReplaceUpdateTrackingAreas: Bool {
        get { getAssociatedValue(key: "didReplaceUpdateTrackingAreas", object: self, initialValue: false ) }
        set { set(associatedValue: newValue, key: "didReplaceUpdateTrackingAreas", object: self) }
    }
    
    func updateTrackingArea() {
        if let trackingAreaOptions = trackingAreaOptions{
            trackingArea.options = trackingAreaOptions
            if didReplaceUpdateTrackingAreas == false {
                do {
                    try self.replaceMethod(
                        #selector(updateTrackingAreas),
                        methodSignature: (@convention(c)  (AnyObject, Selector) -> Void).self,
                        hookSignature: (@convention(block)  (AnyObject) -> Void).self) { store in { object in
                            (object as? NSView)?.trackingArea.update()
                        }
                        }
                    didReplaceUpdateTrackingAreas = true
                } catch {
                    Swift.debugPrint(error)
                }
            }
        } else if didReplaceUpdateTrackingAreas {
            didReplaceUpdateTrackingAreas = false
            self.resetMethod(#selector(updateTrackingAreas))
        }
    }
    
    func trackingArea(_ options: NSTrackingArea.Options) -> TrackingArea {
        let trackingArea = getAssociatedValue(key: "TrackingArea", object: self, initialValue: TrackingArea(for: self, options: options))
        trackingArea.options = options
        trackingArea.update()
        
        do {
            try self.replaceMethod(
                #selector(updateTrackingAreas),
                methodSignature: (@convention(c)  (AnyObject, Selector) -> Void).self,
                hookSignature: (@convention(block)  (AnyObject) -> Void).self) { store in { object in
                    guard let view = (object as? NSView) else { return }
                    let trackingArea = getAssociatedValue(key: "TrackingArea", object: view, initialValue: TrackingArea(for: view, options: options))
                    trackingArea.update()
                }
                }
        } catch {
            Swift.debugPrint(error)
        }
        
        return trackingArea
    }
}

#endif