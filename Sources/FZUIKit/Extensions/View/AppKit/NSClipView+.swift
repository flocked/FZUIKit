//
//  NSClipView+.swift
//  
//
//  Created by Florian Zand on 14.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSClipView {
    /**
     Changes the origin of the clip view’s bounds rectangle animted to newOrigin.
     
     - Parameters:
     - newOrigin: The point in the view to scroll to.
     - animationDuration: The animation duration of the scolling.
     */
    func scroll(to newOrigin: CGPoint, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                self.animator().setBoundsOrigin(newOrigin)
                self.enclosingScrollView?.reflectScrolledClipView(self)
            }
        } else {
            scroll(to: newOrigin)
        }
    }
    
    /// A Boolean value indicating whether users can scroll the view by dragging the mouse.
    @objc open var isScrollableByDagging: Bool {
        get { dragScrollGestureRecognizer != nil }
        set {
            guard newValue != isScrollableByDagging else { return }
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
        get { getAssociatedValue("dragScrollGestureRecognizer", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "dragScrollGestureRecognizer")
        }
    }
    
    class DragScrollGestureRecognizer: NSGestureRecognizer {
        
        var clipView: NSClipView? { view as? NSClipView }
        var clickPoint: CGPoint = .zero
        var originalOrigin: CGPoint = .zero
        
        override func mouseDown(with event: NSEvent) {
            guard let clipView = clipView, clipView.isScrollableByDagging else {
                super.mouseDown(with: event)
                return
            }
            clickPoint = event.locationInWindow
            originalOrigin = clipView.bounds.origin
        }
        
        override func mouseDragged(with event: NSEvent) {
            guard let clipView = clipView, clipView.isScrollableByDagging else {
                super.mouseDragged(with: event)
                return
            }
            let scale = (clipView.superview as? NSScrollView)?.magnification ?? 1.0
            let newPoint = event.locationInWindow
            let newOrigin = CGPoint(x: originalOrigin.x + (clickPoint.x - newPoint.x) / scale,
                                    y: originalOrigin.y + (clickPoint.y - newPoint.y) / scale)
            clipView.scroll(to: newOrigin)
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
}

extension NSScrollView {
    /// A Boolean value indicating whether users can scroll the view by dragging the mouse.
    @objc open var isScrollableByDagging: Bool {
        get { contentView.isScrollableByDagging }
        set { contentView.isScrollableByDagging = newValue }
    }
}

#endif
