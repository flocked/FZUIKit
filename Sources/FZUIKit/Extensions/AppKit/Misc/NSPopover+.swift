//
//  NSPopover+.swift
//
//
//  Created by Florian Zand on 02.11.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import SwiftUI

    extension NSPopover {
        /// Handlers for a popover.
        public struct Handlers {
            /// Handler that gets called whenever the popover is about to show.
            public var willShow: (() -> Void)?
            /// Handler that gets called whenever the popover did show.
            public var didShow: (() -> Void)?
            /// Handler that gets called whenever the popover is about to close.
            public var willClose: (() -> Void)?
            /// Handler that gets called whenever the popover did close.
            public var didClose: (() -> Void)?
            /// Handler that determines whether the popover should close.
            public var shouldClose: (() -> (Bool))?
            /// Handler that gets called whenever the popover did detach.
            public var didDetach: (() -> Void)?
            /// Handler that determines whether the popover should detach.
            public var shouldDetach: (() -> (Bool))?
            /// The handler that gets called when the appearance changes.
            public var effectiveAppearance: ((NSAppearance)->())?
            
            var needsSwizzle: Bool {
                willShow != nil ||
                didShow != nil ||
                willClose != nil ||
                didClose != nil ||
                shouldClose != nil ||
                didDetach != nil ||
                shouldDetach != nil ||
                effectiveAppearance != nil
            }
        }

        /// Handlers for the popover.
        public var handlers: Handlers {
            get { getAssociatedValue("handlers", initialValue: Handlers()) }
            set { 
                setAssociatedValue(newValue, key: "handlers")
                swizzlePopover()
                if newValue.effectiveAppearance != nil {
                    effectiveAppearanceObservation = observeChanges(for: \.effectiveAppearance) { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.handlers.effectiveAppearance?(new)
                    }
                } else {
                    effectiveAppearanceObservation = nil
                }
            }
        }

        /// Creates and returns a popover with the specified content view.
        public convenience init(view: NSView) {
            self.init()
            self.contentView = view
        }
        
        /// Creates and returns a popover with the specified content view controller.
        public convenience init(viewController: NSViewController) {
            self.init()
            self.contentViewController = viewController
        }
        
        /// Sets the behavior of the popover.
        @discardableResult
        @objc open func behavior(_ behavior: Behavior) -> Self {
            self.behavior = behavior
            return self
        }
        
        /// Sets the rectangle within the positioning view relative to which the popover should be positioned.
        @discardableResult
        @objc open func positioningRect(_ positioningRect: CGRect) -> Self {
            self.positioningRect = positioningRect
            return self
        }
        
        /// Sets the view controller that manages the content of the popover.
        @discardableResult
        @objc open func contentViewController(_ viewController: NSViewController?) -> Self {
            self.contentViewController = viewController
            return self
        }
        
        /// A Boolean value that indicates whether the size of the popview is automatically resized to the content view`s size. `
        @objc open var isResizingAutomatically: Bool {
            get { contentViewFrameObservation != nil  }
            set {
                guard newValue != isResizingAutomatically else { return }
                if newValue {
                    contentViewFrameObservation = observeChanges(for: \.contentViewController?.view.frame) { [weak self] old, new in
                        guard let self = self, old?.size != new?.size, let new = new else { return }
                        self.contentSize = new.size
                        self.updatePopover()
                    }
                    contentSize = contentView?.frame.size ?? contentSize
                } else {
                    contentViewFrameObservation = nil
                }
            }
        }
        
        /// Sets the Boolean value that indicates whether the content view is automatically sized to the content view`s size. `
        @discardableResult
        @objc open func isResizingAutomatically(_ autosizes: Bool) -> Self {
            self.isResizingAutomatically = autosizes
            return self
        }
        
        /// Sets the Boolean value that indicates whether the content view of the popover extends into the arrow region.
        @available(macOS 14.0, *)
        @discardableResult
        @objc open func hasFullSizeContent(_ hasFullSizeContent: Bool) -> Self {
            self.hasFullSizeContent = hasFullSizeContent
            return self
        }
                
        /// The content view.
        @objc open var contentView: NSView? {
            get { contentViewController?.view }
            set {
                guard newValue != contentView else { return }
                if let view = newValue {
                    let viewController = NSViewController()
                    viewController.view = view
                    contentViewController = viewController
                    contentSize = view.bounds.size
                } else {
                    contentViewController = nil
                    contentSize = .zero
                }
            }
        }
        
        /// Sets the content view.
        @discardableResult
        @objc open func contentView(_ view: NSView?) -> Self {
            self.contentView = view
            return self
        }

        /// A Boolean value that indicates whether the popover is detachable by the user.
        @objc open var isDetachable: Bool {
            get { getAssociatedValue("isDetachable", initialValue: false) }
            set { setAssociatedValue(newValue, key: "isDetachable")
                swizzlePopover()
            }
        }
        
        /// Sets the Boolean value that indicates whether the popover is detachable by the user.
        @discardableResult
        @objc open func isDetachable(_ isDetachable: Bool) -> Self {
            self.isDetachable = isDetachable
            return self
        }
        
        /// Sets the Boolean value that indicates whether the popover animates.
        @discardableResult
        @objc open func animates(_ animates: Bool) -> Self {
            self.animates = animates
            return self
        }
        
        /// A Boolean value that indicates whether the popover's close button is hidden when detached.
        @objc open var hidesDetachedCloseButton: Bool {
            get { getAssociatedValue("hidesDetachedCloseButton", initialValue: false) }
            set {
                setAssociatedValue(newValue, key: "hidesDetachedCloseButton")
                if isDetached {
                    closeButton?.isHidden = newValue
                }
                swizzlePopover()
            }
        }
        
        /// Sets the Boolean value that indicates whether the popover's close button is hidden when detached.
        @discardableResult
        @objc open func hidesDetachedCloseButton(_ hides: Bool) -> Self {
            self.hidesDetachedCloseButton = hides
            return self
        }

        /// Detaches the popover.
        @objc open func detach() {
            if isDetached == false {
                let detach = NSSelectorFromString("detach")
                if responds(to: detach) {
                    perform(detach)
                }
                closeButton?.isHidden = hidesDetachedCloseButton
            }
        }
        
        /// The view to which the popover should be positioned.
        @objc open var positioningView: NSView? {
            get { value(forKey: "positioningView") as? NSView }
            set { 
                guard newValue != positioningView else { return }
                setValue(newValue, forKey: "positioningView")
                updateVisible()
            }
        }
                
        /// Sets the view to which the popover should be positioned.
        @discardableResult
        @objc open func positioningView(_ view: NSView?) -> Self {
            self.positioningView = view
            return self
        }
        
        /// The edge of `positioningView` the popover should prefer to be anchored to.
        @objc open var preferredEdge: NSRectEdge {
            get { NSRectEdge(rawValue: value(forKey: "_preferredEdge") as? UInt ?? 0)! }
            set { 
                guard newValue != preferredEdge else { return }
                setValue(newValue.rawValue, forKey: "_preferredEdge")
                updateVisible()
            }
        }
        
        /// Sets the edge of `positioningView` the popover should prefer to be anchored to.
        @discardableResult
        @objc open func preferredEdge(_ preferredEdge: NSRectEdge) -> Self {
            self.preferredEdge = preferredEdge
            return self
        }
        
        /// A Boolean value that indicates whether the arrow is visible
        @objc open var isArrowVisible: Bool {
            get { !(value(forKey: "shouldHideAnchor") as? Bool ?? false) }
            set {
                guard newValue != isArrowVisible else { return }
                setValue(!newValue, forKey: "shouldHideAnchor")
                updateVisible()
            }
        }
        
        /// Sets the Boolean value that indicates whether the arrow is visible
        @discardableResult
        @objc open func isArrowVisible(_ isVisible: Bool) -> Self {
            self.isArrowVisible = isVisible
            return self
        }
        
        /// The window of the popover.
        @objc open var window: NSWindow? {
            value(forKey: "_popoverWindow") as? NSWindow
        }
        
        func updateVisible() {
            guard isShown, !isDetached, let positioningView = positioningView else { return }
            show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, hideArrow: viewTrackingOptions?.hidesArrow ?? false, tracksView: viewTrackingOptions != nil)
        }
        
        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningView: The view relative to which the popover should be positioned.
            - preferredEdge: The edge of `positioningView` the popover should prefer to be anchored to.
            - hideArrow: A Boolean value that indicates whether to hide the arrow of the popover.
            - tracksView: A Boolean value that indicates whether to track the `positioningView`. If set to `true`, the popover is automatially positioned to the view's frame and automatically hides, if the view hides.
         */
        public func show(_ positioningView: NSView, preferredEdge: NSRectEdge, hideArrow: Bool = false, tracksView: Bool = false) {
            show(relativeTo: .zero, of: positioningView, preferredEdge: preferredEdge, hideArrow: hideArrow, tracksView: tracksView)
        }
        
        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningRect: The rectangle within `positioningView` relative to which the popover should be positioned, or `nil` to set it to the bounds of the `positioningView`.
            - positioningView: The view relative to which the popover should be positioned.
            - preferredEdge: The edge of `positioningView` the popover should prefer to be anchored to.
            - tracksView: A Boolean value that indicates whether to track the `positioningView`. If set to `true`, the popover is automatially positioned to the view's frame and automatically hides, if the view hides.
         */
        public func show(relativeTo positioningRect: CGRect, of positioningView: NSView, preferredEdge: NSRectEdge, hideArrow: Bool) {
            self.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, hideArrow: hideArrow, tracksView: false)
        }
        
        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningRect: The rectangle within `positioningView` relative to which the popover should be positioned, or `nil` to set it to the bounds of the `positioningView`.
            - positioningView: The view relative to which the popover should be positioned.
            - preferredEdge: The edge of `positioningView` the popover should prefer to be anchored to.
            - tracksView: A Boolean value that indicates whether to track the `positioningView`. If set to `true`, the popover is automatially positioned to the view's frame and automatically hides, if the view hides.
         */
        public func show(relativeTo positioningRect: CGRect, of positioningView: NSView, preferredEdge: NSRectEdge, tracksView: Bool) {
            self.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, hideArrow: false, tracksView: tracksView)
        }

        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningRect: The rectangle within `positioningView` relative to which the popover should be positioned, or `nil` to set it to the bounds of the `positioningView`.
            - positioningView: The view relative to which the popover should be positioned.
            - preferredEdge: The edge of `positioningView` the popover should prefer to be anchored to.
            - hideArrow: A Boolean value that indicates whether to hide the arrow of the popover.
            - tracksView: A Boolean value that indicates whether to track the `positioningView`. If set to `true`, the popover is automatially positioned to the view's frame and automatically hides, if the view hides.
         */
        public func show(relativeTo positioningRect: CGRect, of positioningView: NSView, preferredEdge: NSRectEdge, hideArrow: Bool, tracksView: Bool) {
            let spacing: CGFloat = 0.0
            let tracking: ViewTracking = .disabled
            dismiss()
            if hideArrow == false {
                show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
            } else {
                let noArrowView = NSView(frame: positioningView.frame)
                let edge = edge(for: positioningView, preferredEdge: preferredEdge, spacing: spacing)
                switch edge {
                case .minX:
                    noArrowView.frame.origin.x += 10 - spacing
                case .maxX:
                    noArrowView.frame.origin.x -= 10 - spacing
                case .minY:
                    noArrowView.frame.origin.y += 10 - spacing
                case .maxY:
                    noArrowView.frame.origin.y -= 10 - spacing
                default: break
                }
                self.noArrowView = noArrowView
                positioningView.superview?.addSubview(noArrowView, positioned: .below, relativeTo: positioningView)
                show(relativeTo: positioningRect, of: noArrowView, preferredEdge: preferredEdge)
                noArrowView.frame = NSRect(x: 0, y: -200, width: 10, height: 10)
            }
            willCloseObservation = NotificationCenter.default.observe(NSPopover.willCloseNotification, object: self, using: { [weak self] notification in
                guard let self = self, !self.isClosing else { return }
                self.dismiss()
            })
            if tracksView {
                viewTrackingOptions = ViewTrackingOptions(rect: positioningRect, view: positioningView, preferredEdge: preferredEdge, hidesArrow: hideArrow, tracking: tracking)
                if tracking == .ifFirstResponder {
                    positionObservations.append(positioningView.observeChanges(for: \.window?.firstResponder) { old, new in
                        guard old != new, positioningView.isFirstResponder else { return }
                        self.updateVisibility()
                    }!)
                }
                positionObservations.append(positioningView.observeChanges(for: \.isHidden) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.updateVisibility()
                    }!)
                positionObservations.append(positioningView.observeChanges(for: \.frame) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.updatePopover()
                    }!)
                positionObservations.append(positioningView.observeChanges(for: \.window?.frame) { [weak self] old, new in
                    guard let self = self, old != new, new != nil else { return }
                    self.updatePopover()
                    }!)
            }
        }
                
        private func edge(for view: NSView, preferredEdge: NSRectEdge, spacing: CGFloat = 0.0, centered: Bool = false) -> NSRectEdge {
            guard let contentView = contentView, let screen = view.window?.screen, let frameOnScreen = view.frameOnScreen else { return preferredEdge }
            var edgeFrames: [NSRectEdge: CGRect] = [:]
            edgeFrames[.minX] = CGRect(CGPoint(x: frameOnScreen.x - contentView.frame.width - spacing,
                                               y: frameOnScreen.y + (view.frame.height / 2.0) - (contentView.frame.height / 2.0)), contentView.frame.size)
            edgeFrames[.maxX] = CGRect(CGPoint(x: frameOnScreen.x + view.frame.width + spacing,
                                               y: frameOnScreen.y + (view.frame.height / 2.0) - (contentView.frame.height / 2.0)), contentView.frame.size)
            edgeFrames[.minY] = CGRect(CGPoint(x: centered ? frameOnScreen.x - (view.frame.width/2.0) - (contentView.frame.width / 2.0) : frameOnScreen.x,
                                               y: frameOnScreen.y - contentView.frame.height), contentView.frame.size - spacing)
            edgeFrames[.maxY] = CGRect(CGPoint(x: centered ? frameOnScreen.x - (view.frame.width/2.0) - (contentView.frame.width / 2.0) : frameOnScreen.x,
                                               y: frameOnScreen.y + view.frame.height), contentView.frame.size + spacing)
            var edges: [NSRectEdge] = []
            switch preferredEdge {
            case .minX: edges = [.minX, .maxX, .minY, .maxY]
            case .maxX: edges = [.maxX, .minX, .minY, .maxY]
            case .minY: edges = [.minY, .maxY, .minX, .maxX]
            case .maxY: edges = [.maxY, .minY, .minX, .maxX]
            default: edges = [.minY, .maxY, .minX, .maxX]
            }
            let visibleFrame = screen.visibleFrame
            return edges.first(where: {
                switch $0 {
                case .minY: return visibleFrame.yValue(visibleFrame.y + 16).contains(edgeFrames[$0]!)
                case .maxY: return visibleFrame.yValue(visibleFrame.y - 16).contains(edgeFrames[$0]!)
                default: return  visibleFrame.contains(edgeFrames[$0]!)
                }
            }) ?? preferredEdge
        }
        
        private func updateVisibility() {
            guard let track = viewTrackingOptions else { return }
            if track.view.isHidden || track.tracking == .ifFirstResponder && !track.view.isFirstResponder, isShown, !isDetached {
                isClosing = true
                close()
                isClosing = false
            } else if !track.view.isHidden, !isShown, track.tracking != .ifFirstResponder  || track.tracking == .ifFirstResponder && track.view.isFirstResponder {
                show(relativeTo: track.rect, of: track.view, preferredEdge: track.preferredEdge, hideArrow: track.hidesArrow, tracksView: true)
            }
        }
        
        private func updatePopover() {
            guard isShown, !isDetached, let track = viewTrackingOptions else { return }
            self.animates = false
            show(relativeTo: track.rect, of: track.view, preferredEdge: track.preferredEdge, hideArrow: track.hidesArrow, tracksView: true)
            // self.animates = animates
        }
        
        private func dismiss() {
            noArrowView?.removeFromSuperview()
            noArrowView = nil
            positionObservations = []
            viewTrackingOptions = nil
            willCloseObservation = nil
        }

        private var closeButton: NSButton? {
            contentViewController?.view.superview?.subviews.last as? NSButton
        }
        
        /// Options for tracking a positioning view.
        enum ViewTracking: Int, Hashable {
            /// Doesn't track the positioning view.
            case disabled
            /// Tracks the positioning view.
            case enabled
            /// Tracks the positioning view, if it's the first responder.
            case ifFirstResponder
        }
        
        private struct ViewTrackingOptions {
            let rect: CGRect
            let view: NSView
            let preferredEdge: NSRectEdge
            let hidesArrow: Bool
            var tracking: ViewTracking
        }
        
        private var viewTrackingOptions: ViewTrackingOptions? {
            get { getAssociatedValue("viewTrackingOptions") }
            set { setAssociatedValue(newValue, key: "viewTrackingOptions") }
        }

        private var willCloseObservation: NotificationToken? {
            get { getAssociatedValue("willCloseObservation") }
            set { setAssociatedValue(newValue, key: "willCloseObservation") }
        }
        
        private var didShowObservation: NotificationToken? {
            get { getAssociatedValue("didShowObservation") }
            set { setAssociatedValue(newValue, key: "didShowObservation") }
        }

        private var noArrowView: NSView? {
            get { getAssociatedValue("noArrowView") }
            set { setAssociatedValue(newValue, key: "noArrowView") }
        }
        
        private var isClosing: Bool {
            get { getAssociatedValue("isClosing", initialValue: false) }
            set { setAssociatedValue(newValue, key: "isClosing") }
        }
        
        private var effectiveAppearanceObservation: KeyValueObservation? {
            get { getAssociatedValue("effectiveAppearanceObservation") }
            set { setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
        }
        
        private var contentViewFrameObservation: KeyValueObservation? {
            get { getAssociatedValue("contentViewFrameObservation") }
            set { setAssociatedValue(newValue, key: "contentViewFrameObservation") }
        }
        
        private var positionObservations: [KeyValueObservation] {
            get { getAssociatedValue("positionObservations", initialValue: []) }
            set { setAssociatedValue(newValue, key: "positionObservations") }
        }

        private var popoverDelegate: Delegate? {
            get { getAssociatedValue("popoverDelegate") }
            set { setAssociatedValue(newValue, key: "popoverDelegate") }
        }

        private func swizzlePopover() {
            if handlers.needsSwizzle || hidesDetachedCloseButton || isDetachable {
                guard popoverDelegate == nil else { return }
                popoverDelegate = Delegate(popover: self)
                do {
                    try replaceMethod(
                        #selector(getter: delegate),
                        methodSignature: (@convention(c) (AnyObject, Selector) -> (NSPopoverDelegate?)).self,
                        hookSignature: (@convention(block) (AnyObject) -> (NSPopoverDelegate?)).self
                    ) { _ in { object in
                        (object as? NSPopover)?.popoverDelegate?.delegate
                    }
                    }
                    
                    try replaceMethod(
                        #selector(setter: delegate),
                        methodSignature: (@convention(c) (AnyObject, Selector, NSPopoverDelegate?) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject, NSPopoverDelegate?) -> Void).self
                    ) { _ in { object, delegate in
                        (object as? NSPopover)?.popoverDelegate?.delegate = delegate
                    }
                    }
                } catch {
                    Swift.debugPrint()
                }
            } else if popoverDelegate != nil {
                resetMethod(#selector(getter: delegate))
                resetMethod(#selector(setter: delegate))
                delegate = popoverDelegate?.delegate
                popoverDelegate = nil
            }
        }

        private class Delegate: NSObject, NSPopoverDelegate {
            weak var popover: NSPopover!
            weak var delegate: NSPopoverDelegate?
            var delegateObservation: KeyValueObservation?
            
            init(popover: NSPopover!) {
                self.delegate = popover.delegate
                self.popover = popover
                super.init()
                popover.delegate = self
                delegateObservation = popover.observeChanges(for: \.delegate) { [weak self] old, new in
                    guard let self = self, (new as? NSObject) != self else { return }
                    self.delegate = new
                    self.popover?.delegate = self
                }
            }

            func popoverWillShow(_ notification: Notification) {
                delegate?.popoverWillShow?(notification)
                popover?.handlers.willShow?()
            }

            func popoverDidShow(_ notification: Notification) {
                delegate?.popoverDidShow?(notification)
                popover?.handlers.didShow?()
            }

            func popoverDidClose(_ notification: Notification) {
                delegate?.popoverDidClose?(notification)
                popover?.handlers.didClose?()
            }

            func popoverWillClose(_ notification: Notification) {
                delegate?.popoverWillClose?(notification)
                popover?.handlers.willClose?()
            }

            func popoverShouldClose(_ popover: NSPopover) -> Bool {
                popover.handlers.shouldClose?() ?? delegate?.popoverShouldClose?(popover) ?? true
            }

            func popoverShouldDetach(_ popover: NSPopover) -> Bool {
                popover.handlers.shouldDetach?() ?? delegate?.popoverShouldDetach?(popover) ?? popover.isDetachable
            }

            func popoverDidDetach(_ popover: NSPopover) {
                delegate?.popoverDidDetach?(popover)
                popover.handlers.didDetach?()
                if popover == self.popover {
                    self.popover.closeButton?.isHidden = self.popover.hidesDetachedCloseButton
                }
            }
        }
    }

extension NSPopover.ViewTracking: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = value ? .enabled : .disabled
    }
}
#endif
