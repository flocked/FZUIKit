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
    var movableByBackground: NSViewBackgroundDragOption {
        get { getAssociatedValue(key: "movableByBackground", object: self, initialValue: .off) }
        set {
            guard newValue != self.movableByBackground else { return }
            set(associatedValue: newValue, key: "movableByBackground", object: self)
            self.setupDragResizeMonitors()
        }
    }
    
    internal func setupDragResizeMonitors() {
        if movableByBackground != .off {
            self.mouseDraggedMonitor = NSEvent.localMonitor(for: [.leftMouseDragged], handler: { event in
                guard let contentView = NSApp.keyWindow?.contentView else { return event }
                let location = event.location(in: self)
                if self.bounds.contains(location), contentView.hitTest(event.location(in: contentView)) == self {
                    self.frame.origin.x    += location.x - self.dragPoint.x
                    self.frame.origin.y    += location.y - self.dragPoint.y
                    
                    if let margins = self.movableByBackground.margins {
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
                }
                return event
            })
            
            self.mouseDownMonitor = NSEvent.localMonitor(for: [.leftMouseDown], handler: { event in
                guard let contentView = NSApp.keyWindow?.contentView else { return event }
                let location = event.location(in: self)
                if self.bounds.contains(location), contentView.hitTest(event.location(in: contentView)) == self {
                    self.dragPoint = location
                }
                return event
            })
        } else {
            self.mouseDownMonitor = nil
            self.mouseDraggedMonitor = nil
        }
    }
    
    private var mouseDraggedMonitor: NSEvent.Monitor? {
        get { getAssociatedValue(key: "leftMouseDraggedMonitor", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "leftMouseDraggedMonitor", object: self) }
    }
    
    private var mouseDownMonitor: NSEvent.Monitor? {
        get { getAssociatedValue(key: "leftMouseDownMonitor", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "leftMouseDownMonitor", object: self) }
    }
    
    private var dragPoint: CGPoint {
        get { getAssociatedValue(key: "dragPoint", object: self, initialValue: .zero) }
        set { set(associatedValue: newValue, key: "dragPoint", object: self) }
    }
}
#endif
