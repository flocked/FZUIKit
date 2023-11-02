//
//  NSPopover+.swift
//
//
//  Created by Florian Zand on 02.11.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSPopover {
    /// Creates and returns a popover with the specified view.
    public convenience init(view: NSView) {
        self.init()
        let viewController = NSViewController()
        viewController.view = view
        self.contentViewController = viewController
        self.contentSize = view.bounds.size
    }
    
    /// Detaches the popover and optionally hides the close button.
    public func detach(hideCloseButton: Bool = false) {
        if self.isDetached == false {
            let detach = NSSelectorFromString("detach")
            if self.responds(to: detach) {
                self.perform(detach)
            }
        }
        closeButton?.isHidden = hideCloseButton
    }
    
    /**
     Shows the popover anchored to the specified view.
     
     - Parameters:
        - positioningRect: The rectangle within positioningView relative to which the popover should be positioned. Normally set to the bounds of positioningView. May be an empty rectangle, which will default to the bounds of positioningView.
        - positioningView: The view relative to which the popover should be positioned. Causes the method to raise invalidArgumentException if nil.
        - preferredEdge: The edge of positioningView the popover should prefer to be anchored to.
        - trackViewFrame: A Boolean value that indicates whether to automatically reposition the popover when the view frame changes.
     */
    public func show(relativeTo positioningRect: CGRect, of positioningView: NSView, preferredEdge: NSRectEdge, trackViewFrame: Bool) {
        self.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, hideArrow: false, trackViewFrame: trackViewFrame)
    }
    
    /**
     Shows the popover anchored to the specified view.
     
     - Parameters:
        - positioningRect: The rectangle within positioningView relative to which the popover should be positioned. Normally set to the bounds of positioningView. May be an empty rectangle, which will default to the bounds of positioningView.
        - positioningView: The view relative to which the popover should be positioned. Causes the method to raise invalidArgumentException if nil.
        - preferredEdge: The edge of positioningView the popover should prefer to be anchored to.
        - hideArrow: A Boolean value that indicates whether to hide the arrow of the popover.
        - trackViewFrame: A Boolean value that indicates whether to automatically reposition the popover when the view frame changes.
     */
    public func show(relativeTo positioningRect: CGRect, of positioningView: NSView, preferredEdge: NSRectEdge, hideArrow: Bool, trackViewFrame: Bool = true) {
        isOpeningPopover = true
        self.dismissNoArrow()
        if hideArrow == false {
            self.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
        } else {
            let noArrowView = NSView(frame: positioningView.frame)
            switch preferredEdge {
            case .minX:
                noArrowView.frame.origin.x += 10
            case .maxX:
                noArrowView.frame.origin.x -= 10
            case .minY:
                noArrowView.frame.origin.y += 10
            case .maxY:
                noArrowView.frame.origin.y -= 10
            default: break
            }
            self.noArrowView = noArrowView
            positioningView.superview?.addSubview(noArrowView, positioned: .below,relativeTo: positioningView)
            self.show(relativeTo: positioningRect, of: noArrowView, preferredEdge: preferredEdge)
            noArrowView.frame =  NSMakeRect(0, -200, 10, 10)
            willCloseObserver = NotificationCenter.default.observe(name: NSPopover.willCloseNotification, object: self, using: { notification in
                (notification.object as? NSPopover)?.dismissNoArrow()
            })
        }
        if trackViewFrame {
            positioningViewFrameObserver = positioningView.observeChanges(for: \.frame, handler: { [weak self] old, new in
                guard let self = self, old != new else { return }
                if self.isOpeningPopover == false, self.isDetached == false, self.isShown == true {
                    let animates = self.animates
                    self.animates = false
                    self.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, hideArrow: hideArrow)
                    self.animates = animates
                }
            })
        }
        isOpeningPopover = false
    }
    
    private func dismissNoArrow() {
        self.noArrowView?.removeFromSuperview()
        self.noArrowView = nil
        self.willCloseObserver = nil
    }
    
    private var closeButton: NSButton? {
        self.contentViewController?.view.superview?.subviews.last as? NSButton
    }
    
    private var willCloseObserver: NotificationToken? {
        get { getAssociatedValue(key: "willClosePopoverObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "willClosePopoverObserver", object: self) }
    }
    
    private var noArrowView: NSView? {
        get { getAssociatedValue(key: "noArrowView", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "noArrowView", object: self) }
    }
    
    private var positioningViewFrameObserver: NSKeyValueObservation?  {
        get { getAssociatedValue(key: "positioningFrameObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "positioningFrameObserver", object: self) }
    }
    
    private var isOpeningPopover: Bool  {
        get { getAssociatedValue(key: "isOpeningPopover", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "isOpeningPopover", object: self) }
    }
}
#endif
