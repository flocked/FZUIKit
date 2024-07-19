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
        
        /// A Boolean value that indicates whether the content view is automatically sized to the content view`s size. `
        @objc open var autosizesContentView: Bool {
            get { contentViewControllerObservation != nil  }
            set {
                guard newValue != autosizesContentView else { return }
                if newValue {
                    func setupFrameObservation() {
                        contentViewFrameObservation = contentView?.observeChanges(for: \.frame) { [weak self] old, new in
                            guard let self = self, old.size != new.size else { return }
                             self.contentSize = new.size
                        }
                        contentSize = contentView?.frame.size ?? contentSize
                    }
                    contentViewControllerObservation = observeChanges(for: \.contentViewController) { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        setupFrameObservation()
                    }
                    setupFrameObservation()
                } else {
                    contentViewFrameObservation = nil
                    contentViewControllerObservation = nil
                }
            }
        }
        
        /// Sets the Boolean value that indicates whether the content view is automatically sized to the content view`s size. `
        @discardableResult
        @objc open func autosizesContentView(_ autosizes: Bool) -> Self {
            self.autosizesContentView = autosizes
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
        
        /// A Boolean value that indicates whether the popover's close button is hidden when deteched.
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
        
        /// Sets the Boolean value that indicates whether the popover's close button is hidden when deteched.
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

        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningRect: The rectangle within `positioningView` relative to which the popover should be positioned, or `nil` to set it to the bounds of the `positioningView`.
            - positioningView: The view relative to which the popover should be positioned. Causes the method to raise `invalidArgumentException if `nil`.
            - preferredEdge: The edge of positioningView the popover should prefer to be anchored to.
            - tracksViewFrame: A Boolean value that indicates whether to automatically reposition the popover when the positioning view's frame changes.
         */
        public func show(relativeTo positioningRect: CGRect? = nil, of positioningView: NSView, preferredEdge: NSRectEdge, tracksViewFrame: Bool) {
            show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, hideArrow: false, tracksViewFrame: tracksViewFrame)
        }

        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningRect: The rectangle within `positioningView` relative to which the popover should be positioned, or `nil` to set it to the bounds of the `positioningView`.
            - positioningView: The view relative to which the popover should be positioned. Causes the method to raise `invalidArgumentException` if `nil`.
            - preferredEdge: The edge of positioningView the popover should prefer to be anchored to.
            - hideArrow: A Boolean value that indicates whether to hide the arrow of the popover.
            - tracksViewFrame: A Boolean value that indicates whether to automatically reposition the popover when the positioning view's frame changes.
         */
        public func show(relativeTo positioningRect: CGRect? = nil, of positioningView: NSView, preferredEdge: NSRectEdge, hideArrow: Bool, tracksViewFrame: Bool = true) {
            let positioningRect = positioningRect ?? positioningView.bounds
            isOpeningPopover = true
            dismissNoArrow()
            if hideArrow == false {
                show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
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
                positioningView.superview?.addSubview(noArrowView, positioned: .below, relativeTo: positioningView)
                show(relativeTo: positioningRect, of: noArrowView, preferredEdge: preferredEdge)
                noArrowView.frame = NSRect(x: 0, y: -200, width: 10, height: 10)
                willCloseObserver = NotificationCenter.default.observe(NSPopover.willCloseNotification, object: self, using: { notification in
                    (notification.object as? NSPopover)?.dismissNoArrow()
                })
            }
            if tracksViewFrame {
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
        
        private var effectiveAppearanceObservation: KeyValueObservation? {
            get { getAssociatedValue("effectiveAppearanceObservation", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "effectiveAppearanceObservation") }
        }
        
        private var contentViewFrameObservation: KeyValueObservation? {
            get { getAssociatedValue("contentViewFrameObservation", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "contentViewFrameObservation") }
        }
        
        private var contentViewControllerObservation: KeyValueObservation? {
            get { getAssociatedValue("contentViewControllerObservation", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "contentViewControllerObservation") }
        }

        private func dismissNoArrow() {
            noArrowView?.removeFromSuperview()
            noArrowView = nil
            willCloseObserver = nil
        }

        private var closeButton: NSButton? {
            contentViewController?.view.superview?.subviews.last as? NSButton
        }

        private var willCloseObserver: NotificationToken? {
            get { getAssociatedValue("willClosePopoverObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "willClosePopoverObserver") }
        }

        private var noArrowView: NSView? {
            get { getAssociatedValue("noArrowView", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "noArrowView") }
        }

        private var positioningViewFrameObserver: KeyValueObservation? {
            get { getAssociatedValue("positioningFrameObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "positioningFrameObserver") }
        }

        private var isOpeningPopover: Bool {
            get { getAssociatedValue("isOpeningPopover", initialValue: true) }
            set { setAssociatedValue(newValue, key: "isOpeningPopover") }
        }

        private var popoverDelegate: Delegate? {
            get { getAssociatedValue("popoverProxy", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "popoverProxy") }
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
#endif
