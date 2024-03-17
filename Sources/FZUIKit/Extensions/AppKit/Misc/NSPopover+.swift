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

            var needsSwizzle: Bool {
                willShow != nil ||
                    didShow != nil ||
                    willClose != nil ||
                    didClose != nil ||
                    shouldClose != nil ||
                    didDetach != nil ||
                    shouldDetach != nil
            }
        }

        /// Handlers for the popover.
        public var handlers: Handlers {
            get { getAssociatedValue("handlers", initialValue: Handlers()) }
            set { setAssociatedValue(newValue, key: "handlers")
                if newValue.needsSwizzle {
                    swizzlePopover()
                }
            }
        }

        /// Creates and returns a popover with the specified view.
        public convenience init(view: NSView) {
            self.init()
            let viewController = NSViewController()
            viewController.view = view
            contentViewController = viewController
            contentSize = view.bounds.size
        }

        /// A Boolean value that indicates whether the popover is detachable by the user.
        public var isDetachable: Bool {
            get { getAssociatedValue("isDetachable", initialValue: false) }
            set { setAssociatedValue(newValue, key: "isDetachable")
                if newValue == true {
                    swizzlePopover()
                }
            }
        }
        
        /// A Boolean value that indicates whether the popover's close button is hidden when deteched.
        public var hideDetachedCloseButton: Bool {
            get { getAssociatedValue("hideDetachedCloseButton", initialValue: false) }
            set { setAssociatedValue(newValue, key: "hideDetachedCloseButton")
                if isDetached {
                    closeButton?.isHidden = newValue
                }
                if newValue == true {
                    swizzlePopover()
                }
            }
        }

        /// Detaches the popover.
        public func detach() {
            if isDetached == false {
                let detach = NSSelectorFromString("detach")
                if responds(to: detach) {
                    perform(detach)
                }
                closeButton?.isHidden = hideDetachedCloseButton
            }
        }

        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningRect: The rectangle within `positioningView` relative to which the popover should be positioned. Normally set to the bounds of `positioningView`. May be an empty rectangle, which will default to the bounds of positioningView.
            - positioningView: The view relative to which the popover should be positioned. Causes the method to raise `invalidArgumentException if `nil`.
            - preferredEdge: The edge of positioningView the popover should prefer to be anchored to.
            - trackViewFrame: A Boolean value that indicates whether to automatically reposition the popover when the positioning view's frame changes.
         */
        public func show(relativeTo positioningRect: CGRect, of positioningView: NSView, preferredEdge: NSRectEdge, trackViewFrame: Bool) {
            show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge, hideArrow: false, trackViewFrame: trackViewFrame)
        }

        /**
         Shows the popover anchored to the specified view.

         - Parameters:
            - positioningRect: The rectangle within `positioningView` relative to which the popover should be positioned. Normally set to the bounds of `positioningView`. May be an empty rectangle, which will default to the bounds of `positioningView`.
            - positioningView: The view relative to which the popover should be positioned. Causes the method to raise `invalidArgumentException` if `nil`.
            - preferredEdge: The edge of positioningView the popover should prefer to be anchored to.
            - hideArrow: A Boolean value that indicates whether to hide the arrow of the popover.
            - trackViewFrame: A Boolean value that indicates whether to automatically reposition the popover when the positioning view's frame changes.
         */
        public func show(relativeTo positioningRect: CGRect, of positioningView: NSView, preferredEdge: NSRectEdge, hideArrow: Bool, trackViewFrame: Bool = true) {
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

        private var popoverProxy: DelegateProxy? {
            get { getAssociatedValue("popoverProxy", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "popoverProxy") }
        }

        func swizzlePopover() {
            if handlers.needsSwizzle || hideDetachedCloseButton {
                guard popoverProxy == nil else { return }
                popoverProxy = DelegateProxy(delegate: delegate, popover: self)
                delegate = popoverProxy
                do {
                    try replaceMethod(
                        #selector(getter: delegate),
                        methodSignature: (@convention(c) (AnyObject, Selector) -> (NSPopoverDelegate?)).self,
                        hookSignature: (@convention(block) (AnyObject) -> (NSPopoverDelegate?)).self
                    ) { _ in { object in
                        (object as? NSPopover)?.popoverProxy?.delegate
                    }
                    }
                    
                    try replaceMethod(
                        #selector(setter: delegate),
                        methodSignature: (@convention(c) (AnyObject, Selector, NSPopoverDelegate?) -> Void).self,
                        hookSignature: (@convention(block) (AnyObject, NSPopoverDelegate?) -> Void).self
                    ) { _ in { object, delegate in
                        (object as? NSPopover)?.popoverProxy?.delegate = delegate
                    }
                    }
                } catch {
                    Swift.debugPrint()
                }
            } else {
                resetMethod(#selector(getter: delegate))
                resetMethod(#selector(setter: delegate))
                popoverProxy = nil
            }
        }

        private class DelegateProxy: NSObject, NSPopoverDelegate {
            weak var delegate: NSPopoverDelegate?
            weak var popover: NSPopover!
            init(delegate: NSPopoverDelegate? = nil, popover: NSPopover!) {
                self.delegate = delegate
                self.popover = popover
            }

            func popoverWillShow(_ notification: Notification) {
                delegate?.popoverWillShow?(notification)
                popover.handlers.willShow?()
            }

            func popoverDidShow(_ notification: Notification) {
                delegate?.popoverDidShow?(notification)
                popover.handlers.didShow?()
            }

            func popoverDidClose(_ notification: Notification) {
                delegate?.popoverDidClose?(notification)
                popover.handlers.didClose?()
            }

            func popoverWillClose(_ notification: Notification) {
                delegate?.popoverWillClose?(notification)
                popover.handlers.willClose?()
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
                    self.popover.closeButton?.isHidden = self.popover.hideDetachedCloseButton
                }
            }
        }
    }
#endif
