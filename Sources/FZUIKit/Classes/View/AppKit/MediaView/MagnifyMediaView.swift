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
        let scrollView = MediaScrollView()
        
        /// The video player view that is playing video.
        public var videoView: AVPlayerView {
            mediaView.videoView
        }

        /// A view for hosting layered content on top of the media view.
        open var overlayContentView: NSView {
            mediaView.overlayContentView
        }

        /// The image tint color for template and symbol images.
        open var imageTintColor: NSColor? {
            get { mediaView.imageTintColor }
            set { mediaView.imageTintColor = newValue }
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

        open override func rightMouseDown(with _: NSEvent) {
            mediaView.videoView.player?.togglePlayback()
        }
        
        open override func menu(for event: NSEvent) -> NSMenu? {
            return nil
        }

        open override var mouseDownCanMoveWindow: Bool {
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

        /// The symbol configuration of the image.
        @available(macOS 12.0, iOS 13.0, *)
        open var imageSymbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { mediaView.imageSymbolConfiguration }
            set { mediaView.imageSymbolConfiguration = newValue }
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

        /**
         Requests that the player seek to a specified time.

         - Parameters:
            - time: The time to which to seek.
            - tolerance: The tolerance.
            - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
                - finished: A Boolean value that indicates whether the seek operation completed.
         */
        open func seekVideo(to interval: TimeDuration, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
            mediaView.seekVideo(to: interval, tolerance: tolerance, completionHandler: completionHandler)
        }

        /**
         Requests that the player seek to a specified percentage.

         - Parameters:
            - percentage: The percentage to which to seek (between `0.0` and `1.0`).
            - tolerance: The tolerance.
            - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
                - finished: A Boolean value that indicates whether the seek operation completed.
         */
        open func seekVideo(toPercentage percentage: Double, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
            mediaView.seekVideo(toPercentage: percentage, tolerance: tolerance, completionHandler: completionHandler)
        }

        open var videoPlaybackTime: TimeDuration {
            get { mediaView.videoPlaybackTime }
            set { mediaView.videoPlaybackTime = newValue }
        }

        open var videoDuration: TimeDuration { mediaView.videoDuration }

        open var videoPlaybackPercentage: Double {
            get { mediaView.videoPlaybackPercentage }
            set { mediaView.videoPlaybackPercentage = newValue }
        }

        open var videoPlaybackHandler: ((TimeDuration) -> Void)? {
            get { mediaView.videoPlaybackHandler }
            set { mediaView.videoPlaybackHandler = newValue }
        }

        open override var menu: NSMenu? {
            get { mediaView.menu }
            set { mediaView.menu = newValue }
        }

        open var imageAnimationPlayback: ImageView.AnimationPlaybackOption {
            get { mediaView.imageAnimationPlayback }
            set { mediaView.imageAnimationPlayback = newValue }
        }
                
        open var isLooping: Bool {
            get { mediaView.isLooping }
            set { mediaView.isLooping = newValue }
        }

        open var videoViewControlStyle: AVPlayerViewControlsStyle {
            get { mediaView.videoViewControlStyle }
            set { mediaView.videoViewControlStyle = newValue }
        }

        open var mediaScaling: MediaView.MediaScaling {
            get { mediaView.mediaScaling }
            set { mediaView.mediaScaling = newValue }
        }

        open var mediaType: MediaView.MediaType? { mediaView.mediaType }

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

        open override var fittingSize: NSSize {
            mediaView.fittingSize
        }
        
        open override var intrinsicContentSize: NSSize {
            mediaView.intrinsicContentSize
        }
        
        open override var acceptsFirstResponder: Bool {
            true
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

        open override var enclosingScrollView: NSScrollView? {
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
        
        public init(asset: AVAsset) {
            super.init(frame: .zero)
            sharedInit()
            self.asset = asset
        }

        public override init(frame frameRect: NSRect) {
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

class MediaScrollView: FZScrollView {
    var mediaView: MediaView? {
        documentView as? MediaView
    }
    
    override func scrollWheel(with event: NSEvent) {
        if magnification == 1.0, let mediaView = mediaView, mediaView.mediaType == .video, (mediaView.isVolumeControllableByScrolling || mediaView.isPlaybackPositionControllableByScrolling) {
            mediaView.scrollWheel(with: event)
            /*
            let isMouse = event.phase.isEmpty
            let isTrackpadBegan = event.phase.contains(.began)
            let isTrackpadEnd = event.phase.contains(.ended)

            // determine direction

            if isMouse || isTrackpadBegan {
              if event.scrollingDeltaX != 0 {
                scrollDirection = .horizontal
              } else if event.scrollingDeltaY != 0 {
                scrollDirection = .vertical
              }
            } else if isTrackpadEnd {
              scrollDirection = nil
            }
            let isPrecise = event.hasPreciseScrollingDeltas
            let isNatural = event.isDirectionInvertedFromDevice

            var deltaX = isPrecise ? Double(event.scrollingDeltaX) : event.scrollingDeltaX.unifiedDouble
            var deltaY = isPrecise ? Double(event.scrollingDeltaY) : event.scrollingDeltaY.unifiedDouble * 2

            if isNatural {
              deltaY = -deltaY
            } else {
              deltaX = -deltaX
            }
            let delta = Float(scrollDirection == .horizontal ? deltaX : deltaY)
            let volume = Float(isMouse ? delta : volumeMap[volumeScrollAmount] * delta)
            let newVolume = (mediaView.volume + Float(isMouse ? (delta/100) : volumeMap[volumeScrollAmount] * (delta/100))).clamped(max: 1.0)
            let seconds = (isMouse ? seekAmountMapMouse : seekAmountMap)[3]*Double(delta)
            let newPlaybackPosition = mediaView.videoPlaybackTime + .seconds(seconds)
            Swift.print("scroll", volume, seconds, newVolume, newPlaybackPosition.seconds)
            if scrollDirection == .vertical, mediaView.isVolumeControllableByScrolling {
                Swift.print("volume", mediaView.volume, newVolume)
                mediaView.volume = newVolume
            } else if scrollDirection == .horizontal, mediaView.isPlaybackPositionControllableByScrolling {
                mediaView.seekVideo(to: newPlaybackPosition, tolerance: .zero)
                Swift.print("position", mediaView.videoPlaybackTime.seconds, newPlaybackPosition.seconds)
            }
             */
        } else {
            super.scrollWheel(with: event)
        }
    }
    
    enum ScrollDirection {
      case horizontal
      case vertical
    }
    var scrollDirection: ScrollDirection?
    let volumeMap: [Float] = [0, 0.25, 0.5, 0.75, 1]
    let seekAmountMap: [Double] = [0, 0.05, 0.1, 0.25, 0.5]
    let seekAmountMapMouse: [Double] = [0, 0.5, 1, 2, 4]

    let volumeScrollAmount = 3
    let relativeSeekAmount = 3

}

extension CGFloat {
    var unifiedDouble: Double {
        Double(copysign(1, self))
    }
}

#endif
