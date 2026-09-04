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

public extension NSView {
    /// A region of a view that generates mouse-tracking and cursor-update events when the pointer is over that region.
    class TrackingArea {
        /// The view associated with the tracking area.
        public private(set) weak var view: NSView?
        private var trackingArea: NSTrackingArea?
                
        /**
         A Boolean value indicating whether the tracking area is enabled.
         
         The default value is `true`.
         */
        public var isEnabled: Bool = true {
            didSet {
                guard oldValue != isEnabled else { return }
                update()
            }
        }
        
        private var options: NSTrackingArea.Options = [] {
            didSet {
                guard oldValue != options else { return }
                update()
            }
        }
        
        /**
         The rectangle in the view's coordinate system in which mouse events are tracked, or `nil` to track the view's visible area ([visibleRect](https://developer.apple.com/documentation/appkit/nsview/visiblerect)).
         
         The default value is `nil`.
         */
        public var trackingRect: CGRect? {
            didSet {
                guard oldValue != trackingRect else { return }
                update()
            }
        }
        
        /**
         Updates the tracking area.

         Call this method from the view's [updateTrackingAreas()](https://developer.apple.com/documentation/appkit/nsview/updatetrackingareas()) when the tracking area needs to be updated.
         */
        public func update() {
            guard let view else { return }
            if let trackingArea {
                view.removeTrackingArea(trackingArea)
                self.trackingArea = nil
            }
            
            guard isEnabled, !events.isEmpty else { return }
            var options = options
            options[.inVisibleRect] = trackingRect == nil
            let rect = trackingRect.map { view.bounds.intersection($0) } ?? view.bounds
            guard trackingRect == nil || !rect.isNull else { return }
            let trackingArea = NSTrackingArea(rect: rect, options: options, owner: view, userInfo: nil)
            view.trackingAreas
            view.addTrackingArea(trackingArea)
            self.trackingArea = trackingArea
        }
        
        /// The events tracked by the tracking area.
        public var events: Events {
            get { .init(rawValue: options.intersection([.cursorUpdate, .mouseMoved, .mouseEnteredAndExited]).rawValue) }
            set {
                guard newValue != events else { return }
                var options = options
                options.remove(.init(rawValue: events.rawValue))
                options.insert(.init(rawValue: newValue.rawValue))
                self.options = options
            }
        }
        
        /**
         The conditions under which the tracking area is active.
         
         The default value is ``Activation/inKeyWindow``.
         */
        public var activation: Activation {
            get { .init(rawValue: options.intersection([.activeWhenFirstResponder, .activeInKeyWindow, .activeInActiveApp, .activeAlways]).rawValue)! }
            set {
                guard newValue != activation else { return }
                var options = options
                options.remove(.init(rawValue: activation.rawValue))
                options.insert(.init(rawValue: newValue.rawValue))
                self.options = options
            }
        }
        
        /**
         A Boolean value indicating whether the first event is generated when the cursor leaves the tracking area, regardless of whether the cursor is inside the area when the tracking area is added to the view.
         
         The default value is `false`, which specifies that the first event is generated when the cursor leaves the tracking area if the cursor is initially inside it, or when the cursor enters the area if the cursor is initially outside it.
         
         Generally, you do not want to enable this behavior.
         */
        public var assumesInside: Bool {
            get { options[.assumeInside] }
            set { options[.assumeInside] = newValue }
        }

        /**
         A Boolean value indicating whether the view receives [mouseEntered(with:)](https://developer.apple.com/documentation/appkit/nsresponder/mouseentered(with:)) events when the mouse cursor is dragged into the tracking area.
         
         The default value is `false`, which specifies that the view receives the events only when the mouse moves into the tracking area with no buttons pressed, or on `NSLeftMouseUp` after a mouse drag.
         */
        public var isEnabledDuringMouseDrag: Bool {
            get { options[.enabledDuringMouseDrag] }
            set { options[.enabledDuringMouseDrag] = newValue }
        }
        
        /**
         Creates a tracking area for the specified mouse events in the view.
         
         - Parameters:
           - view: The view in which mouse events are tracked.
           - rect: The rectangle in the view's coordinate system in which mouse events are tracked, or `nil` to track the view's visible area.
           - events: The mouse events to track.
           - activation: The condition under which the tracking area is active.
           - assumesInside: A Boolean value indicating whether the mouse is assumed to be inside the tracking area when tracking begins.
           - isEnabledDuringMouseDrag: A Boolean value indicating whether the view receives mouse-entered events when the mouse cursor is dragged into the tracking area.
         */
        public init(view: NSView, rect: CGRect? = nil, events: Events, activation: Activation = .inKeyWindow, assumesInside: Bool = false, isEnabledDuringMouseDrag: Bool = false) {
            self.view = view
            trackingRect = rect
            options = .init(rawValue: events.rawValue)
            options.insert(.init(rawValue: activation.rawValue))
            options[.assumeInside] = assumesInside
            options[.enabledDuringMouseDrag] = isEnabledDuringMouseDrag
            update()
        }
        
        deinit {
            guard let trackingArea else { return }
            view?.removeTrackingArea(trackingArea)
        }
        
        /// The events tracked by a tracking area.
        public struct Events: OptionSet, Sendable {
            /// The view receives [mouseEntered(with:)](https://developer.apple.com/documentation/appkit/nsresponder/mouseentered(with:)) when the mouse cursor enters the tracking area and [mouseExited(with:)](https://developer.apple.com/documentation/appkit/nsresponder/mouseexited(with:)) when the mouse cursor leaves it.
            public static let mouseEnteredAndExited = Self(rawValue: 1 << 0)
            /// The view receives [mouseMoved(with:)](https://developer.apple.com/documentation/appkit/nsresponder/mousemoved(with:)) events while the mouse cursor is within the tracking area.
            public static let mouseMoved = Self(rawValue: 1 << 1)
            /// The view receives [cursorUpdate(with:)](https://developer.apple.com/documentation/appkit/nsresponder/cursorupdate(with:)) events when the mouse cursor enters the tracking area.
            public static let cursorUpdate = Self(rawValue: 1 << 2)
            
            public let rawValue: UInt

            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
        }
        
        /// The conditions under which a tracking area is active.
        public enum Activation: UInt {
            /// The tracking area is active when the view is the first responder.
            case whenFirstResponder = 16
            /// The tracking area is active when the view's [window](https://developer.apple.com/documentation/appkit/nsview/window) is the key window.
            case inKeyWindow = 32
            /// The tracking area is active when the application is active.
            case inActiveApp = 64
            /**
             The tracking area is always active.
             
             The view doesn't receive [cursorUpdate(with:)](https://developer.apple.com/documentation/appkit/nsresponder/cursorupdate(with:)) events when ``TrackingArea/Events/cursorUpdate`` is enabled.
             */
            case always = 128
        }
    }
}
#endif
