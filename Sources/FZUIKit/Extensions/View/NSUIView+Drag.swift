//
//  NSUIView+Drag.swift
//  Tester
//
//  Created by Florian Zand on 21.09.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif
    import FZSwiftUtils


    public extension NSUIView {
        /// A value that indicates whether a view is movable by clicking and dragging anywhere in its background.
        enum BackgroundDragOption: Hashable, ExpressibleByBooleanLiteral {
            /// The view is movable.
            case on
            
            /// The view is movable if it's the first responder.
            case ifFirstResponder
            
            /// The view isn't movable.
            case off
            
            public init(booleanLiteral value: Bool) {
                self = value == true ? .on : .off
            }
        }
        
        /// Options for moving the view by it's background.
        struct MovableByBackgroundOptions {
            /// The view bounds to the superview when moved.
            public var boundsToSuperView: Bool = true
            
            /// The margins that the view bounds to the superview when moved.
            public var margins: NSDirectionalEdgeInsets = .zero
        }
        
        /// A value that indicates whether the view is movable by clicking and dragging anywhere in its background.
        var isMovableByViewBackground: BackgroundDragOption {
            get { getAssociatedValue(key: "isMovableByViewBackground", object: self, initialValue: .off) }
            set {
                guard newValue != isMovableByViewBackground else { return }
                set(associatedValue: newValue, key: "isMovableByViewBackground", object: self)
             
                setupDragResizeGesture()
            }
        }
        
        /// The options for moving the view by it's background.
        var movableByBackgroundOptions: MovableByBackgroundOptions {
            get { getAssociatedValue(key: "movableByBackgroundOptions", object: self, initialValue: MovableByBackgroundOptions()) }
            set { set(associatedValue: newValue, key: "movableByBackgroundOptions", object: self) }
        }

        /// A handler that provides the moved velocity when the view ``isMovableByViewBackground``.
        var movableByBackgroundVelocity: ((CGPoint) -> Void)? {
            get { getAssociatedValue(key: "movableByBackgroundVelocity", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "movableByBackgroundVelocity", object: self) }
        }

        internal func setupDragResizeGesture() {
            if isMovableByViewBackground != .off {
                if panGesture == nil {
                    panGesture = NSUIPanGestureRecognizer { [weak self] gesture in
                        guard let self = self, self.isMovableByViewBackground != .ifFirstResponder || self.isFirstResponder else { return }
                        self.movableByBackgroundVelocity?(gesture.velocity(in: self))
                        switch gesture.state {
                        case .began:
                            self.dragPoint = self.frame.origin
                        case .ended:
                            self.dragPoint = self.frame.origin
                        case .changed:
                            let translation = gesture.translation(in: self)
                            var dragPoint = self.dragPoint
                            dragPoint.x += translation.x
                            #if os(macOS)
                            dragPoint.y -= translation.y
                            #else
                            dragPoint.y += translation.y
                            #endif
                            self.frame.origin = dragPoint
                            if self.movableByBackgroundOptions.boundsToSuperView {
                                let margins = self.movableByBackgroundOptions.margins
                                if self.frame.origin.x < 0 + margins.leading {
                                    self.frame.origin.x = 0 + margins.leading
                                }
                                if self.frame.origin.y < 0 + margins.bottom {
                                    self.frame.origin.y = 0 + margins.bottom
                                }
                                if let superview = self.superview {
                                    if self.frame.origin.x > superview.bounds.width - self.frame.width - margins.trailing {
                                        self.frame.origin.x = superview.bounds.width - self.frame.width - margins.trailing
                                    }
                                    if self.frame.origin.y > superview.bounds.height - self.frame.height - margins.top {
                                        self.frame.origin.y = superview.bounds.height - self.frame.height - margins.top
                                    }
                                }
                            }
                        default:
                            break
                        }
                    }
                    addGestureRecognizer(panGesture!)
                }
            } else {
                if let panGesture = panGesture {
                    removeGestureRecognizer(panGesture)
                    self.panGesture = nil
                }
            }
        }

        private var dragPoint: CGPoint {
            get { getAssociatedValue(key: "dragPoint", object: self, initialValue: .zero) }
            set { set(associatedValue: newValue, key: "dragPoint", object: self) }
        }

        private var panGesture: NSUIPanGestureRecognizer? {
            get { getAssociatedValue(key: "panGesture", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "panGesture", object: self) }
        }
    }

#endif
