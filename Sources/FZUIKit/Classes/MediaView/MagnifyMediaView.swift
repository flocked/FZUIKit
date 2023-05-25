//
//  Magnee.swift
//  CombTest
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
    import AVKit
    import Cocoa
    import Foundation
    import FZSwiftUtils

    public class MagnifyMediaView: NSView {
        private let mediaView = MediaView()
        private let scrollView = NSScrollView()

        override public var acceptsFirstResponder: Bool {
            return true
        }

        public var overlayView: NSView? {
            get { return mediaView.overlayView }
            set { mediaView.overlayView = newValue }
        }

        public var contentTintColor: NSColor? {
            get { mediaView.contentTintColor }
            set { mediaView.contentTintColor = newValue }
        }

        public var doubleClickZoomFactor: CGFloat = 0.5
        override public func mouseDown(with event: NSEvent) {
            window?.makeFirstResponder(self)
            if event.clickCount == 2 {
                if magnification != 1.0 {
                    setMagnification(1.0)
                } else {
                    let mousePoint = event.location(in: self)
                    zoomIn(factor: doubleClickZoomFactor, centeredAt: mousePoint)
                }
            }
        }

        override public func rightMouseDown(with _: NSEvent) {
            mediaView.videoView.player?.togglePlayback()
        }

        override public func keyDown(with event: NSEvent) {
            if event.keyCode == 30 { // Zoom In
                if event.modifierFlags.contains(.command) {
                    setMagnification(maxMagnification)
                } else {
                    zoomIn(factor: 0.3)
                }
            } else if event.keyCode == 44 { // Zoom Out
                if event.modifierFlags.contains(.command) {
                    //  self.setMagnification(self.minMagnification, animationDuration: 0.1)
                    setMagnification(1.0)
                } else {
                    zoomOut(factor: 0.3)
                }
            } else {
                super.keyDown(with: event)
            }
        }

        override public var mouseDownCanMoveWindow: Bool {
            return true
        }

        public func scroll(to point: CGPoint) {
            scrollView.contentView.setBoundsOrigin(point)
            scrollView.scroll(scrollView.contentView, to: point)
        }

        public func scroll(to point: CGPoint, animationDuration: TimeInterval) {
            scrollView.scroll(point, animationDuration: animationDuration)
        }

        public func zoomIn(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }

        public func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: -factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }

        public func zoom(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            if allowsMagnification {
                let range = maxMagnification - minMagnification
                if range > 0.0 {
                    let factor = factor.clamped(to: -1.0 ... 1.0)
                    let newMag = (magnification + (range * factor)).clamped(to: minMagnification ... maxMagnification)
                    setMagnification(newMag, centeredAt: centeredAt, animationDuration: animationDuration)
                }
            }
        }

        public func setMagnification(_ magnification: CGFloat, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            scrollView.setMagnification(magnification, centeredAt: centeredAt, animationDuration: animationDuration)
            if magnification == 1.0 {
                scrollElasticity = .none
                hasScrollers = false
            } else {
                hasScrollers = true
                scrollElasticity = .automatic
            }
        }

        public var mediaURL: URL? {
            get { return mediaView.mediaURL }
            set {
                mediaView.mediaURL = newValue
                scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        public var image: NSImage? {
            get { return mediaView.image }
            set {
                mediaView.image = newValue
                scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        public var images: [NSImage] {
            get { return mediaView.images }
            set {
                mediaView.images = newValue
                scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        @available(macOS 12.0, iOS 13.0, *)
        public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { mediaView.symbolConfiguration }
            set { mediaView.symbolConfiguration = newValue }
        }

        public var asset: AVAsset? {
            get { return mediaView.asset }
            set {
                mediaView.asset = newValue
                scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        public var isMuted: Bool {
            get { mediaView.isMuted }
            set { mediaView.isMuted = newValue }
        }

        public var volume: Float {
            get { mediaView.volume }
            set { mediaView.volume = newValue }
        }

        public var videoPlaybackOption: MediaView.VideoPlaybackOption {
            get { mediaView.videoPlaybackOption }
            set { mediaView.videoPlaybackOption = newValue }
        }

        public var autoAnimatesImages: Bool {
            get { mediaView.autoAnimatesImages }
            set { mediaView.autoAnimatesImages = newValue }
        }

        public var loopVideos: Bool {
            get { mediaView.loopVideos }
            set { mediaView.loopVideos = newValue }
        }

        public var videoViewControlStyle: AVPlayerViewControlsStyle {
            get { mediaView.videoViewControlStyle }
            set { mediaView.videoViewControlStyle = newValue }
        }

        public var contentScaling: CALayerContentsGravity {
            get { mediaView.contentScaling }
            set { mediaView.contentScaling = newValue }
        }

        public var mediaType: URL.FileType? { return mediaView.mediaType }

        public func play() {
            mediaView.play()
        }

        public func pause() {
            mediaView.pause()
        }

        public func stop() {
            mediaView.stop()
        }

        public func togglePlayback() {
            mediaView.togglePlayback()
        }

        public var isPlaying: Bool {
            return mediaView.isPlaying
        }

        override public var fittingSize: NSSize {
            return mediaView.fittingSize
        }

        public func sizeToFit() {
            frame.size = fittingSize
        }

        public var hasScrollers: Bool {
            get { scrollView.hasVerticalScroller }
            set {
                scrollView.hasVerticalScroller = newValue
                scrollView.hasHorizontalScroller = newValue
            }
        }

        public var scrollElasticity: NSScrollView.Elasticity {
            get { scrollView.verticalScrollElasticity }
            set {
                scrollView.verticalScrollElasticity = newValue
                scrollView.horizontalScrollElasticity = newValue
            }
        }

        public var allowsMagnification: Bool {
            get { scrollView.allowsMagnification }
            set { scrollView.allowsMagnification = newValue }
        }

        public var magnification: CGFloat {
            get { scrollView.magnification }
            set { setMagnification(newValue) }
        }

        public var minMagnification: CGFloat {
            get { scrollView.minMagnification }
            set { scrollView.minMagnification = newValue }
        }

        public var maxMagnification: CGFloat {
            get { self.scrollView.maxMagnification }
            set { self.scrollView.maxMagnification = newValue }
        }

        override public var enclosingScrollView: NSScrollView? {
            return scrollView
        }

        public init(mediaURL: URL) {
            super.init(frame: .zero)
            self.mediaURL = mediaURL
        }

        public init(frame: CGRect, mediaURL: URL) {
            super.init(frame: frame)
            self.mediaURL = mediaURL
        }

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        private func sharedInit() {
            wantsLayer = true
            mediaView.wantsLayer = true
            mediaView.frame = bounds
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.frame = bounds
            addSubview(scrollView)

            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

            scrollView.contentView = CenteredClipView()

            scrollView.contentView.frame.size = CGSize(width: 50, height: 50)
            scrollView.drawsBackground = false

            mediaView.frame = scrollView.contentView.bounds
            mediaView.autoresizingMask = .all

            scrollView.documentView = mediaView

            allowsMagnification = true
            contentScaling = .resizeAspect
            minMagnification = 1.0
            maxMagnification = 3.0
            backgroundColor = .black
            enclosingScrollView?.backgroundColor = .black
        }
    }

    fileprivate class CenteredClipView: NSClipView {
        override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
            var rect = super.constrainBoundsRect(proposedBounds)

            if let containerView = documentView {
                if rect.size.width > containerView.frame.size.width {
                    rect.origin.x = (containerView.frame.width - rect.width) / 2
                }

                if rect.size.height > containerView.frame.size.height {
                    rect.origin.y = (containerView.frame.height - rect.height) / 2
                }
            }

            return rect
        }
    }
#endif
