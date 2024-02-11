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
            /// One or more constants that specify the type of tracking area, the situations when the area is active, and special behaviors of the tracking area.
            open var options: NSTrackingArea.Options {
                didSet {
                    update()
                }
            }

            /// A rectangle that defines a region of the tracked view for tracking events related to mouse tracking and cursor updating. The specified rectangle should not exceed the view’s bounds rectangle.
            open var trackingRect: CGRect? {
                didSet {
                    update()
                }
            }

            /**
             Creates a tracking area.

             - Parameters:
              - view: The view to add tracking to.
              - rect: The area inside the view to track. The default value is `nil` which uses the view's bounds.
              - options: The options for tracking. The default value is `[]` which doesn't track anything.
             */
            public init(for view: NSView, rect: CGRect? = nil, options: NSTrackingArea.Options = []) {
                self.view = view
                trackingRect = rect
                self.options = options
            }

            /**
             Updates the tracking area.

             - Note: This should be called in your `updateTrackingAreas()` method.
             */
            open func update() {
                if let trackingArea = trackingArea {
                    view?.removeTrackingArea(trackingArea)
                }

                if let view = view {
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

            private weak var view: NSView?
            private var trackingArea: NSTrackingArea?
        }

        /**
         The options for creating a tracking area for the view.  The default value is `nil`.

         Providing a non `nil` option will add a tracking area that tracks the view with the options.
         */
        public var trackingAreaOptions: NSTrackingArea.Options? {
            get { getAssociatedValue(key: "trackingAreaOptions", object: self, initialValue: nil) }
            set {
                set(associatedValue: newValue, key: "trackingAreaOptions", object: self)
                updateTrackingArea()
            }
        }

        var _trackingArea: TrackingArea? {
            get { getAssociatedValue(key: "_trackingArea", object: self, initialValue: TrackingArea(for: self, options: trackingAreaOptions ?? [])) }
            set { set(associatedValue: newValue, key: "_trackingArea", object: self) }
        }

        var replaceUpdateTrackingAreasToken: ReplacedMethodToken? {
            get { getAssociatedValue(key: "replaceUpdateTrackingAreasToken", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "replaceUpdateTrackingAreasToken", object: self) }
        }
        
        static var didSwizzleUpdateTrackingAreas: Bool {
            get { getAssociatedValue(key: "didSwizzleUpdateTrackingAreas", object: self, initialValue: false) }
            set { set(associatedValue: newValue, key: "didSwizzleUpdateTrackingAreas", object: self) }
        }
        
        @objc func swizzled_updateTrackingAreas() {
            
            swizzled_updateTrackingAreas()
        }
        
        static func swizzleUpdateTrackingAreas() {
            guard didSwizzleUpdateTrackingAreas == false else { return }
            didSwizzleUpdateTrackingAreas = true
            _ = try? Swizzle(NSView.self) {
                #selector(updateTrackingAreas) <-> #selector(updateTrackingAreas)
            }
        }

        func updateTrackingArea() {
            if let trackingAreaOptions = trackingAreaOptions {
                if _trackingArea == nil {
                    _trackingArea = TrackingArea(for: self, options: trackingAreaOptions)
                }
                _trackingArea?.options = trackingAreaOptions
                if replaceUpdateTrackingAreasToken == nil {
                    do {
                        replaceUpdateTrackingAreasToken = try replaceMethod(
                            #selector(updateTrackingAreas),
                            methodSignature: (@convention(c) (AnyObject, Selector) -> Void).self,
                            hookSignature: (@convention(block) (AnyObject) -> Void).self
                        ) { store in { object in
                            (object as? NSView)?._trackingArea?.update()
                            store.original(object, #selector(NSView.updateTrackingAreas))
                        }
                        }
                    } catch {
                        Swift.debugPrint(error)
                    }
                }
            } else if let replaceUpdateTrackingAreasToken = self.replaceUpdateTrackingAreasToken {
                _trackingArea = nil
                resetMethod(replaceUpdateTrackingAreasToken)
                self.replaceUpdateTrackingAreasToken = nil
            }
        }
    }

#endif
