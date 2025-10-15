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
    let scrollView = AutosizingScrollView()
        
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
        self.mediaURL = mediaURL
        return self
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
        self.image = image
        return self
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
        self.images = images
        return self
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
        self.asset = asset
        return self
    }
        
    /// The handler that is called when the status of the media asset changes.
    open var assetStatusHandler: ((AVPlayerItem.Status)->())? {
        get { mediaView.assetStatusHandler }
        set { mediaView.assetStatusHandler = newValue }
    }
        
    /// Sets the handler that is called when the status of the media asset changes.
    @discardableResult
    open func assetStatusHandler(_ handler: ((AVPlayerItem.Status)->())?) -> Self {
        assetStatusHandler = handler
        return self
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
        self.mediaScaling = mediaScaling
        return self
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
        self.imageTintColor = imageTintColor
        return self
    }
        
    /// The symbol configuration of the image.
    @available(macOS 11.0, *)
    open var imageSymbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { mediaView.imageSymbolConfiguration }
        set { mediaView.imageSymbolConfiguration = newValue }
    }
        
    /// Sets the image symbol configuration.
    @available(macOS 11.0, *)
    @discardableResult
    open func imageSymbolConfiguration(_ symbolConfiguration: NSUIImage.SymbolConfiguration?) -> Self {
        imageSymbolConfiguration = symbolConfiguration
        return self
    }
        
    /// Sets the image symbol configuration.
    @available(macOS 12.0, *)
    @discardableResult
    open func imageSymbolConfiguration(_ symbolConfiguration: ImageSymbolConfiguration?) -> Self {
        imageSymbolConfiguration = symbolConfiguration?.nsSymbolConfiguration()
        return self
    }
        
    /// A Boolean value indicating whether media is looped.
    open var imageAnimationPlayback: ImageView.AnimationPlaybackOption {
        get { mediaView.imageAnimationPlayback }
        set { mediaView.imageAnimationPlayback = newValue }
    }
        
    /// Sets the playback behavior for animated images.
    @discardableResult
    open func imageAnimationPlayback(_ animationPlayback: ImageView.AnimationPlaybackOption) -> Self {
        imageAnimationPlayback = animationPlayback
        return self
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
        imageAnimationDuration = duration
        return self
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
        imageAnimationRepeatCount = repeatCount
        return self
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
        self.volume = volume
        return self
    }

    /// A Boolean value indicating whether media is muted.
    open var isMuted: Bool {
        get { mediaView.isMuted }
        set { mediaView.isMuted = newValue }
    }
        
    /// Sets the Boolean value indicating whether media is muted.
    @discardableResult
    open func isMuted(_ isMuted: Bool) -> Self {
        self.isMuted = isMuted
        return self
    }
        
    /// A Boolean value indicating whether media is looped.
    open var isLooping: Bool {
        get { mediaView.isLooping }
        set { mediaView.isLooping = newValue }
    }
        
    /// Sets the Boolean value indicating whether media is looped.
    @discardableResult
    open func isLooping(_ isLooping: Bool) -> Self {
        self.isLooping = isLooping
        return self
    }
        
    /// A value indicating whether the volume is controllable by scrolling up & down.
    open var volumeScrollControl: MediaView.VolumeScrollControl {
        get { mediaView.volumeScrollControl }
        set { mediaView.volumeScrollControl = newValue }
    }
        
    /// Sets the value indicating whether the volume is controllable by scrolling up & down.
    @discardableResult
    open func volumeScrollControl(_ volumeScrollControl: MediaView.VolumeScrollControl) -> Self {
        self.volumeScrollControl = volumeScrollControl
        return self
    }
        
    /// A value indicating whether the playback position is controllable by scrolling left & right.
    open var playbackPositionScrollControl: MediaView.PlaybackPositionScrollControl {
        get { mediaView.playbackPositionScrollControl }
        set { mediaView.playbackPositionScrollControl = newValue }
    }
        
    /// Sets the value indicating whether the playback position is controllable by scrolling left & right.
    @discardableResult
    open func playbackPositionScrollControl(_ playbackPositionScrollControl: MediaView.PlaybackPositionScrollControl) -> Self {
        self.playbackPositionScrollControl = playbackPositionScrollControl
        return self
    }
        
    /// The control style for videos.
    open var videoControlStyle: AVPlayerViewControlsStyle {
        get { mediaView.videoControlStyle }
        set { mediaView.videoControlStyle = newValue }
    }
        
    /// Sets the control style for videos.
    @discardableResult
    open func videoControlStyle(_ style: AVPlayerViewControlsStyle) -> Self {
        videoControlStyle = style
        return self
    }

    /// The playback option when loading new media.
    open var videoPlaybackOption: MediaView.VideoPlaybackOption {
        get { mediaView.videoPlaybackOption }
        set { mediaView.videoPlaybackOption = newValue }
    }
        
    /// The playback option when loading new media.
    @discardableResult
    open func videoPlaybackOption(_ option: MediaView.VideoPlaybackOption) -> Self {
        videoPlaybackOption = option
        return self
    }
        
    /// A Boolean value indicating whether right clicking toggles the playback between play and pause.
    open var togglePlaybackByRightClick: Bool {
        get { mediaView.togglePlaybackByRightClick }
        set { mediaView.togglePlaybackByRightClick = newValue }
    }
        
    /// Sets the Boolean value indicating whether right clicking toggles the playback between play and pause.
    @discardableResult
    open func togglePlaybackByRightClick(_ togglePlaybackByRightClick: Bool) -> Self {
        self.togglePlaybackByRightClick = togglePlaybackByRightClick
        return self
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
        self.playbackState = playbackState
        return self
    }

    /**
     Requests that the player seek to a specified time.

     - Parameters:
        - time: The time to which to seek.
        - tolerance: The tolerance.
        - completion: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value indicating whether the seek operation completed.
     */
    open func seekVideo(to interval: TimeDuration, tolerance: TimeDuration? = nil, completion: ((Bool) -> Void)? = nil) {
        mediaView.seekVideo(to: interval, tolerance: tolerance, completionHandler: completion)
    }

    /**
     Requests that the player seek to a specified percentage.

     - Parameters:
        - percentage: The percentage to which to seek (between `0.0` and `1.0`).
        - tolerance: The tolerance.
        - completion: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value indicating whether the seek operation completed.
     */
    open func seekVideo(toPercentage percentage: Double, tolerance: TimeDuration? = nil, completion: ((Bool) -> Void)? = nil) {
        mediaView.seekVideo(toPercentage: percentage, tolerance: tolerance, completionHandler: completion)
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
        self.videoPlaybackTime = videoPlaybackTime
        return self
    }

    /// The playback percentage of the current video (between `0` and `1.0`).
    open var videoPlaybackPercentage: Double {
        get { mediaView.videoPlaybackPercentage }
        set { mediaView.videoPlaybackPercentage = newValue }
    }
        
    /// Sets the playback percentage of the current video (between `0` and `1.0`).
    @discardableResult
    open func videoPlaybackPercentage(_ percentage: Double) -> Self {
        videoPlaybackPercentage = percentage
        return self
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
        playbackPositionHandler = handler
        return self
    }
        
    /// The time interval at which the system invokes the handler during normal playback, according to progress of the current playback position.
    open var playbackPositionHandlerInterval: TimeInterval {
        get { mediaView.playbackPositionHandlerInterval }
        set { mediaView.playbackPositionHandlerInterval = newValue }
    }
        
    // MARK: - Scroll

    /// A Boolean indicating whether the media view has scrollers.
    open var hasScrollers: Bool {
        get { scrollView.hasVerticalScroller }
        set {
            scrollView.hasVerticalScroller = newValue
            scrollView.hasHorizontalScroller = newValue
        }
    }
        
    /// Sets the Boolean indicating whether the media view has scrollers.
    @discardableResult
    open func hasScrollers(_ hasScrollers: Bool) -> Self {
        self.hasScrollers = hasScrollers
        return self
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
        self.scrollElasticity = scrollElasticity
        return self
    }

    /// A Boolean value indicating whether the user can magnify the media.
    open var allowsMagnification: Bool {
        get { scrollView.allowsMagnification }
        set { scrollView.allowsMagnification = newValue }
    }
        
    /// Sets the Boolean value indicating whether the user can magnify the media.
    @discardableResult
    open func allowsMagnification(_ allows: Bool) -> Self {
        allowsMagnification = allows
        return self
    }

    /// The amount by which the media is currently scaled.
    open var magnification: CGFloat {
        get { scrollView.magnification }
        set { setMagnification(newValue) }
    }
        
    /// Sets the amount by which the media is currently scaled.
    @discardableResult
    open func magnification(_ magnification: CGFloat) -> Self {
        self.magnification = magnification
        return self
    }
        
    /// The minimum value to which the content can be magnified.
    open var minMagnification: CGFloat {
        get { scrollView.minMagnification }
        set { scrollView.minMagnification = newValue }
    }
        
    /// Sets the minimum value to which the content can be magnified.
    @discardableResult
    open func minMagnification(_ minMagnification: CGFloat) -> Self {
        self.minMagnification = minMagnification
        return self
    }

    /// The maximum value to which the content can be magnified.
    open var maxMagnification: CGFloat {
        get { self.scrollView.maxMagnification }
        set { self.scrollView.maxMagnification = newValue }
    }
        
    /// Sets the maximum value to which the content can be magnified.
    @discardableResult
    open func maxMagnification(_ maxMagnification: CGFloat) -> Self {
        self.maxMagnification = maxMagnification
        return self
    }
        
    /**
     The amount by which to zoom the image when the user presses either the plus or minus key.
         
     Specify a value of `0.0` to disable zooming via keyboard.
     */
    open var keyDownZoomFactor: CGFloat? {
        get { scrollView.keyDownZoomFactor }
        set { scrollView.keyDownZoomFactor = newValue }
    }
        
    /// Sets the amount by which to zoom the image when the user presses either the plus or minus key.
    @discardableResult
    open func keyDownZoomFactor(_ zoomFactor: CGFloat?) -> Self {
        keyDownZoomFactor = zoomFactor
        return self
    }
        
    /**
     The amount by which to momentarily zoom the image when the user holds the space key.
         
     Specify a value of `0.0` to disable zooming via space key.
     */
    open var spaceKeyZoomFactor: CGFloat? {
        get { scrollView.spaceKeyZoomFactor }
        set { scrollView.spaceKeyZoomFactor = newValue }
    }
        
    /// Sets the amount by which to momentarily zoom the image when the user holds the space key.
    @discardableResult
    open func spaceKeyZoomFactor(_ zoomFactor: CGFloat?) -> Self {
        spaceKeyZoomFactor = zoomFactor
        return self
    }
        
    /**
     The amount by which to zoom the image when the user double clicks the view.
         
     Specify a value of `0.0` to disable zooming via mouse clicks.
     */
    open var mouseClickZoomFactor: CGFloat? {
        get { scrollView.mouseClickZoomFactor }
        set { scrollView.mouseClickZoomFactor = newValue }
    }
        
    /// Sets the amount by which to zoom the image when the user double clicks the view.
    @discardableResult
    open func mouseClickZoomFactor(_ zoomFactor: CGFloat?) -> Self {
        mouseClickZoomFactor = zoomFactor
        return self
    }
        
    /**
     Zooms in the image by the specified factor.
         
     - Parameters:
        - factor: The amount by which to zoom in the image.
        - point: The point on which to center magnification.
     */
    public func zoomIn(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil) {
        scrollView.animator(isProxy()).zoomIn(factor: factor, centeredAt: centeredAt)
    }

    /**
     Zooms out the image by the specified factor.
         
     - Parameters:
        - factor: The amount by which to zoom out the image.
        - point: The point on which to center magnification.
     */
    public func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil) {
        scrollView.animator(isProxy()).zoomOut(factor: factor, centeredAt: centeredAt)
    }

    /**
     Magnifies the content by the given amount and optionally centers the result on the given point.

     - Parameters:
        - magnification: The amount by which to magnify the content.
        - point: The point (in content view space) on which to center magnification, or `nil` if the magnification shouldn't be centered.
     */
    public func setMagnification(_ magnification: CGFloat, centeredAt: CGPoint? = nil) {
        if let centeredAt = centeredAt {
            scrollView.animator(isProxy()).setMagnification(magnification, centeredAt: centeredAt)
        } else {
            scrollView.animator(isProxy()).magnification = magnification
        }
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
        transitionAnimation = transition
        return self
    }
        
    /// The duration of the transition animation.
    open var transitionDuration: TimeInterval {
        get { mediaView.transitionDuration }
        set { mediaView.transitionDuration = newValue }
    }
        
    /// Sets the duration of the transition animation.
    @discardableResult
    open func transitionDuration(_ duration: TimeInterval) -> Self {
        transitionDuration = duration
        return self
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
      allowedMediaDroping = mediaTypes
      return self
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
        
    /// A Boolean value indicating whether the media is draggable outside.
    open var isDraggable: Bool = false
        
    /// Sets the Boolean value indicating whether the media is draggable outside.
    open func isDraggable(_ isDraggable: Bool) -> Self {
        self.isDraggable = isDraggable
        return self
    }
        
    private func sharedInit() {
        backgroundColor = .black
        mediaView.wantsLayer = true
        mediaView.frame = bounds
        scrollView.frame = bounds
        scrollView.documentView = mediaView
        addSubview(scrollView)
            
        dragHandlers.canDrag = { _ in
            guard self.isDraggable, let url = self.mediaURL else { return nil }
            return [url]
        }
    }
        
    open override var menu: NSMenu? {
        didSet { mediaView.menu = menu }
    }
}

#endif
