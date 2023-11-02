//
//  NSView+Drag.swift
//  Tester
//
//  Created by Florian Zand on 21.09.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A value that indicates whether a view is movable by clicking and dragging anywhere in its background.
public enum NSViewBackgroundDragOption: Hashable {
    /// The view is movable and bounds to the superview.
    case boundsToSuperview(NSDirectionalEdgeInsets = .zero)
    /// The view is movable.
    case on
    /// The view isn't movable.
    case off
    
    internal var margins: NSDirectionalEdgeInsets? {
        switch self {
            case .boundsToSuperview(let margins): return margins
            default: return nil
        }
    }
}

public extension NSView {
    /// A value that indicates whether the view is movable by clicking and dragging anywhere in its background.
    var movableByViewBackground: NSViewBackgroundDragOption {
        get { getAssociatedValue(key: "movableByViewBackground", object: self, initialValue: .off) }
        set {
            guard newValue != self.movableByViewBackground else { return }
            set(associatedValue: newValue, key: "movableByViewBackground", object: self)
            self.setupDragResizeGesture()
        }
    }
    
    internal func setupDragResizeGesture() {
        if movableByViewBackground != .off {
            if panGesture == nil {
                panGesture = NSPanGestureRecognizer() { gesture in
                    switch gesture.state {
                    case .began, .ended:
                        self.dragPoint = self.frame.origin
                    case .changed:
                        let translation = gesture.translation(in: self)
                        self.frame.origin = self.dragPoint.offset(by: translation)
                        if let margins = self.movableByViewBackground.margins {
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
    
    private var panGesture: NSPanGestureRecognizer? {
        get { getAssociatedValue(key: "panGesture", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "panGesture", object: self) }
    }
}
#endif
