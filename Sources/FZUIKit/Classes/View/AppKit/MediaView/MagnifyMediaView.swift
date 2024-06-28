//
//  MagnifyMediaView.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
    import AppKit
    import AVKit
    import FZSwiftUtils

    /// A magnifiable view that displays media.
    open class MagnifyMediaView: NSView {
        
        let mediaView = MediaView()
        let scrollView = FZScrollView()
        
        /// The player for media assets.
        public var player: AVPlayer {
            mediaView.player
        }
        
        // MARK: - Media
        
        /// The url to the media displayed in the media view.
        open var mediaURL: URL? {
            get { mediaView.mediaURL }
            set {
                mediaView.mediaURL = newValue
                setMagnification(1.0)
            }
        }
        
        /// Sets the url to the media displayed in the media view.
        @discardableResult
        open func mediaURL(_ mediaURL: URL?) -> Self {
            set(\.mediaURL, to: mediaURL)
        }

        /// The image displayed in the media view.
        open var image: NSImage? {
            get { mediaView.image }
            set {
                mediaView.image = newValue
                setMagnification(1.0)
            }
        }
        
        /// Sets the image displayed in the media view.
        @discardableResult
        open func image(_ image: NSImage?) -> Self {
            set(\.image, to: image)
        }
        
        /// The images displayed in the media view.
        open var images: [NSImage] {
            get { mediaView.images }
            set {
                mediaView.images = newValue
                setMagnification(1.0)
            }
        }
        
        /// Sets the images displayed in the media view.
        @discardableResult
        open func images(_ images: [NSImage]) -> Self {
            set(\.images, to: images)
        }

        /// The media asset played by the media view.
        open var asset: AVAsset? {
            get { mediaView.asset }
            set {
                mediaView.asset = newValue
                //   scrollView.contentView.frame.size = bounds.size
                setMagnification(1.0)
            }
        }
        
        /// Sets the media asset played by the media view.
        @discardableResult
        open func asset(_ asset: AVAsset?) -> Self {
            set(\.asset, to: asset)
        }
        
        /// The handler that gets called when the status of the media asset changes.
        open var assetStatusHandler: ((AVPlayerItem.Status)->())? {
            get { mediaView.assetStatusHandler }
            set { mediaView.assetStatusHandler = newValue }
        }
        
        /// Sets the handler that gets called when the status of the media asset changes.
        @discardableResult
        open func assetStatusHandler(_ handler: ((AVPlayerItem.Status)->())?) -> Self {
            set(\.assetStatusHandler, to: handler)
        }
        
        /// The media type currently displayed.
        open var mediaType: MediaView.MediaType? {
            mediaView.mediaType
        }
        
        /// The current size and position of the media that displays within the media view’s bounds.
        public var mediaBounds: CGRect {
            mediaView.mediaBounds
        }
        
        /// The scaling of the media.
        open var mediaScaling: MediaView.MediaScaling {
            get { mediaView.mediaScaling }
            set { mediaView.mediaScaling = newValue }
        }
        
        /// Sets the scaling of the media.
        @discardableResult
        open func mediaScaling(_ mediaScaling: MediaView.MediaScaling) -> Self {
            set(\.mediaScaling, to: mediaScaling)
        }
        
        // MARK: - Image
        
        /// The image tint color for template and symbol images.
        open var imageTintColor: NSColor? {
            get { mediaView.imageTintColor }
            set { mediaView.imageTintColor = newValue }
        }
        
        /// Sets the image tint color for template and symbol images.
        @discardableResult
        open func imageTintColor(_ imageTintColor: NSColor?) -> Self {
            set(\.imageTintColor, to: imageTintColor)
        }
        
        /// The symbol configuration of the image.
        @available(macOS 12.0, iOS 13.0, *)
        open var imageSymbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { mediaView.imageSymbolConfiguration }
            set { mediaView.imageSymbolConfiguration = newValue }
        }
        
        /// Sets the image symbol configuration.
        @available(macOS 12.0, iOS 13.0, *)
        @discardableResult
        open func imageSymbolConfiguration(_ symbolConfiguration: NSUIImage.SymbolConfiguration?) -> Self {
            set(\.imageSymbolConfiguration, to: symbolConfiguration)
        }
        
        /// A Boolean value that indicates whether media is looped.
        open var imageAnimationPlayback: ImageView.AnimationPlaybackOption {
            get { mediaView.imageAnimationPlayback }
            set { mediaView.imageAnimationPlayback = newValue }
        }
        
        /// Sets the playback behavior for animated images.
        @discardableResult
        open func imageAnimationPlayback(_ animationPlayback: ImageView.AnimationPlaybackOption) -> Self {
            set(\.imageAnimationPlayback, to: animationPlayback)
        }
        
        /**
         The amount of time it takes to go through one cycle of an animated image.

         The time duration is measured in seconds. The default value of this property is `0.0`, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
         */
        open var imageAnimationDuration: TimeInterval {
            get { mediaView.imageAnimationDuration }
            set { mediaView.imageAnimationDuration = newValue }
        }
        
        /// Sets the amount of time it takes to go through one cycle of an animated image.
        @discardableResult
        open func imageAnimationDuration(_ duration: TimeInterval) -> Self {
            set(\.imageAnimationDuration, to: duration)
        }
        
        /**
         Specifies the number of times to repeat animated images.

         The default value is `0`, which specifies to repeat the animation indefinitely.
         */
        open var imageAnimationRepeatCount: Int {
            get { mediaView.imageAnimationRepeatCount }
            set { mediaView.imageAnimationRepeatCount = newValue }
        }
        
        /// Sets the number of times to repeat animated images.
        @discardableResult
        open func imageAnimationRepeatCount(_ repeatCount: Int) -> Self {
            set(\.imageAnimationRepeatCount, to: repeatCount)
        }
        
        // MARK: - Video
        
        /// The volume of the media.
       @objc dynamic open var volume: CGFloat {
            get { mediaView.volume }
            set { mediaView.volume = newValue }
        }
        
        /// Sets the volume of the media.
        @discardableResult
        open func volume(_ volume: CGFloat) -> Self {
            set(\.volume, to: volume)
        }

        /// A Boolean value indicating whether media is muted.
        open var isMuted: Bool {
            get { mediaView.isMuted }
            set { mediaView.isMuted = newValue }
        }
        
        /// Sets the Boolean value that indicates whether media is muted.
        @discardableResult
        open func isMuted(_ isMuted: Bool) -> Self {
            set(\.isMuted, to: isMuted)
        }
        
        /// A Boolean value that indicates whether media is looped.
        open var isLooping: Bool {
            get { mediaView.isLooping }
            set { mediaView.isLooping = newValue }
        }
        
        /// Sets the Boolean value that indicates whether media is looped.
        @discardableResult
        open func isLooping(_ isLooping: Bool) -> Self {
            set(\.isLooping, to: isLooping)
        }
        
        /// A value that indicates whether the volume is controllable by scrolling up & down.
        open var volumeScrollControl: MediaView.VolumeScrollControl {
            get { mediaView.volumeScrollControl }
            set { mediaView.volumeScrollControl = newValue }
        }
        
        /// Sets the value that indicates whether the volume is controllable by scrolling up & down.
        @discardableResult
        open func volumeScrollControl(_ volumeScrollControl: MediaView.VolumeScrollControl) -> Self {
            set(\.volumeScrollControl, to: volumeScrollControl)
        }
        
        /// A value that indicates whether the playback position is controllable by scrolling left & right.
        open var playbackPositionScrollControl: MediaView.PlaybackPositionScrollControl {
            get { mediaView.playbackPositionScrollControl }
            set { mediaView.playbackPositionScrollControl = newValue }
        }
        
        /// Sets the value that indicates whether the playback position is controllable by scrolling left & right.
        @discardableResult
        open func playbackPositionScrollControl(_ playbackPositionScrollControl: MediaView.PlaybackPositionScrollControl) -> Self {
            set(\.playbackPositionScrollControl, to: playbackPositionScrollControl)
        }
        
        /// The control style for videos.
        open var videoControlStyle: AVPlayerViewControlsStyle {
            get { mediaView.videoControlStyle }
            set { mediaView.videoControlStyle = newValue }
        }
        
        /// Sets the control style for videos.
        @discardableResult
        open func videoControlStyle(_ style: AVPlayerViewControlsStyle) -> Self {
            set(\.videoControlStyle, to: style)
        }

        /// The playback option when loading new media.
        open var videoPlaybackOption: MediaView.VideoPlaybackOption {
            get { mediaView.videoPlaybackOption }
            set { mediaView.videoPlaybackOption = newValue }
        }
        
        /// The playback option when loading new media.
        @discardableResult
        open func videoPlaybackOption(_ option: MediaView.VideoPlaybackOption) -> Self {
            set(\.videoPlaybackOption, to: option)
        }
        
        /// A Boolean value that indicates whether right clicking toggles the playback between play and pause.
        open var togglePlaybackByRightClick: Bool {
            get { mediaView.togglePlaybackByRightClick }
            set { mediaView.togglePlaybackByRightClick = newValue }
        }
        
        /// Sets the Boolean value that indicates whether right clicking toggles the playback between play and pause.
        @discardableResult
        open func togglePlaybackByRightClick(_ togglePlaybackByRightClick: Bool) -> Self {
            set(\.togglePlaybackByRightClick, to: togglePlaybackByRightClick)
        }
        
        // MARK: - Playback
        
        /// Starts playback of the media.
        open func play() {
            mediaView.play()
        }

        /// Pauses playback of the media.
        open func pause() {
            mediaView.pause()
        }

        /// Stops playback of the media.
        open func stop() {
            mediaView.stop()
        }

        /// Toggles the playback between play and pause.
        open func togglePlayback() {
            mediaView.togglePlayback()
        }
        
        /// The playback state of the displayed media.
        open var playbackState: MediaView.PlaybackState {
            get { mediaView.playbackState }
            set { mediaView.playbackState = newValue }
        }
        
        /// Sets the playback state of the displayed media.
        @discardableResult
        open func playbackState(_ playbackState: MediaView.PlaybackState) -> Self {
            set(\.playbackState, to: playbackState)
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
        
        /// The duration of the current video.
        open var videoDuration: TimeDuration { mediaView.videoDuration }

        /// The playback time of the current video.
        open var videoPlaybackTime: TimeDuration {
            get { mediaView.videoPlaybackTime }
            set { mediaView.videoPlaybackTime = newValue }
        }
        
        /// Sets the playback time of the current video.
        @discardableResult
        open func videoPlaybackTime(_ videoPlaybackTime: TimeDuration) -> Self {
            set(\.videoPlaybackTime, to: videoPlaybackTime)
        }

        /// The playback percentage of the current video (between `0` and `1.0`).
        open var videoPlaybackPercentage: Double {
            get { mediaView.videoPlaybackPercentage }
            set { mediaView.videoPlaybackPercentage = newValue }
        }
        
        /// Sets the playback percentage of the current video (between `0` and `1.0`).
        @discardableResult
        open func videoPlaybackPercentage(_ percentage: Double) -> Self {
            set(\.videoPlaybackPercentage, to: percentage)
        }
        
        /// The handler that is called whenever the playback reached to the end time.
        open var playbackReachedEndHandler: (() -> Void)? {
            get { mediaView.playbackReachedEndHandler }
            set { mediaView.playbackReachedEndHandler = newValue }
        }

        /// The handler that is called whenever the playback position changes.
        open var playbackPositionHandler: ((TimeDuration) -> Void)? {
            get { mediaView.playbackPositionHandler }
            set { mediaView.playbackPositionHandler = newValue }
        }
        
        /// Sets the handler that is called whenever the playback position changes.
        @discardableResult
        open func playbackPositionHandler(_ handler: ((TimeDuration) -> Void)?) -> Self {
            set(\.playbackPositionHandler, to: handler)
        }
        
        /// The time interval at which the system invokes the handler during normal playback, according to progress of the current playback position.
        open var playbackPositionHandlerInterval: TimeInterval {
            get { mediaView.playbackPositionHandlerInterval }
            set { mediaView.playbackPositionHandlerInterval = newValue }
        }
        
        // MARK: - Scroll

        /// A Boolean that indicates whether the media view has scrollers.
        open var hasScrollers: Bool {
            get { scrollView.hasVerticalScroller }
            set {
                scrollView.hasVerticalScroller = newValue
                scrollView.hasHorizontalScroller = newValue
            }
        }
        
        /// Sets the Boolean that indicates whether the media view has scrollers.
        @discardableResult
        open func hasScrollers(_ hasScrollers: Bool) -> Self {
            set(\.hasScrollers, to: hasScrollers)
        }

        /// The scrolling elasticity mode.
        open var scrollElasticity: NSScrollView.Elasticity {
            get { scrollView.verticalScrollElasticity }
            set {
                scrollView.verticalScrollElasticity = newValue
                scrollView.horizontalScrollElasticity = newValue
            }
        }
        
        /// Sets the scrolling elasticity mode.
        @discardableResult
        open func scrollElasticity(_ scrollElasticity: NSScrollView.Elasticity) -> Self {
            set(\.scrollElasticity, to: scrollElasticity)
        }

        /// A Boolean value indicating whether the user can magnify the media.
        open var allowsMagnification: Bool {
            get { scrollView.allowsMagnification }
            set { scrollView.allowsMagnification = newValue }
        }
        
        /// Sets the Boolean value indicating whether the user can magnify the media.
        @discardableResult
        open func allowsMagnification(_ allows: Bool) -> Self {
            set(\.allowsMagnification, to: allows)
        }

        /// The amount by which the media is currently scaled.
        open var magnification: CGFloat {
            get { scrollView.magnification }
            set { setMagnification(newValue) }
        }
        
        /// Sets the amount by which the media is currently scaled.
        @discardableResult
        open func magnification(_ magnification: CGFloat) -> Self {
            set(\.magnification, to: magnification)
        }
        
        /// The minimum value to which the content can be magnified.
        open var minMagnification: CGFloat {
            get { scrollView.minMagnification }
            set { scrollView.minMagnification = newValue }
        }
        
        /// Sets the minimum value to which the content can be magnified.
        @discardableResult
        open func minMagnification(_ minMagnification: CGFloat) -> Self {
            set(\.minMagnification, to: minMagnification)
        }

        /// The maximum value to which the content can be magnified.
        open var maxMagnification: CGFloat {
            get { self.scrollView.maxMagnification }
            set { self.scrollView.maxMagnification = newValue }
        }
        
        /// Sets the maximum value to which the content can be magnified.
        @discardableResult
        open func maxMagnification(_ maxMagnification: CGFloat) -> Self {
            set(\.maxMagnification, to: maxMagnification)
        }
        
        /**
         The amount by which to zoom the image when the user presses either the plus or minus key.
         
         Specify a value of `0.0` to disable zooming via keyboard.
         */
        open var keyDownZoomFactor: CGFloat {
            get { scrollView.keyDownZoomFactor }
            set { scrollView.keyDownZoomFactor = newValue }
        }
        
        /// Sets the amount by which to zoom the image when the user presses either the plus or minus key.
        @discardableResult
        open func keyDownZoomFactor(_ zoomFactor: CGFloat) -> Self {
            set(\.keyDownZoomFactor, to: zoomFactor)
        }
        
        /**
         The amount by which to momentarily zoom the image when the user holds the space key.
         
         Specify a value of `0.0` to disable zooming via space key.
         */
        open var spaceKeyZoomFactor: CGFloat {
            get { scrollView.spaceKeyZoomFactor }
            set { scrollView.spaceKeyZoomFactor = newValue }
        }
        
        /// Sets the amount by which to momentarily zoom the image when the user holds the space key.
        @discardableResult
        open func spaceKeyZoomFactor(_ zoomFactor: CGFloat) -> Self {
            set(\.spaceKeyZoomFactor, to: zoomFactor)
        }
        
        /**
         The amount by which to zoom the image when the user double clicks the view.
         
         Specify a value of `0.0` to disable zooming via mouse clicks.
         */
        open var mouseClickZoomFactor: CGFloat {
            get { scrollView.mouseClickZoomFactor }
            set { scrollView.mouseClickZoomFactor = newValue }
        }
        
        /// Sets the amount by which to zoom the image when the user double clicks the view.
        @discardableResult
        open func mouseClickZoomFactor(_ zoomFactor: CGFloat) -> Self {
            set(\.mouseClickZoomFactor, to: zoomFactor)
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

        open override var enclosingScrollView: NSScrollView? {
            scrollView
        }
        
        // MARK: - Transition
        
        /// The transition animation when changing the displayed image.
        open var transitionAnimation: MediaView.TransitionAnimation {
            get { mediaView.transitionAnimation }
            set { mediaView.transitionAnimation = newValue }
        }
        
        /// Sets the transition animation when changing the displayed media.
        @discardableResult
        open func transitionAnimation(_ transition: MediaView.TransitionAnimation) -> Self {
            set(\.transitionAnimation, to: transition)
        }
        
        /// The duration of the transition animation.
        open var transitionDuration: TimeInterval {
            get { mediaView.transitionDuration }
            set { mediaView.transitionDuration = newValue }
        }
        
        /// Sets the duration of the transition animation.
        @discardableResult
        open func transitionDuration(_ duration: TimeInterval) -> Self {
            set(\.transitionDuration, to: duration)
        }
        
        /*
        // MARK: - Media Drop
        
        /**
         The media types that the user can drop to the media view.
         
         If the user drops any of the specified media types to the view, the action is called.
         */
        open var allowedMediaDroping: [MediaView.MediaType] {
            get { mediaView.allowedMediaDroping }
            set { mediaView.allowedMediaDroping = newValue }
        }
        
        /**
         Sets the media types that the user can drop to the media view.
         
         If the user drops any of the specified media types to the view, the action is called.
         */
        @discardableResult
        open func allowedMediaDroping(_ mediaTypes: [MediaView.MediaType]) -> Self {
            set(\.allowedMediaDroping, to: mediaTypes)
        }
         */
        
        // MARK: - Layout
        
        /// A view for hosting layered content on top of the media view.
        open var overlayContentView: NSView {
            mediaView.overlayContentView
        }

        open override var fittingSize: NSSize {
            mediaView.fittingSize
        }
        
        open override var intrinsicContentSize: NSSize {
            mediaView.intrinsicContentSize
        }

        open func sizeToFit() {
            frame.size = fittingSize
        }
        
        open override func layout() {
            super.layout()
            scrollView.frame = bounds
        }
        
        // MARK: - Init

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
        
        open override var menu: NSMenu? {
            didSet { mediaView.menu = menu }
        }
    }

#endif
