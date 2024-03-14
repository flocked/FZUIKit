//
//  NSScrollView+.swift
//
//
//  Created by Florian Zand on 22.05.22.
//

#if os(macOS)

    import AppKit
    import Foundation
    import FZSwiftUtils

    public extension NSScrollView {
        /// Scrolls the scroll view to the top.
        func scrollToTop() {
            contentOffset.y = contentSize.height
        }

        /// Scrolls the scroll view to the bottom.
        func scrollToBottom() {
            contentOffset.y = 0.0
        }
        
        /// Scrolls the scroll view to the left.
        func scrollToLeft() {
            contentOffset.x = 0.0
        }
        
        /// Scrolls the scroll view to the right.
        func scrollToRight() {
            contentOffset.x = contentSize.width
        }
        
        /**
         The point at which the origin of the document view is offset from the origin of the scroll view.

         The value can be animated via `animator()`.
         */
        @objc var contentOffset: CGPoint {
            get { documentVisibleRect.origin }
            set {
                NSView.swizzleAnimationForKey()
                documentView?.scroll(newValue)
            }
        }
        
        /**
         The point at which the origin of the document view is offset from the origin of the scroll view.
         
         - A value of `CGPoint(x:0, y:0)` indicates the document view is at the bottom left.
         - A value of `CGPoint(x:1, y:1)` indicates the document view is at the top right.

         The value can be animated via `animator()`.
         */
        var contentPoint: CGPoint {
            get {
                guard let maxOffset = maxContentOffset else { return .zero }
                return CGPoint(contentOffset.x / maxOffset.x, contentOffset.y / maxOffset.y)
            }
            set {
                guard let maxOffset = maxContentOffset else { return }
                NSView.swizzleAnimationForKey()
                contentOffset = CGPoint(newValue.x.clamped(max: 1.0) * maxOffset.x, newValue.y.clamped(max: 1.0) * maxOffset.y)
            }
        }
        
        var maxContentOffset: CGPoint? {
            guard let documentView = documentView else { return nil }
            let maxY = documentView.frame.maxY - contentView.bounds.height
            let maxX = documentView.frame.maxX - contentView.bounds.width
            return CGPoint(maxX, maxY)
        }

        /**
         The size of the document view, or `zero` if there isn't a document view.

         The value can be animated via `animator()`.
         */
        @objc var visibleDocumentSize: CGSize {
            get { documentVisibleRect.size }
            set {
                guard newValue != documentSize else { return }
                NSView.swizzleAnimationForKey()
                zoom(toSize: newValue)
            }
        }
        
        /**
         The size of the document view, or `zero` if there isn't a document view.

         The value can be animated via `animator()`.
         */
        @objc var documentSize: CGSize {
            get { (documentView?.bounds.size ?? .zero) * magnification }
            set {
                guard newValue != documentSize else { return }
                NSView.swizzleAnimationForKey()
                let documentSize = (documentView?.bounds.size ?? .zero)
                magnification = max(newValue.width/documentSize.width, newValue.height/documentSize.height)
            }
        }
        
        internal func zoom(toSize size: CGSize) {
            magnification = max(contentSize.width/size.width, contentSize.height/size.height)
        }

        /**
         Magnify the content by the given amount and optionally center the result on the given point.

         - Parameters:
            - magnification: The amount by which to magnify the content.
            - point: The point (in content view space) on which to center magnification, or `nil` if the magnification shouldn't be centered.
            - animationDuration: The animation duration of the magnification, or `nil` if the magnification shouldn't be animated.
         */
        func setMagnification(_ magnification: CGFloat, centeredAt point: CGPoint? = nil, animationDuration: TimeInterval?) {
            if let animationDuration = animationDuration, animationDuration != 0.0 {
                NSAnimationContext.runAnimationGroup {
                    context in
                    context.duration = animationDuration
                    if let point = point {
                        self.animator().setMagnification(magnification, centeredAt: point)
                    } else {
                        self.animator().magnification = magnification
                    }
                }
            } else {
                if let point = point {
                    setMagnification(magnification, centeredAt: point)
                } else {
                    self.magnification = magnification
                }
            }
        }
        
        /// The range to which the content can be magnified.
        var magnificationRange: ClosedRange<CGFloat> {
            minMagnification...maxMagnification
        }
        
        /// A Boolean value that indicates whether the clip view should automatically center itself.
        var shouldCenterClipView: Bool {
            get { (contentView as? CenteredClipView)?.shouldCenter ?? false }
            set {
                if let centeredContentView = contentView as? CenteredClipView {
                    centeredContentView.shouldCenter = newValue
                } else if newValue {
                    let centeredContentView = CenteredClipView()
                    centeredContentView.frame = contentView.frame
                    centeredContentView.drawsBackground = contentView.drawsBackground
                    centeredContentView.backgroundColor = contentView.backgroundColor
                    centeredContentView.documentView = contentView.documentView
                    centeredContentView.documentCursor = contentView.documentCursor
                    contentView = centeredContentView
                }
            }
        }
        
        /**
         Zooms in the content by the specified factor.
         
         - Parameters:
            - factor: The amount by which to zoom in the content.
            - point: The point (in content view space) on which to center magnification.
            - animationDuration: The animation duration of the zoom, or `nil` if the zoom shouldn't be animated.
         */
        func zoomIn(factor: CGFloat = 0.5, centeredAt point: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: factor, centeredAt: point, animationDuration: animationDuration)
        }

        /**
         Zooms out the content by the specified factor.
         
         - Parameters:
            - factor: The amount by which to zoom out the content.
            - point: The point (in content view space) on which to center magnification.
            - animationDuration: The animation duration of the zoom, or `nil` if the zoom shouldn't be animated.
         */
        func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: -factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }
        
        internal func zoom(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            if allowsMagnification {
                let range = maxMagnification - minMagnification
                if range > 0.0 {
                    let magnification = (magnification + (range * factor)).clamped(to: minMagnification ... maxMagnification)
                    let visibleSize = documentVisibleRect.size
                    setMagnification(magnification, centeredAt: centeredAt, animationDuration: animationDuration)
                    let newVisibleSize = documentVisibleRect.size
                    contentOffset.x *= (newVisibleSize.width / visibleSize.width)
                    contentOffset.y *= (newVisibleSize.height / visibleSize.height)
                }
            }
        }
        
        /// A Boolean value that indicates whether the scroll view should automatically manages it's document view.
        var shouldManageDocumentView: Bool {
            get { getAssociatedValue(key: "manageDocumentView", object: self, initialValue: false) }
            set {
                guard newValue != shouldManageDocumentView else { return }
                set(associatedValue: newValue, key: "manageDocumentView", object: self)
                if newValue {
                    documentView?.frame = bounds
                    scrollViewObserver = KeyValueObserver(self)
                    scrollViewObserver?.add(\.documentView) { [weak self] old, new in
                        guard let self = self, old != new, let new = new else { return }
                        new.frame = self.bounds
                    }
                    scrollViewObserver?.add(\.frame) { [weak self] old, new in
                        guard let self = self, old != new, let documentView = self.documentView else { return }
                        documentView.frame = CGRect(.zero, new.size)
                        guard self.contentOffset != .zero else { return }
                        self.contentOffset.x *= (new.width / old.width)
                        self.contentOffset.y *= (new.height / old.height)
                    }
                } else {
                    scrollViewObserver = nil
                }
            }
        }
        
        internal var scrollViewObserver: KeyValueObserver<NSScrollView>? {
            get { getAssociatedValue(key: "scrollViewObserver", object: self, initialValue: nil) }
            set { set(associatedValue: newValue, key: "scrollViewObserver", object: self) }
        }

        /// A saved scroll position.
        struct SavedScrollPosition {
            let bounds: CGRect
            let visible: CGRect
        }

        /// Saves the current scroll position.
        func saveScrollPosition() -> SavedScrollPosition {
            SavedScrollPosition(bounds: bounds, visible: visibleRect)
        }

        /**
         Restores the specified saved scroll position.

         - Parameter scrollPosition: The scroll position to restore.
         */
        func restoreScrollPosition(_ scrollPosition: SavedScrollPosition) {
            let oldBounds = scrollPosition.bounds
            let oldVisible = scrollPosition.visible
            let oldY = oldVisible.midY
            let oldH = oldBounds.height
            guard oldH > 0.0 else { return }

            let fraction = (oldY - oldBounds.minY) / oldH
            let newBounds = bounds
            var newVisible = visibleRect
            let newY = newBounds.minY + fraction * newBounds.height
            newVisible.origin.y = newY - 0.5 * newVisible.height
            scroll(newVisible.origin)
        }
    }

#endif
