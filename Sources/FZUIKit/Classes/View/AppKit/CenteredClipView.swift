//
//  CenteredClipView.swift
//
//
//  Created by Florian Zand on 21.09.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

class DragScrollGestureRecognizer: NSGestureRecognizer {
    var clipView: NSClipView? {
        view as? NSClipView
    }
    
    var isDragScrollablw: Bool {
        (view as? NSClipView)?.isDragScrollable ?? false
    }
    
    var clickPoint: CGPoint = .zero
    var originalOrigin: CGPoint = .zero
    
    override func mouseDown(with event: NSEvent) {
        guard let clipView = clipView, clipView.isDragScrollable else {
            super.mouseDown(with: event)
            return
        }
        
        clickPoint = event.locationInWindow
        originalOrigin = clipView.bounds.origin
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let clipView = clipView, clipView.isDragScrollable else {
            super.mouseDragged(with: event)
            return
        }
        
        let scale = (clipView.superview as? NSScrollView)?.magnification ?? 1.0
        let newPoint = event.locationInWindow

        
        let newOrigin = NSPoint(x: originalOrigin.x + (clickPoint.x - newPoint.x) / scale,
                                y: originalOrigin.y - (clickPoint.y - newPoint.y) / scale)

        let constrainedRect = clipView.constrainBoundsRect(NSRect(origin: newOrigin, size: clipView.bounds.size))
        
        
        clipView.scroll(to: constrainedRect.origin)
        clipView.superview?.reflectScrolledClipView(clipView)
    }
    
    convenience init() {
        self.init(target: nil, action: nil)
    }

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSClipView {
    /// A Boolean value indicating whether users can select scroll the view by mouse drag.
    public var isDragScrollable: Bool {
        get { getAssociatedValue(key: "isDragScrollable", object: self, initialValue: false) }
        set { 
            guard newValue != isDragScrollable else { return }
            set(associatedValue: newValue, key: "isDragScrollable", object: self)
            if newValue {
                dragScrollGestureRecognizer = DragScrollGestureRecognizer()
                addGestureRecognizer(dragScrollGestureRecognizer!)
            } else {
                dragScrollGestureRecognizer?.removeFromView()
                dragScrollGestureRecognizer = nil
            }
        }
    }
    
    var dragScrollGestureRecognizer: DragScrollGestureRecognizer? {
        get { getAssociatedValue(key: "dragScrollGestureRecognizer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "dragScrollGestureRecognizer", object: self)
        }
    }
}

/// A `NSClipView` that is centered.
open class CenteredClipView: NSClipView {
    /// A Boolean value indicating whether the clipview is centered when it's scrollview magnification is smaller than `1.0`.
    open var shouldCenter: Bool = true
    
    /*
    var clickPoint: CGPoint = .zero
    var originalOrigin: CGPoint = .zero
    
    open override func mouseDown(with event: NSEvent) {
        if isDragScrollable {
            clickPoint = event.locationInWindow
            originalOrigin = bounds.origin
        } else {
            super.mouseDown(with: event)
        }
    }
    
    open override func mouseDragged(with event: NSEvent) {
        if isDragScrollable {
            let scale = (superview as? NSScrollView)?.magnification ?? 1.0
            let newPoint = event.locationInWindow
            let newOrigin = CGPoint(x: originalOrigin.x + (clickPoint.x - newPoint.x) / scale,
                                    y: originalOrigin.y - (clickPoint.y - newPoint.y) / scale)
            
            let constrainedRect = constrainBoundsRect(CGRect(newOrigin, bounds.size))
             scroll(to: constrainedRect.origin)
             superview?.reflectScrolledClipView(self)
        } else {
            super.mouseDragged(with: event)
        }
    }
    */
    override open func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)
        if shouldCenter {
            if let containerView = documentView {
                if rect.size.width > containerView.frame.size.width {
                    rect.origin.x = (containerView.frame.width - rect.width) / 2
                }
                
                if rect.size.height > containerView.frame.size.height {
                    rect.origin.y = (containerView.frame.height - rect.height) / 2
                }
            }
        }
        return rect
    }
}
#endif
