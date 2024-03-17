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
            
            /// The view isn't movable.
            case off
            
            /// The view is movable and bounds to it's superview by the specified margins.
            case boundsToSuperview(margins: NSDirectionalEdgeInsets)
            
            /// The view is movable and bounds to it's superview.
            public static let boundsToSuperview = BackgroundDragOption.boundsToSuperview(margins: .zero)
            
            var margins: NSDirectionalEdgeInsets? {
                switch self {
                case .boundsToSuperview(let margins):
                    return margins
                default: return nil
                }
            }
            public init(booleanLiteral value: Bool) {
                self = value == true ? .on : .off
            }
        }
        
        /// A value that indicates whether the view is movable by clicking and dragging anywhere in its background.
        var isMovableByViewBackground: BackgroundDragOption {
            get { getAssociatedValue("isMovableByViewBackground", initialValue: .off) }
            set {
                guard newValue != isMovableByViewBackground else { return }
                setAssociatedValue(newValue, key: "isMovableByViewBackground")
                setupDragResizeGesture()
            }
        }
        
        /// A handler that provides the velocity of the dragging of the view by it's background when ``isMovableByViewBackground`` is enabled.
        var backgroundDragVelocity: ((_ state: NSUIGestureRecognizer.State, _ velocity: CGPoint) -> Void)? {
            get { getAssociatedValue("movableByBackgroundVelocity", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "movableByBackgroundVelocity") }
        }

        internal func setupDragResizeGesture() {
            if isMovableByViewBackground != .off {
                if panGesture == nil {
                    panGesture = NSUIPanGestureRecognizer { [weak self] gesture in
                        guard let self = self else { return }
                        let velocity = gesture.velocity(in: self)
                        switch gesture.state {
                        case .began:                        
                            backgroundDragVelocity?(.began, velocity)
                            self.dragPoint = self.frame.origin
                        case .ended:
                            backgroundDragVelocity?(.ended, velocity)
                            self.dragPoint = self.frame.origin
                        case .changed:
                            backgroundDragVelocity?(.changed, velocity)
                            let translation = gesture.translation(in: self)
                            var dragPoint = self.dragPoint
                            dragPoint.x += translation.x
                            #if os(macOS)
                            dragPoint.y += translation.y
                            #else
                            dragPoint.y += translation.y
                            #endif
                            self.frame.origin = dragPoint
                            if let margins = isMovableByViewBackground.margins {
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
            get { getAssociatedValue("dragPoint", initialValue: .zero) }
            set { setAssociatedValue(newValue, key: "dragPoint") }
        }

        private var panGesture: NSUIPanGestureRecognizer? {
            get { getAssociatedValue("panGesture", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "panGesture") }
        }
    }

#endif
