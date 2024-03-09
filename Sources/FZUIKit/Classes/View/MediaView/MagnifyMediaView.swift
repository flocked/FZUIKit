//
//  MagnifyMediaView.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
    import AppKit
    import AVKit
    import Foundation
    import FZSwiftUtils

    /// A magnifiable view that presents media.
    open class MagnifyMediaView: NSView {
        public let mediaView = MediaView()
        private let scrollView = NSScrollView()
        
        /// The video player view that is playing video.
        public var videoView: AVPlayerView {
            mediaView.videoView
        }

        override open var acceptsFirstResponder: Bool {
            true
        }

        open var overlayView: NSView? {
            get { mediaView.overlayView }
            set { mediaView.overlayView = newValue }
        }

        open var tintColor: NSColor? {
            get { mediaView.tintColor }
            set { mediaView.tintColor = newValue }
        }

        open var doubleClickZoomFactor: CGFloat = 0.5

        override open func mouseDown(with event: NSEvent) {
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

        override open func rightMouseDown(with _: NSEvent) {
            mediaView.videoView.player?.togglePlayback()
        }
        
        open override func menu(for event: NSEvent) -> NSMenu? {
            return nil
        }

        override open func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 30:
                if event.modifierFlags.contains(.command) {
                    setMagnification(maxMagnification)
                } else {
                    zoomIn(factor: 0.3)
                }
            case 44:
                if event.modifierFlags.contains(.command) {
                    //  self.setMagnification(self.minMagnification, animationDuration: 0.1)
                    setMagnification(1.0)
                } else {
                    zoomOut(factor: 0.3)
                }
            default:
                super.keyDown(with: event)
            }
        }

        override open var mouseDownCanMoveWindow: Bool {
            true
        }

        open func scroll(to point: CGPoint) {
            scrollView.contentView.setBoundsOrigin(point)
            scrollView.scroll(scrollView.contentView, to: point)
        }

        open func scroll(to point: CGPoint, animationDuration: TimeInterval) {
            scrollView.scroll(point, animationDuration: animationDuration)
        }

        open func zoomIn(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }

        open func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: -factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }

        open func zoom(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            if allowsMagnification {
                let range = maxMagnification - minMagnification
                if range > 0.0 {
                    let factor = factor.clamped(to: -1.0 ... 1.0)
                    let newMag = (magnification + (range * factor)).clamped(to: minMagnification ... maxMagnification)
                    setMagnification(newMag, centeredAt: centeredAt, animationDuration: animationDuration)
                }
            }
        }

        open func setMagnification(_ magnification: CGFloat, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            scrollView.setMagnification(magnification, centeredAt: centeredAt, animationDuration: animationDuration)
            if magnification == 1.0 {
                scrollElasticity = .none
                hasScrollers = false
            } else {
                hasScrollers = true
                scrollElasticity = .automatic
            }
        }

        open var mediaURL: URL? {
            get { mediaView.mediaURL }
            set {
                mediaView.mediaURL = newValue
                //    scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        open var image: NSImage? {
            get { mediaView.image }
            set {
                mediaView.image = newValue
                //  scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        open var images: [NSImage] {
            get { mediaView.images }
            set {
                mediaView.images = newValue
                //  scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        @available(macOS 12.0, iOS 13.0, *)
        open var symbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { mediaView.symbolConfiguration }
            set { mediaView.symbolConfiguration = newValue }
        }

        open var asset: AVAsset? {
            get { mediaView.asset }
            set {
                mediaView.asset = newValue
                //   scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        open var isMuted: Bool {
            get { mediaView.isMuted }
            set { mediaView.isMuted = newValue }
        }

        open var volume: Float {
            get { mediaView.volume }
            set { mediaView.volume = newValue }
        }

        open var videoPlaybackOption: MediaView.VideoPlaybackOption {
            get { mediaView.videoPlaybackOption }
            set { mediaView.videoPlaybackOption = newValue }
        }

        public func seek(to interval: TimeDuration) {
            mediaView.seek(to: interval)
        }

        public func seek(toPercentage percentage: Double) {
            mediaView.seek(toPercentage: percentage)
        }

        public var videoPlaybackTime: TimeDuration {
            get { mediaView.videoPlaybackTime }
            set { mediaView.videoPlaybackTime = newValue }
        }

        public var videoDuration: TimeDuration { mediaView.videoDuration }

        public var videoPlaybackPosition: Double {
            get { mediaView.videoPlaybackPosition }
            set { mediaView.videoPlaybackPosition = newValue }
        }

        public var videoPlaybackPositionHandler: ((TimeDuration) -> Void)? {
            get { mediaView.videoPlaybackPositionHandler }
            set { mediaView.videoPlaybackPositionHandler = newValue }
        }

        override open var menu: NSMenu? {
            get { mediaView.menu }
            set { mediaView.menu = newValue }
        }

        public var player: AVPlayer? {
            get { mediaView.videoView.player }
            set { mediaView.videoView.player = newValue }
        }

        open var autoAnimatesImages: Bool {
            get { mediaView.autoAnimatesImages }
            set { mediaView.autoAnimatesImages = newValue }
        }

        open var loopVideos: Bool {
            get { mediaView.loopVideos }
            set { mediaView.loopVideos = newValue }
        }

        open var videoViewControlStyle: AVPlayerViewControlsStyle {
            get { mediaView.videoViewControlStyle }
            set { mediaView.videoViewControlStyle = newValue }
        }

        open var contentScaling: CALayerContentsGravity {
            get { mediaView.contentScaling }
            set { mediaView.contentScaling = newValue }
        }

        open var mediaType: FileType? { mediaView.mediaType }

        open func play() {
            mediaView.play()
        }

        open func pause() {
            mediaView.pause()
        }

        open func stop() {
            mediaView.stop()
        }

        open func togglePlayback() {
            mediaView.togglePlayback()
        }

        open var isPlaying: Bool {
            mediaView.isPlaying
        }

        override open var fittingSize: NSSize {
            mediaView.fittingSize
        }

        open func sizeToFit() {
            frame.size = fittingSize
        }

        open var hasScrollers: Bool {
            get { scrollView.hasVerticalScroller }
            set {
                scrollView.hasVerticalScroller = newValue
                scrollView.hasHorizontalScroller = newValue
            }
        }

        open var scrollElasticity: NSScrollView.Elasticity {
            get { scrollView.verticalScrollElasticity }
            set {
                scrollView.verticalScrollElasticity = newValue
                scrollView.horizontalScrollElasticity = newValue
            }
        }

        open var allowsMagnification: Bool {
            get { scrollView.allowsMagnification }
            set { scrollView.allowsMagnification = newValue }
        }

        open var magnification: CGFloat {
            get { scrollView.magnification }
            set { setMagnification(newValue) }
        }

        open var minMagnification: CGFloat {
            get { scrollView.minMagnification }
            set { scrollView.minMagnification = newValue }
        }

        open var maxMagnification: CGFloat {
            get { self.scrollView.maxMagnification }
            set { self.scrollView.maxMagnification = newValue }
        }

        override open var enclosingScrollView: NSScrollView? {
            scrollView
        }

        public init() {
            super.init(frame: .zero)
            sharedInit()
        }

        public init(mediaURL: URL) {
            super.init(frame: .zero)
            sharedInit()
            self.mediaURL = mediaURL
        }

        public init(image: NSImage) {
            super.init(frame: .zero)
            sharedInit()
            self.image = image
        }

        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }

        override open func layout() {
            super.layout()
            scrollView.frame.size = bounds.size
            scrollView.documentView?.frame.size = bounds.size
        }

        private func sharedInit() {
            wantsLayer = true
            mediaView.wantsLayer = true
            mediaView.frame = bounds
            scrollView.frame = bounds

            addSubview(scrollView)

            scrollView.contentView = CenteredClipView()

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

        /// Handlers for a media view.
        public struct Handlers {
            /// Handler that gets called whenever the player view receives a `keyDown` event.
            public var keyDown: ((NSEvent) -> (Bool))?

            /// Handler that gets called whenever the player view receives a `mouseDown` event.
            public var mouseDown: ((NSEvent) -> (Bool))?

            /// Handler that gets called whenever the player view receives a `rightMouseDown` event.
            public var rightMouseDown: ((NSEvent) -> (Bool))?

            /// Handler that gets called whenever the player view receives a `flagsChanged` event.
            public var flagsChanged: ((NSEvent) -> (Bool))?
        }

        /// Handlers for the media view.
        public var handlers: Handlers = .init()
    }
#endif
