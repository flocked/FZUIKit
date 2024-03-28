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

    extension NSScrollView {
        var contentOffsetNotificationToken: NotificationToken? {
            get { getAssociatedValue("contentOffsetNotificationToken", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "contentOffsetNotificationToken")}
        }
        
        var previousContentOffset: CGPoint {
            get { getAssociatedValue("previousContentOffset", initialValue: .zero) }
            set { setAssociatedValue(newValue, key: "previousContentOffset")}
        }
        
        var isChangingContentOffset: Bool {
            get { getAssociatedValue("isChangingContentOffset", initialValue: false) }
            set { setAssociatedValue(newValue, key: "isChangingContentOffset")}
        }
        
        public var contentOffsetIsObservable: Bool {
            get { getAssociatedValue("contentOffsetIsObservable", initialValue: false) }
            set {
                guard newValue != contentOffsetIsObservable else { return}
                setAssociatedValue(newValue, key: "contentOffsetIsObservable")
                if newValue {
                    previousContentOffset = contentOffset
                    contentView.postsBoundsChangedNotifications = true
                    contentOffsetNotificationToken = NotificationCenter.default.observe(NSView.boundsDidChangeNotification, object: contentView) { [weak self] notification in
                        guard let self = self, self.contentOffset != self.previousContentOffset else { return }
                        self.isChangingContentOffset = true
                        self.willChangeValue(for: \.contentOffset)
                        self.isChangingContentOffset = false
                        self.previousContentOffset = self.contentOffset
                        self.didChangeValue(for: \.contentOffset)
                    }
                } else {
                    contentOffsetNotificationToken = nil
                }
            }
        }
        
        /// Scrolls the scroll view to the top.
        public func scrollToBottom(animationDuration: TimeInterval? = nil) {
            var contentOffset = contentOffset
            contentOffset.y = maxContentOffset?.y ?? contentSize.height
            if let animationDuration = animationDuration {
                setContentOffset(contentOffset, animationDuration: animationDuration)
            } else {
                self.contentOffset = contentOffset
            }
        }

        /// Scrolls the scroll view to the bottom.
        public func scrollToTop(animationDuration: TimeInterval? = nil) {
            var contentOffset = contentOffset
            contentOffset.y = 0.0
            if let animationDuration = animationDuration {
                setContentOffset(contentOffset, animationDuration: animationDuration)
            } else {
                self.contentOffset = contentOffset
            }
        }
        
        /// Scrolls the scroll view to the left.
        public func scrollToLeft(animationDuration: TimeInterval? = nil) {
            var contentOffset = contentOffset
            contentOffset.x = 0.0
            if let animationDuration = animationDuration {
                setContentOffset(contentOffset, animationDuration: animationDuration)
            } else {
                self.contentOffset = contentOffset
            }
        }
        
        /// Scrolls the scroll view to the right.
        public func scrollToRight(animationDuration: TimeInterval? = nil) {
            var contentOffset = contentOffset
            contentOffset.x = maxContentOffset?.x ?? contentSize.width
            if let animationDuration = animationDuration {
                setContentOffset(contentOffset, animationDuration: animationDuration)
            } else {
                self.contentOffset = contentOffset
            }
        }
        
        /**
         The point at which the origin of the document view is offset from the origin of the scroll view.

         The value can be animated via `animator()`.
         */
        @objc dynamic open var contentOffset: CGPoint {
            get { isChangingContentOffset ? previousContentOffset : documentVisibleRect.origin }
            set {
                guard newValue.x.isFinite, newValue.y.isFinite else { return }
                NSView.swizzleAnimationForKey()
                documentView?.scroll(newValue)
            }
        }
        
        /**
         The fractional content offset on a range between `0.0` and `1.0`.
         
         - A value of `CGPoint(x:0, y:0)` indicates the document view is at the bottom left.
         - A value of `CGPoint(x:1, y:1)` indicates the document view is at the top right.

         The value can be animated via `animator()`.
         */
        @objc open var contentOffsetFractional: CGPoint {
            get {
                guard let maxOffset = maxContentOffset else { return .zero }
                return CGPoint(contentOffset.x / maxOffset.x, contentOffset.y / maxOffset.y)
            }
            set {
                guard let maxOffset = maxContentOffset else { return }
                NSView.swizzleAnimationForKey()
                contentOffset = CGPoint(newValue.x.clamped(to: 0.0...1.0) * maxOffset.x, newValue.y.clamped(to: 0.0...1.0) * maxOffset.y)
            }
        }
        
        public var maxContentOffset: CGPoint? {
            guard let documentView = documentView else { return nil }
            let maxY = documentView.frame.maxY - contentView.bounds.height
            let maxX = documentView.frame.maxX - contentView.bounds.width
            return CGPoint(maxX, maxY)
        }

        /**
         The size of the document view, or `zero` if there isn't a document view.

         The value can be animated via `animator()`.
         */
        @objc open var visibleDocumentSize: CGSize {
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
        @objc open var documentSize: CGSize {
            get { (documentView?.bounds.size ?? .zero) * magnification }
            set {
                guard newValue != documentSize else { return }
                NSView.swizzleAnimationForKey()
                let documentSize = (documentView?.bounds.size ?? .zero)
                magnification = max(newValue.width/documentSize.width, newValue.height/documentSize.height)
            }
        }
        
        func zoom(toSize size: CGSize) {
            magnification = max(contentSize.width/size.width, contentSize.height/size.height)
        }
        
        /**
         Sets the point at which the origin of the document view is offset from the origin of the scroll view.

         - Parameters:
            - contentOffset: The content offset to apply.
            - animationDuration: The animation duration.
         */
        @objc open func setContentOffset(_ contentOffset: CGPoint, animationDuration: TimeInterval, timingCurve: CAMediaTimingFunction = .default) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = animationDuration
                context.timingFunction = timingCurve
                self.contentView.animator().bounds.origin = contentOffset
            })
        }
        
        /**
         Sets the fractional content offset on a range between `0.0` and `1.0`.
         
         - A value of `CGPoint(x:0, y:0)` indicates the document view is at the bottom left.
         - A value of `CGPoint(x:1, y:1)` indicates the document view is at the top right.

         - Parameters:
            - contentOffset: The fractional content offset to apply.
            - animationDuration: The animation duration.
         */
       @objc open func setContentOffsetFractional(_ contentOffset: CGPoint, animationDuration: TimeInterval, timingCurve: CAMediaTimingFunction = .default) {
            guard let maxOffset = maxContentOffset else { return }
            let contentOffset = CGPoint(contentOffset.x.clamped(to: 0.0...1.0) * maxOffset.x, contentOffset.y.clamped(to: 0.0...1.0) * maxOffset.y)
            setContentOffset(contentOffset, animationDuration: animationDuration, timingCurve: timingCurve)
        }
        
        /**
         Sets the point at which the origin of the document view is offset from the origin of the scroll view.

         THe animation speed specifies the distance that is animated per second:
         
         `speed * 100 points per second`
         
         - Parameters:
            - contentOffset: The content offset to apply.
            - animationSpeed: The animation speed.
         */
        @objc open func setContentOffset(_ contentOffset: CGPoint, animationSpeed: TimeInterval, timingCurve: CAMediaTimingFunction = .default) {
            let distance = self.contentOffset.distance(to: contentOffset)
            let animationDuration = distance / (animationSpeed * 100.0)
                        
            setContentOffset(contentOffset, animationDuration: animationDuration, timingCurve: timingCurve)
        }
        
        /**
         Sets the point at which the origin of the document view is offset from the origin of the scroll view.

         THe animation speed specifies the distance that is animated per second:
         
         `speed * 100 points per second`
         
         - Parameters:
            - contentOffset: The content offset to apply.
            - animationSpeed: The animation speed.
         */
        @objc open func setContentOffsetFractional(_ contentOffset: CGPoint, animationSpeed: TimeInterval, timingCurve: CAMediaTimingFunction = .default) {
             guard let maxOffset = maxContentOffset else { return }
             let contentOffset = CGPoint(contentOffset.x.clamped(to: 0.0...1.0) * maxOffset.x, contentOffset.y.clamped(to: 0.0...1.0) * maxOffset.y)
             setContentOffset(contentOffset, animationSpeed: animationSpeed, timingCurve: timingCurve)
         }
        
        /*
        /**
         Scrolls to the specified

         - Parameters:
            - contentOffset: The content offset to apply.
            - animationDuration: The animation duration.
         */
        public func scroll(to point: CGPoint, animationDuration: CGFloat) {
            let fractionalOffset = CGPoint(point.x.clamped(to: 0...bounds.width) / bounds.width, point.y.clamped(to: 0...bounds.height) / bounds.height)
            setContentOffsetFractional(fractionalOffset, animationDuration: animationDuration)
        }
        
        /**
         Sets the point at which the origin of the document view is offset from the origin of the scroll view.

         THe animation speed specifies the distance that is animated per second:
         
         `speed * 100 points per second`
         
         - Parameters:
            - contentOffset: The content offset to apply.
            - animationSpeed: The animation speed.
         */
        public func scroll(to point: CGPoint, animationSpeed: CGFloat) {
            let fractionalOffset = CGPoint(point.x.clamped(to: 0...bounds.width) / bounds.width, point.y.clamped(to: 0...bounds.height) / bounds.height)
            setContentOffsetFractional(fractionalOffset, animationSpeed: animationSpeed)
        }
        */

        /**
         Magnifies the content by the given amount and optionally centers the result on the given point.

         - Parameters:
            - magnification: The amount by which to magnify the content.
            - point: The point (in content view space) on which to center magnification, or `nil` if the magnification shouldn't be centered.
            - animationDuration: The animation duration of the magnification, or `nil` if the magnification shouldn't be animated.
         */
       public func setMagnification(_ magnification: CGFloat, centeredAt point: CGPoint? = nil, animationDuration: TimeInterval?) {
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
       public var magnificationRange: ClosedRange<CGFloat> {
            minMagnification...maxMagnification
        }
        
        /// A Boolean value that indicates whether the clip view should automatically center itself.
        @objc open var shouldCenterClipView: Bool {
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
       public func zoomIn(factor: CGFloat = 0.5, centeredAt point: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: factor, centeredAt: point, animationDuration: animationDuration)
        }

        /**
         Zooms out the content by the specified factor.
         
         - Parameters:
            - factor: The amount by which to zoom out the content.
            - point: The point (in content view space) on which to center magnification.
            - animationDuration: The animation duration of the zoom, or `nil` if the zoom shouldn't be animated.
         */
       public func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: -factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }
        
        func zoom(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
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
        @objc open var shouldManageDocumentView: Bool {
            get { getAssociatedValue("manageDocumentView", initialValue: false) }
            set {
                guard newValue != shouldManageDocumentView else { return }
                setAssociatedValue(newValue, key: "manageDocumentView")
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
        
        var scrollViewObserver: KeyValueObserver<NSScrollView>? {
            get { getAssociatedValue("scrollViewObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "scrollViewObserver") }
        }

        /// A saved scroll position.
        public struct SavedScrollPosition {
            let offset: CGPoint
        }

        /**
         Returns a value representing the current scroll position.
         
         To restore the saved scroll position, use ``restoreScrollPosition(_:)``.
         
         - Returns: The saved scroll position.
         */
        public func saveScrollPosition() -> SavedScrollPosition {
            SavedScrollPosition(offset: contentOffsetFractional)
        }

        /**
         Restores the specified saved scroll position.
         
         To save a scroll position, use ``saveScrollPosition()``.

         - Parameter scrollPosition: The scroll position to restore.
         */
       public func restoreScrollPosition(_ scrollPosition: SavedScrollPosition) {
           contentOffsetFractional = scrollPosition.offset
        }
    }

#endif
