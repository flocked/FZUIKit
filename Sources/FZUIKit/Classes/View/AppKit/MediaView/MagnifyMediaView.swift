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
        private let scrollView = ScrollView()
        
        /// The video player view that is playing video.
        public var videoView: AVPlayerView {
            mediaView.videoView
        }

        override open var acceptsFirstResponder: Bool {
            true
        }

        /// A view for hosting layered content on top of the media view.
        open var overlayView: NSView? {
            get { mediaView.overlayView }
            set { mediaView.overlayView = newValue }
        }

        /// The image tint color for template and symbol images.
        open var tintColor: NSColor? {
            get { mediaView.tintColor }
            set { mediaView.tintColor = newValue }
        }
        
        /**
         The amount by which to zoom the image when the user presses either the plus or minus key.
         
         Specify a value of `0.0` to disable zooming via keyboard.
         */
        open var keyDownZoomFactor: CGFloat {
            get { scrollView.keyDownZoomFactor }
            set { scrollView.keyDownZoomFactor = newValue }
        }
        
        /**
         The amount by which to momentarily zoom the image when the user holds the space key.
         
         Specify a value of `0.0` to disable zooming via space key.
         */
        open var spaceKeyZoomFactor: CGFloat {
            get { scrollView.spaceKeyZoomFactor }
            set { scrollView.spaceKeyZoomFactor = newValue }
        }
        
        /**
         The amount by which to zoom the image when the user double clicks the view.
         
         Specify a value of `0.0` to disable zooming via mouse clicks.
         */
        open var mouseClickZoomFactor: CGFloat {
            get { scrollView.mouseClickZoomFactor }
            set { scrollView.mouseClickZoomFactor = newValue }
        }

        override open func rightMouseDown(with _: NSEvent) {
            mediaView.videoView.player?.togglePlayback()
        }
        
        open override func menu(for event: NSEvent) -> NSMenu? {
            return nil
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

        /**
         Zooms in the image by the specified factor.
         
         - Parameters:
            - factor: The amount by which to zoom in the image.
            - point: The point on which to center magnification.
            - animationDuration: The animation duration of the zoom, or `nil` if the zoom shouldn't be animated.
         */
        open func zoomIn(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            zoom(factor: factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }

        /**
         Zooms out the image by the specified factor.
         
         - Parameters:
            - factor: The amount by which to zoom out the image.
            - point: The point on which to center magnification.
            - animationDuration: The animation duration of the zoom, or `nil` if the zoom shouldn't be animated.
         */
        open func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            scrollView.zoom()
            zoom(factor: -factor, centeredAt: centeredAt, animationDuration: animationDuration)
        }

        func zoom(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
            if allowsMagnification {
                let range = maxMagnification - minMagnification
                if range > 0.0 {
                    let factor = factor.clamped(to: -1.0 ... 1.0)
                    let newMag = (magnification + (range * factor)).clamped(to: minMagnification ... maxMagnification)
                    setMagnification(newMag, centeredAt: centeredAt, animationDuration: animationDuration)
                    var point = CGPoint.zero
                    point.x = bounds.size.width / 2.0
                    point.y = bounds.size.height / 2.0
                    scrollView.contentOffset = point
                   

                }
            }
        }

        /**
         Magnifies the content by the given amount and optionally centers the result on the given point.

         - Parameters:
            - magnification: The amount by which to magnify the content.
            - point: The point (in content view space) on which to center magnification, or `nil` if the magnification shouldn't be centered.
            - animationDuration: The animation duration of the magnification, or `nil` if the magnification shouldn't be animated.
         */
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
                setMagnification(1.0)
            }
        }

        /// The image displayed in the media view.
        open var image: NSImage? {
            get { mediaView.image }
            set {
                mediaView.image = newValue
                setMagnification(1.0)
            }
        }

        /// The images displayed in the media view.
        open var images: [NSImage] {
            get { mediaView.images }
            set {
                mediaView.images = newValue
                setMagnification(1.0)
            }
        }

        /// The symbol configuration of the image.
        @available(macOS 12.0, iOS 13.0, *)
        open var symbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { mediaView.symbolConfiguration }
            set { mediaView.symbolConfiguration = newValue }
        }

        /// The asset in the media view.
        open var asset: AVAsset? {
            get { mediaView.asset }
            set {
                mediaView.asset = newValue
                //   scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }

        /// A Boolean value indicating whether media is muted.
        open var isMuted: Bool {
            get { mediaView.isMuted }
            set { mediaView.isMuted = newValue }
        }

        /// The volume of the media.
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

        open var imagePlayback: ImageView.AnimationPlaybackOption {
            get { mediaView.imagePlayback }
            set { mediaView.imagePlayback = newValue }
        }
        
        

        open var loopVideos: Bool {
            get { mediaView.loopVideos }
            set { mediaView.loopVideos = newValue }
        }

        open var videoViewControlStyle: AVPlayerViewControlsStyle {
            get { mediaView.videoViewControlStyle }
            set { mediaView.videoViewControlStyle = newValue }
        }

        open var contentScaling: ImageView.ImageScaling {
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
        
        open override func layout() {
            super.layout()
            scrollView.frame = bounds
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

        private func sharedInit() {
            backgroundColor = .black
            mediaView.wantsLayer = true
            mediaView.frame = bounds
            scrollView.frame = bounds
            scrollView.documentView = mediaView
            addSubview(scrollView)
        }
    }


#endif
