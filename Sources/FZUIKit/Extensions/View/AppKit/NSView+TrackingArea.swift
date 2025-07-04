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
        open class TrackingArea {
            weak var view: NSView?
            var trackingArea: NSTrackingArea?
            
            /// One or more constants that specify the type of tracking area, the situations when the area is active, and special behaviors of the tracking area.
            open var options: NSTrackingArea.Options {
                didSet { update() }
            }

            /**
             A rectangle that defines a region of the tracked view for tracking events related to mouse tracking and cursor updating.
             
             The specified rectangle should not exceed the view’s bounds rectangle.
             
             The default value is `nil` which uses the view's bounds.
             */
            open var trackingRect: CGRect? {
                didSet { update() }
            }
            
            /**
             Creates a tracking area.

             - Parameters:
              - view: The view to add tracking to.
              - rect: The area inside the view to track. The default value is `nil` which uses the view's bounds.
              - options: The options for tracking.
             */
            public init(for view: NSView, rect: CGRect? = nil, options: NSTrackingArea.Options = []) {
                self.view = view
                trackingRect = rect
                self.options = options
            }

            /**
             Updates the tracking area.
             
             This should be called inside  the view's [updateTrackingAreas()](https://developer.apple.com/documentation/appkit/nsview/updatetrackingareas()).
             */
            open func update() {
                if let trackingArea = trackingArea {
                    view?.removeTrackingArea(trackingArea)
                }

                if let view = view, !options.isEmpty {
                    let newTrackingArea = NSTrackingArea(
                        rect: trackingRect ?? view.bounds,
                        options: options,
                        owner: self.view,
                        userInfo: nil
                    )

                    view.addTrackingArea(newTrackingArea)
                    trackingArea = newTrackingArea
                }
            }
            
            deinit {
                guard let trackingArea = trackingArea else { return }
                view?.removeTrackingArea(trackingArea)
            }
        }
    }

#endif
