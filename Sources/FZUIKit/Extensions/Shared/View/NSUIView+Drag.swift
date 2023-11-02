//
//  NSView+Drag.swift
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
    enum BackgroundDragOption: Hashable {
        /// The view is movable and bounds to the superview with the specified insets.
        case boundsToSuperview(NSDirectionalEdgeInsets)
        /// The view is movable.
        case on
        /// The view isn't movable.
        case off
        
        /// The view is movable and bounds to the superview.
        public static var boundsToSuperview = BackgroundDragOption.boundsToSuperview(.zero)
        
        internal var margins: NSDirectionalEdgeInsets? {
            switch self {
                case .boundsToSuperview(let margins): return margins
                default: return nil
            }
        }
    }
    
    /// A value that indicates whether the view is movable by clicking and dragging anywhere in its background.
    var isMovableByViewBackground: BackgroundDragOption {
        get { getAssociatedValue(key: "isMovableByViewBackground", object: self, initialValue: .off) }
        set {
            guard newValue != self.isMovableByViewBackground else { return }
            set(associatedValue: newValue, key: "isMovableByViewBackground", object: self)
            self.setupDragResizeGesture()
        }
    }
    
    /// A handler that provides the moved velocity when the view ``isMovableByViewBackground``.
    var movableViewVelocity: ((CGPoint)->())? {
        get { getAssociatedValue(key: "movableViewVelocity", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "movableViewVelocity", object: self) }
    }
    
    internal func setupDragResizeGesture() {
        if isMovableByViewBackground != .off {
            if panGesture == nil {
                panGesture = NSUIPanGestureRecognizer() { [weak self] gesture in
                    guard let self = self else { return }
                    switch gesture.state {
                    case .began:
                        self.dragPoint = self.frame.origin
                    case .ended:
                        self.dragPoint = self.frame.origin
                        let velocity = gesture.velocity(in: self)
                        self.movableViewVelocity?(velocity)
                    case .changed:
                        let translation = gesture.translation(in: self)
                        self.frame.origin = self.dragPoint.offset(by: translation)
                        if let margins = self.isMovableByViewBackground.margins {
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
                self.addGestureRecognizer(panGesture!)
            }
        } else {
            if let panGesture = self.panGesture {
                self.removeGestureRecognizer(panGesture)
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
