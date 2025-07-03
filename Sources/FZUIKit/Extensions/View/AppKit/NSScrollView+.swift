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
        /// Sets the Boolean value that indicates whether the scroll view draws its background.
        @discardableResult
        public func drawsBackground(_ draws: Bool) -> Self {
            drawsBackground = draws
            return self
        }
        
        /// Sets the color of the content view’s background.
        @discardableResult
        public func backgroundColor(_ color: NSColor?) -> Self {
            backgroundColor = color ?? .clear
            drawsBackground = color != nil
            return self
        }
        
        /// The Autoscroll speed (pixel per second) of the scroll view, or `nil` for no autoscrolling.
        @available(macOS 14.0, *)
        public var autoScrollSpeed: CGFloat? {
            get { getAssociatedValue("autoScrollSpeed") }
            set {
                var newValue = newValue?.clamped(min: 0.0)
                newValue = newValue == 0.0 ? nil : newValue
                guard newValue != autoScrollSpeed else { return }
                setAssociatedValue(newValue, key: "autoScrollSpeed")
                if let newValue = newValue {
                    autoScrollDisplaylink = DisplayLink(view: self) { [weak self] frame in
                        guard let self = self, let displayLink = self.autoScrollDisplaylink, let documentView = self.documentView else { return }
                        let currentOrigin = self.contentView.bounds.origin
                        let maxScrollY = documentView.bounds.height - self.contentSize.height
                        var newY = max(0, min(currentOrigin.y + newValue / displayLink.framesPerSecond, documentView.bounds.height - self.contentSize.height))
                        if self.loopsAutoScroll && newY >= maxScrollY {
                               newY = 0
                           } else {
                               newY = max(0, min(newY, maxScrollY))
                           }
                        let newOrigin = NSPoint(x: currentOrigin.x, y: newY)
                        self.contentView.scroll(to: newOrigin)
                        self.reflectScrolledClipView(contentView)
                    }
                    autoScrollDisplaylink?.isPaused = documentView == nil
                    autoScrollDocumentViewObservation = observeChanges(for: \.documentView) { [weak self] old, new in
                        self?.autoScrollDisplaylink?.isPaused = new == nil
                    }
                } else {
                    autoScrollDisplaylink = nil
                    autoScrollDocumentViewObservation = nil
                }
            }
        }
        
        /// Sets the Autoscroll speed (pixel per second) of the scroll view, or `nil` for no autoscrolling.
        @discardableResult
        @available(macOS 14.0, *)
        public func autoScrollSpeed(_ speed: CGFloat?) -> Self {
            autoScrollSpeed = speed
            return self
        }
        
        /// A Boolean value indicating whether the autoscrolling should loop when the scroll view reached the bottom.
        @available(macOS 14.0, *)
        public var loopsAutoScroll: Bool {
            get { getAssociatedValue("loopsAutoScroll") ?? false }
            set { setAssociatedValue(newValue, key: "loopsAutoScroll") }
        }
        
        /// Sets the Boolean value indicating whether the autoscrolling should loop when the scroll view reached the bottom.
        @discardableResult
        @available(macOS 14.0, *)
        public func loopsAutoScroll(_ loops: Bool) -> Self {
            loopsAutoScroll = loops
            return self
        }
        
        @available(macOS 14.0, *)
        var autoScrollDisplaylink: DisplayLink? {
            get { getAssociatedValue("autoScrollDisplaylink") }
            set { setAssociatedValue(newValue, key: "autoScrollDisplaylink") }
        }
        
        @available(macOS 14.0, *)
        var autoScrollDocumentViewObservation: KeyValueObservation? {
            get { getAssociatedValue("autoScrollDocumentViewObservation") }
            set { setAssociatedValue(newValue, key: "autoScrollDocumentViewObservation") }
        }
        
        
        /// Sets the value that specifies the appearance of the scroll view’s border.
        @discardableResult
        public func borderType(_ type: NSBorderType) -> Self {
            borderType = type
            return self
        }
        
        /// Sets the view the scroll view scrolls within its content view.
        @discardableResult
        public func documentView(_ view: NSView?) -> Self {
            documentView = view
            return self
        }
        
        /// Sets the scroll view’s content view, the view that clips the document view.
        @discardableResult
        public func contentView(_ view: NSClipView) -> Self {
            contentView = view
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view has a vertical and horizontal scroller.
        @discardableResult
        public func hasScroller(_ hasScroller: Bool) -> Self {
            self.hasVerticalScroller = hasScroller
            self.hasHorizontalScroller = hasScroller
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view has a vertical scroller.
        @discardableResult
        public func hasVerticalScroller(_ hasScroller: Bool) -> Self {
            self.hasVerticalScroller = hasScroller
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view has a horizontal scroller.
        @discardableResult
        public func hasHorizontalScroller(_ hasScroller: Bool) -> Self {
            self.hasHorizontalScroller = hasScroller
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view keeps a vertical and horizontal ruler object.
        @discardableResult
        public func hasRuler(_ hasRuler: Bool) -> Self {
            self.hasVerticalRuler = hasRuler
            self.hasHorizontalScroller = hasRuler
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view keeps a vertical ruler object.
        @discardableResult
        public func hasVerticalRuler(_ hasRuler: Bool) -> Self {
            self.hasVerticalRuler = hasRuler
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view keeps a horizontal ruler object.
        @discardableResult
        public func hasHorizontalRuler(_ hasRuler: Bool) -> Self {
            self.hasHorizontalRuler = hasRuler
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view displays its rulers.
        @discardableResult
        public func rulersVisible(_ visible: Bool) -> Self {
            self.rulersVisible = visible
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view automatically adjusts its content insets.
        @discardableResult
        public func automaticallyAdjustsContentInsets(_ adjusts: Bool) -> Self {
            self.automaticallyAdjustsContentInsets = adjusts
            return self
        }
        
        /// Sets the distance that the scroll view’s subviews are inset from the enclosing scroll view during tiling.
        @discardableResult
        public func contentInsets(_ insets: NSEdgeInsets) -> Self {
            self.contentInsets = insets
            return self
        }
        
        /// Sets the distance the scrollers are inset from the edge of the scroll view.
        @discardableResult
        public func scrollerInsets(_ insets: NSEdgeInsets) -> Self {
            self.scrollerInsets = insets
            return self
        }
        
        /// Sets the knob style of scroll views that use the overlay scroller style.
        @discardableResult
        public func scrollerKnobStyle(_ style: NSScroller.KnobStyle) -> Self {
            self.scrollerKnobStyle = style
            return self
        }
        
        /// Sets the scroller style used by the scroll view.
        @discardableResult
        public func scrollerStyle(_ style: NSScroller.Style) -> Self {
            self.scrollerStyle = style
            return self
        }
        
        /// Sets the Boolean that indicates whether the scroll view redraws its document view while scrolling continuously.
        @discardableResult
        public func scrollsDynamically(_ scrollsDynamically: Bool) -> Self {
            self.scrollsDynamically = scrollsDynamically
            return self
        }
        
        /// Sets the scroll view’s vertical and horizontal scrolling elasticity mode.
        @discardableResult
        public func scrollElasticity(_ elasticity: Elasticity) -> Self {
            self.horizontalScrollElasticity = elasticity
            self.verticalScrollElasticity = elasticity
            return self
        }
        
        /// Sets the scroll view’s vertical scrolling elasticity mode.
        @discardableResult
        public func verticalScrollElasticity(_ elasticity: Elasticity) -> Self {
            self.verticalScrollElasticity = elasticity
            return self
        }
        
        /// Sets the scroll view’s horizontal scrolling elasticity mode.
        @discardableResult
        public func horizontalScrollElasticity(_ elasticity: Elasticity) -> Self {
            self.horizontalScrollElasticity = elasticity
            return self
        }
        
        /// Sets the Boolean that indicates whether the user is allowed to magnify the scroll view.
        @discardableResult
        public func allowsMagnification(_ allows: Bool) -> Self {
            self.allowsMagnification = allows
            return self
        }
        
        /// Sets the amount by which the content is currently scaled.
        @discardableResult
        public func magnification(_ magnification: CGFloat) -> Self {
            self.magnification = magnification
            return self
        }
        
        /// Sets the minimum value to which the content can be magnified.
        @discardableResult
        public func minMagnification(_ minMagnification: CGFloat) -> Self {
            self.minMagnification = minMagnification
            return self
        }
        
        /// Sets the maximum value to which the content can be magnified.
        @discardableResult
        public func maxMagnification(_ maxMagnification: CGFloat) -> Self {
            self.maxMagnification = maxMagnification
            return self
        }
        
        /// Sets the scroll view’s line by line scroll amount.
        @discardableResult
        public func lineScroll(_ lineScroll: CGFloat) -> Self {
            self.lineScroll = lineScroll
            return self
        }
        
        /// Sets the scroll view’s horizontal line by line scroll amount.
        @discardableResult
        public func horizontalLineScroll(_ lineScroll: CGFloat) -> Self {
            self.horizontalLineScroll = lineScroll
            return self
        }
        
        /// Sets the scroll view’s vertical line by line scroll amount.
        @discardableResult
        public func verticalLineScroll(_ lineScroll: CGFloat) -> Self {
            self.verticalLineScroll = lineScroll
            return self
        }
        
        /// Sets the amount of the document view kept visible when scrolling page by page.
        @discardableResult
        public func pageScroll(_ pageScroll: CGFloat) -> Self {
            self.pageScroll = pageScroll
            return self
        }
        
        /// Sets the amount of the document view kept visible when scrolling horizontally page by page.
        @discardableResult
        public func horizontalPageScroll(_ pageScroll: CGFloat) -> Self {
            self.horizontalPageScroll = pageScroll
            return self
        }
        
        /// Sets the amount of the document view kept visible when scrolling vertically page by page.
        @discardableResult
        public func verticalPageScroll(_ pageScroll: CGFloat) -> Self {
            self.verticalPageScroll = pageScroll
            return self
        }
                                                
        var contentOffsetNotificationToken: NotificationToken? {
            get { getAssociatedValue("contentOffsetNotificationToken") }
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
        public var contentOffset: CGPoint {
            get { _contentOffset }
            set {
                NSView.swizzleAnimationForKey()
                _contentOffset = newValue
            }
        }
        
        @objc var _contentOffset: CGPoint {
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
        public var contentOffsetFractional: CGPoint {
            get { _contentOffsetFractional }
            set {
                NSView.swizzleAnimationForKey()
                _contentOffsetFractional = newValue
            }
        }
        
        @objc var _contentOffsetFractional: CGPoint {
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
        public var documentSize: CGSize {
            get { _documentSize }
            set {
                NSView.swizzleAnimationForKey()
                _documentSize = newValue
            }
        }
        
        @objc var _documentSize: CGSize {
            get { (documentView?.bounds.size ?? .zero) * magnification }
            set {
                guard newValue != documentSize else { return }
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
        
        /// A Boolean value that indicates whether the scroll view should automatically manage it's document view.
        @objc open var managesDocumentView: Bool {
            get { getAssociatedValue("managesDocumentView", initialValue: false) }
            set {
                guard newValue != managesDocumentView else { return }
                setAssociatedValue(newValue, key: "managesDocumentView")
                updateScrollViewObserver()
                documentView?.frame = bounds
            }
        }
        
        /// Sets the Boolean value that indicates whether the scroll view should automatically manage it's document view.
        @discardableResult
        @objc open func managesDocumentView(_ manages: Bool) -> Self {
            self.managesDocumentView = manages
            return self
        }
        
        ///A Boolean value that indicates whether the scrollers automatically hide if the `magnification` value is `1.0`.
        @objc open var hidesScrollersWhenZoomedOut: Bool {
            get { getAssociatedValue("hidesScrollersWhenZoomedOut", initialValue: false) }
            set {
                guard newValue != hidesScrollersWhenZoomedOut else { return }
                setAssociatedValue(newValue, key: "hidesScrollersWhenZoomedOut")
                updateScrollViewObserver()
                scrollerConfiguration = ScrollerConfiguration(verticalElasticity: verticalScrollElasticity, horizontalElasticity: horizontalScrollElasticity, hasVertical: hasVerticalRuler, hasHorizontal: hasHorizontalScroller)
            }
        }
                
        /// Sets the Boolean value that indicates whether the scrollers automatically hide if the `magnification` value is `1.0`.
        @discardableResult
        @objc open func hidesScrollersWhenZoomedOut(_ hides: Bool) -> Self {
            self.hidesScrollersWhenZoomedOut = hides
            return self
        }
        
        var scrollViewObserver: KeyValueObserver<NSScrollView>? {
            get { getAssociatedValue("scrollViewObserver") }
            set { setAssociatedValue(newValue, key: "scrollViewObserver") }
        }
        
        func updateScrollViewObserver() {
            if managesDocumentView || hidesScrollersWhenZoomedOut {
                scrollViewObserver = KeyValueObserver(self)
                if managesDocumentView {
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
                }
                if hidesScrollersWhenZoomedOut {
                    scrollViewObserver?.add(\.verticalScrollElasticity) { [weak self] old, new in
                        guard let self = self, old != new, !self.isUpdatingScrollers else { return }
                        self.scrollerConfiguration.verticalElasticity = new
                    }
                    scrollViewObserver?.add(\.horizontalScrollElasticity) { [weak self] old, new in
                        guard let self = self, old != new, !self.isUpdatingScrollers else { return }
                        self.scrollerConfiguration.horizontalElasticity = new
                    }
                    scrollViewObserver?.add(\.hasVerticalScroller) { [weak self] old, new in
                        guard let self = self, old != new, !self.isUpdatingScrollers else { return }
                        self.scrollerConfiguration.hasVertical = new
                    }
                    scrollViewObserver?.add(\.hasHorizontalScroller) { [weak self] old, new in
                        guard let self = self, old != new, !self.isUpdatingScrollers else { return }
                        self.scrollerConfiguration.hasHorizontal = new
                    }
                    scrollViewObserver?.add(\.magnification) { [weak self] old, new in
                        guard let self = self else { return }
                        guard (old == 1.0 && new != 1.0) || old != 1.0 && new == 1.0 else { return }
                        self.updateScrollers()
                    }
                }
            } else {
                scrollViewObserver = nil
            }
        }
        
        var scrollerConfiguration: ScrollerConfiguration {
            get { getAssociatedValue("scrollerConfiguration", initialValue: ScrollerConfiguration(verticalElasticity: verticalScrollElasticity, horizontalElasticity: horizontalScrollElasticity, hasVertical: hasVerticalRuler, hasHorizontal: hasHorizontalScroller)) }
            set {
                setAssociatedValue(newValue, key: "scrollerConfiguration")
                updateScrollers()
            }
        }
        
        var isUpdatingScrollers: Bool {
            get { getAssociatedValue("isUpdatingScrollers", initialValue: false) }
            set { setAssociatedValue(newValue, key: "isUpdatingScrollers") }
        }
        
        func updateScrollers() {
            guard hidesScrollersWhenZoomedOut else { return }
            isUpdatingScrollers = true
            if magnification == 1.0 {
                verticalScrollElasticity = .none
                horizontalScrollElasticity = .none
                hasVerticalScroller = false
                hasHorizontalScroller = false
            } else {
                verticalScrollElasticity = scrollerConfiguration.verticalElasticity
                horizontalScrollElasticity = scrollerConfiguration.horizontalElasticity
                hasVerticalScroller = scrollerConfiguration.hasVertical
                hasHorizontalScroller = scrollerConfiguration.hasHorizontal
            }
            isUpdatingScrollers = false
        }
        
        
        struct ScrollerConfiguration {
            var verticalElasticity: NSScrollView.Elasticity
            var horizontalElasticity: NSScrollView.Elasticity
            var hasVertical: Bool
            var hasHorizontal: Bool
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
              
        /// The handlers for the scroll view.
        public var handlers: Handlers {
            get { getAssociatedValue("scrollViewHandlers", initialValue: Handlers()) }
            set {
                setAssociatedValue(newValue, key: "scrollViewHandlers")
                if let handler = handlers.documentVisibleRect {
                    func setup(for view: NSView?) {
                        if let view = view {
                            view.postsBoundsChangedNotifications = true
                            scrollViewTokens[NSView.boundsDidChangeNotification] = NotificationCenter.default.observe(NSView.boundsDidChangeNotification, object: view) { [weak self] _ in
                                guard let self = self else { return }
                                handler(self.documentVisibleRect)
                            }
                        } else {
                            scrollViewTokens[NSView.boundsDidChangeNotification] = nil
                        }
                    }
                    documentViewObservation = observeChanges(for: \.documentView) { [weak self] old, new in
                        guard self != nil else { return }
                        setup(for: new)
                    }
                    setup(for: documentView)
                } else {
                    scrollViewTokens[NSView.boundsDidChangeNotification] = nil
                    documentViewObservation = nil
                }
                func setup(_ keyPath: KeyPath<NSScrollView, (()->())?>, notification: Notification.Name) {
                    if let handler = self[keyPath: keyPath] {
                        scrollViewTokens[notification] = NotificationCenter.default.observe(notification, object: self) { _ in
                            handler()
                        }
                    } else {
                        scrollViewTokens[notification] = nil
                    }
                }
                setup(\.handlers.userWillStartMagnify, notification: NSScrollView.willStartLiveMagnifyNotification)
                setup(\.handlers.userDidEndMagnify, notification: NSScrollView.didEndLiveMagnifyNotification)
                setup(\.handlers.userWillStartScroll, notification: NSScrollView.willStartLiveScrollNotification)
                setup(\.handlers.userDidEndScroll, notification: NSScrollView.didEndLiveScrollNotification)
                setup(\.handlers.userDidScroll, notification: NSScrollView.didLiveScrollNotification)
            }
        }
        
        /// The handlers for the scroll view.
        public struct Handlers {
            /// The handler that gets called at the beginning of a user-initiated magnify gesture.
            public var userWillStartMagnify: (()->())?
            /// The handler that gets called at the end of a user-initiated magnify gesture.
            public var userDidEndMagnify: (()->())?
            /// The handler that gets called at the beginning of a user-initiated scroll (gesture scroll or scroller tracking).
            public var userWillStartScroll: (()->())?
            /// The handler that gets called after the clipview bounds origin changed due to a user-initiated scroll.
            public var userDidScroll: (()->())?
            /// The handler that gets called at the end of a user-initiated scroll (gesture scroll or scroller tracking).
            public var userDidEndScroll: (()->())?
            /// The handler that gets called when the visible rectangle of the document view changes.
            public var documentVisibleRect: ((CGRect)->())?
        }
        
        var scrollViewTokens: [Notification.Name : NotificationToken] {
            get { getAssociatedValue("scrollViewTokens", initialValue: [:]) }
            set { setAssociatedValue(newValue, key: "scrollViewTokens") }
        }
        
        var documentViewObservation: KeyValueObservation? {
            get { getAssociatedValue("documentViewObservation") ?? nil }
            set { setAssociatedValue(newValue, key: "documentViewObservation") }
        }
    }

extension NSScrollView {
    /**
     The amount by which to zoom the image when the user double clicks the view.
     
     Specify a value of `nil` to disable zooming via mouse clicks.
     */
    var mouseClickZoomFactorAlt: CGFloat? {
        get { getAssociatedValue("mouseClickZoomFactorAlt") }
        set {
            guard newValue != mouseClickZoomFactorAlt else { return }
            setAssociatedValue(newValue, key: "mouseClickZoomFactorAlt")
            setupScrollViewGestureRecognizer()
        }
    }
    
    /**
     The amount by which to zoom the image when the user presses either the `plus` or `minus` key.
     
     Specify a value of `nil` to disable zooming via keyboard.
     */
    var keyDownZoomFactorAlt: CGFloat? {
        get { getAssociatedValue("keyDownZoomFactorAlt") }
        set {
            guard newValue != mouseClickZoomFactorAlt else { return }
            setAssociatedValue(newValue, key: "keyDownZoomFactorAlt")
            setupScrollViewGestureRecognizer()
        }
    }
    
    /**
     The amount by which to momentarily zoom the image when the user holds the `space` key.
     
     Specify a value of `nil` to disable zooming via space key.
     */
    var spaceKeyZoomFactorAlt: CGFloat? {
        get { getAssociatedValue("spaceKeyZoomFactor") }
        set {
            guard newValue != mouseClickZoomFactorAlt else { return }
            setAssociatedValue(newValue, key: "spaceKeyZoomFactor")
            setupScrollViewGestureRecognizer()
        }
    }
    
    func setupScrollViewGestureRecognizer() {
        if spaceKeyZoomFactorAlt == nil, keyDownZoomFactorAlt == nil, mouseClickZoomFactorAlt == nil {
            scrollViewGestureRecognizer?.removeFromView()
            scrollViewGestureRecognizer = nil
        } else if scrollViewGestureRecognizer == nil {
            scrollViewGestureRecognizer = ScrollViewGestureRecognizer(self)
        }
    }
    
    var scrollViewGestureRecognizer: ScrollViewGestureRecognizer? {
        get { getAssociatedValue("scrollViewGestureRecognizer") }
        set { setAssociatedValue(newValue, key: "scrollViewGestureRecognizer") }
    }
    
    class ScrollViewGestureRecognizer: NSGestureRecognizer {
        init(_ scrollView: NSScrollView) {
            super.init(target: nil, action: nil)
            scrollView.addGestureRecognizer(self)
            delaysPrimaryMouseButtonEvents = true
            delaysKeyEvents = true
            reattachesAutomatically = true
        }
        
        override func mouseDown(with event: NSEvent) {
            defer { if state != .ended { state = .cancelled } }
            state = .began
            guard let scrollView = scrollView else { return }
            if let mouseClickZoomFactor = scrollView.mouseClickZoomFactorAlt, event.clickCount == 2 {
                if scrollView.magnification != 1.0 {
                    scrollView.setMagnification(1.0, centeredAt: nil, animationDuration: nil)
                } else {
                    scrollView.zoomIn(factor: mouseClickZoomFactor, centeredAt: event.location(in: scrollView))
                }
                state = .ended
            }
        }
        
        override func mouseUp(with event: NSEvent) {
            state = .began
            state = .cancelled
        }
        
        override func mouseDragged(with event: NSEvent) {
            state = .began
            state = .cancelled
        }
        
        override func keyDown(with event: NSEvent) {
            defer { if state != .ended { state = .cancelled } }
            state = .began
            guard let scrollView = scrollView else { return }
            switch event.keyCode {
            case 30:
                guard let keyDownZoomFactor = scrollView.keyDownZoomFactorAlt else { return }
                if event.modifierFlags.contains(.command) {
                    scrollView.setMagnification(scrollView.maxMagnification, centeredAt: nil, animationDuration: nil)
                } else {
                    scrollView.zoomIn(factor: keyDownZoomFactor)
                }
                state = .ended
            case 44:
                guard let keyDownZoomFactor = scrollView.keyDownZoomFactorAlt else { return }
                if event.modifierFlags.contains(.command) {
                    scrollView.setMagnification(1.0, centeredAt: nil, animationDuration: nil)
                } else {
                    scrollView.zoomOut(factor: keyDownZoomFactor)
                }
                state = .ended
            case 49:
                guard let spaceKeyZoomFactor = scrollView.spaceKeyZoomFactorAlt else { return }
                scrollView.zoomIn(factor: spaceKeyZoomFactor, animationDuration: 0.2)
                state = .ended
            default:
                super.keyDown(with: event)
            }
        }
        
        override func keyUp(with event: NSEvent) {
            defer { if state != .ended { state = .cancelled } }
            state = .began
            guard let scrollView = scrollView, event.keyCode == 49, let spaceKeyZoomFactor = scrollView.spaceKeyZoomFactorAlt else { return }
            scrollView.zoomOut(factor: spaceKeyZoomFactor, animationDuration: 0.2)
            state = .ended
        }
        
        override func flagsChanged(with event: NSEvent) {
            state = .began
            state = .cancelled
        }
        
        var scrollView: NSScrollView? {
            view as? NSScrollView
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#endif
