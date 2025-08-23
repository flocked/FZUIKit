//
//  MediaView.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
import AppKit
import AVKit
import FZSwiftUtils

/// A view that displays media.
open class MediaView: NSControl {
                                
    public let imageView = ImageView().isHidden(true)
    public let videoView = ScrollPlayerView().isHidden(true)
    /// The player for media assets.
    public let player = AVPlayer()
    private var playbackObserver: AVPlayerTimeObservation?
    private var previousVideoPlaybackState: AVPlayer.State = .isStopped
    private var _mediaURL: URL?

    /// Media type.
    public enum MediaType {
        /// Video.
        case video
        /// Image.
        case image
        /// GIF.
        case gif
            
        var fileType: FileType {
            switch self {
            case .video: return .video
            case .image: return .image
            case .gif: return .gif
            }
        }
    }
        
    /// The scaling of the media.
    public enum MediaScaling: Int {
        /// The media is resized to fit the bounds rectangle, preserving the aspect of the image.
        case scaleToFit
        /// The media is resized to completely fill the bounds rectangle, while still preserving the aspect of the image.
        case scaleToFill
        /// The media is resized to fit the entire bounds rectangle.
        case resize
        /// The media isn't resized.
        case none
            
        var imageScaling: ImageView.ImageScaling {
            ImageView.ImageScaling(rawValue: rawValue)!
        }
        var videoGravity: AVLayerVideoGravity {
            switch self {
            case .scaleToFit: return .resizeAspect
            case .resize: return .resize
            default: return .resizeAspectFill
            }
        }
    }
        
    // MARK: - Media
        
    /// The url to the media displayed in the media view.
    open var mediaURL: URL? {
        get { _mediaURL }
        set {
            pause()
            if let mediaURL = newValue {
                if mediaURL.fileType == .video {
                    setupAsset(AVAsset(url: mediaURL))
                    _mediaURL = newValue
                } else if mediaURL.fileType == .image || mediaURL.fileType == .gif, let image = NSImage(contentsOf: mediaURL) {
                    self.image = image
                    _mediaURL = newValue
                } else {
                    _mediaURL = nil
                    hideImageView()
                    hideVideoView()
                }
            } else {
                _mediaURL = nil
                hideImageView()
                hideVideoView()
            }
            invalidateIntrinsicContentSize()
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
        get { imageView.image }
        set {
            if let transition = transitionAnimation.transition(transitionDuration) {
                self.transition(transition)
            }
            imageView.image = newValue
            if newValue != nil {
                _mediaURL = nil
                showImageView()
            } else if mediaType == .image {
                hideImageView()
            }
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
        get { imageView.images }
        set {
            if let transition = transitionAnimation.transition(transitionDuration) {
                self.transition(transition)
            }
            imageView.images = newValue
            if newValue.isEmpty == false {
                _mediaURL = nil
                showImageView()
            } else if mediaType == .image {
                hideImageView()
            }
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
        get { player.currentItem?.asset }
        set {
            setupAsset(newValue)
            _mediaURL = (asset as? AVURLAsset)?.url
        }
    }
        
    /// Sets the media asset played by the media view.
    @discardableResult
    open func asset(_ asset: AVAsset?) -> Self {
        self.asset = asset
        return self
    }
        
    private func setupAsset(_ asset: AVAsset?) {
        if let transition = transitionAnimation.transition(transitionDuration) {
            self.transition(transition)
        }
        if let asset = asset {
            updatePreviousPlaybackState()
            player.pause()
            let item = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: item)
            setupAssetStatusHandler()
            showVideoView()
            if videoPlaybackOption == .autostart || (videoPlaybackOption == .previousPlaybackState && previousVideoPlaybackState == .isPlaying) {
                player.play()
            } else {
                player.pause()
            }
        } else if mediaType == .video {
            hideVideoView()
            _mediaURL = nil
        }
    }
        
    /// The handler that is called when the status of the media asset changes.
    open var assetStatusHandler: ((AVPlayerItem.Status)->())? = nil {
        didSet { setupAssetStatusHandler() }
    }
        
    /// Sets the handler that is called when the status of the media asset changes.
    @discardableResult
    open func assetStatusHandler(_ handler: ((AVPlayerItem.Status)->())?) -> Self {
        assetStatusHandler = handler
        return self
    }
        
    func setupAssetStatusHandler() {
        if let item = player.currentItem {
            if item.status == .readyToPlay {
                self.assetStatusHandler?(.readyToPlay)
            } else {
                item.handlers.status = { [weak self] status in
                    guard let self = self else { return }
                    self.assetStatusHandler?(status)
                }
            }
        }
    }
        
    var assetStatusObservation: KeyValueObservation?
        
    /// The media type currently displayed.
    open var mediaType: MediaType? {
        if !videoView.isHidden {
            return .video
        } else if !imageView.isHidden {
            return imageView.isAnimatable ? .gif : .image
        }
        return nil
    }
        
    /// The current size and position of the media that displays within the media view’s bounds.
    open var mediaBounds: CGRect {
        switch mediaType {
        case .video:
            return videoView.videoBounds
        case .image, .gif:
            return imageView.imageBounds
        case nil:
            return .zero
        }
    }
        
    /// The scaling of the media.
    open var mediaScaling: MediaScaling = .scaleToFit {
        didSet {
            imageView.imageScaling = mediaScaling.imageScaling
            videoView.videoGravity = mediaScaling.videoGravity
        }
    }
        
    /// Sets the scaling of the media.
    @discardableResult
    open func mediaScaling(_ mediaScaling: MediaScaling) -> Self {
        self.mediaScaling = mediaScaling
        return self
    }
        
    // MARK: - Image
        
    /// The image tint color for template and symbol images.
    open var imageTintColor: NSColor? {
        get { imageView.tintColor }
        set { imageView.tintColor = newValue }
    }
        
    /// Sets the image tint color for template and symbol images.
    @discardableResult
    open func imageTintColor(_ imageTintColor: NSColor?) -> Self {
        self.imageTintColor = imageTintColor
        return self
    }
        
    /// The image symbol configuration.
    @available(macOS 11.0, *)
    open var imageSymbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { imageView.symbolConfiguration }
        set { imageView.symbolConfiguration = newValue }
    }
        
    /// Sets the image symbol configuration.
    @available(macOS 11.0, *)
    @discardableResult
    open func imageSymbolConfiguration(_ symbolConfiguration: NSUIImage.SymbolConfiguration?) -> Self {
        self.imageSymbolConfiguration = symbolConfiguration
        return self
    }
        
    /// Sets the image symbol configuration.
    @available(macOS 12.0, *)
    @discardableResult
    open func imageSymbolConfiguration(_ symbolConfiguration: ImageSymbolConfiguration?) -> Self {
        self.imageSymbolConfiguration = symbolConfiguration?.nsSymbolConfiguration()
        return self
    }
        
    /// The playback behavior for animated images.
    open var imageAnimationPlayback: ImageView.AnimationPlaybackOption {
        get { imageView.animationPlayback }
        set { imageView.animationPlayback = newValue }
    }
        
    /// Sets the playback behavior for animated images.
    @discardableResult
    open func imageAnimationPlayback(_ animationPlayback: ImageView.AnimationPlaybackOption) -> Self {
        self.imageAnimationPlayback = animationPlayback
        return self
    }

    /**
     The amount of time it takes to go through one cycle of an animated image.

     The time duration is measured in seconds. The default value of this property is `0.0`, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
     */
    open var imageAnimationDuration: TimeInterval {
        get { imageView.animationDuration }
        set { imageView.animationDuration = newValue }
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
        get { imageView.animationRepeatCount }
        set { imageView.animationRepeatCount = newValue }
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
        get { CGFloat(player.volume) }
        set { player.volume = Float(newValue) }
    }
        
    /// Sets the volume of the media.
    @discardableResult
    open func volume(_ volume: CGFloat) -> Self {
        self.volume = volume
        return self
    }
        
    /// A Boolean value indicating whether media is muted.
    open var isMuted: Bool {
        get { player.isMuted }
        set { player.isMuted = newValue }
    }
        
    /// Sets the Boolean value indicating whether media is muted.
    @discardableResult
    open func isMuted(_ isMuted: Bool) -> Self {
        self.isMuted = isMuted
        return self
    }

    /// A Boolean value indicating whether media is looped.
    open var isLooping: Bool {
        get { player.isLooping }
        set { player.isLooping = newValue }
    }
        
    /// Sets the Boolean value indicating whether media is looped.
    @discardableResult
    open func isLooping(_ isLooping: Bool) -> Self {
        self.isLooping = isLooping
        return self
    }

    /// A value indicating whether the volume is controllable by scrolling up & down.
    open var volumeScrollControl: VolumeScrollControl {
        get { .init(rawValue: videoView.volumeScrollControl.rawValue)! }
        set { videoView.volumeScrollControl = .init(rawValue: newValue.rawValue)! }
    }
        
    /// Sets the value indicating whether the volume is controllable by scrolling up & down.
    @discardableResult
    open func volumeScrollControl(_ volumeScrollControl: VolumeScrollControl) -> Self {
        self.volumeScrollControl = volumeScrollControl
        return self
    }
        
    /// The value indicating whether the volume is controllable by scrolling up & down.
    public enum VolumeScrollControl: Int {
        /// Scrolling doesn't change the volume.
        case off = 0
        /// Scrolling changes the volume slowly.
        case slow = 1
        /// Scrolling changes the volume.
        case normal = 2
        /// Scrolling changes the volume fastly.
        case fast = 3
            
        var value: Double {
            [0.0, 0.25, 0.5, 0.75][rawValue]
        }
    }
        
    /// A value indicating whether the playback position is controllable by scrolling left & right.
    open var playbackPositionScrollControl: PlaybackPositionScrollControl {
        get { .init(rawValue: videoView.playbackPositionScrollControl.rawValue)! }
        set { videoView.playbackPositionScrollControl = .init(rawValue: newValue.rawValue)! }
    }
        
    /// Sets the value indicating whether the playback position is controllable by scrolling left & right.
    @discardableResult
    open func playbackPositionScrollControl(_ playbackPositionScrollControl: PlaybackPositionScrollControl) -> Self {
        self.playbackPositionScrollControl = playbackPositionScrollControl
        return self
    }

    /// The value indicating whether the playback position is controllable by scrolling left & right.
    public enum PlaybackPositionScrollControl: Int {
        /// Scrolling doesn't change the playback position.
        case off = 0
        /// Scrolling changes the playback position slowly.
        case slow = 1
        /// Scrolling changes the playback position.
        case normal = 2
        /// Scrolling changes the playback position fastly.
        case fast = 3
            
        func value(isMouse: Bool) -> Double {
            (isMouse ? [0, 1, 2, 4] : [0.0, 0.1, 0.25, 0.5])[rawValue]
        }
    }
        
    /// The control style for videos.
    open var videoControlStyle: AVPlayerViewControlsStyle  {
        get { videoView.controlsStyle }
        set { videoView.controlsStyle = newValue }
    }
        
    /// Sets the control style for videos.
    @discardableResult
    open func videoControlStyle(_ style: AVPlayerViewControlsStyle) -> Self {
        videoControlStyle = style
        return self
    }
        
    /// The playback option when loading new media.
    open var videoPlaybackOption: VideoPlaybackOption = .autostart
        
    /// The playback option when loading new media.
    @discardableResult
    open func videoPlaybackOption(_ option: VideoPlaybackOption) -> Self {
        videoPlaybackOption = option
        return self
    }
        
    /// Playback option when loading a new video.
    public enum VideoPlaybackOption: Int, Hashable {
        /// The video automatically starts playing.
        case autostart
        /// The video keeps the previous playback state.
        case previousPlaybackState
        /// The video is paused.
        case pause
    }
        
    /// A Boolean value indicating whether right clicking toggles the playback between play and pause.
    open var togglePlaybackByRightClick: Bool {
        get { videoView.togglePlaybackByRightClick }
        set { videoView.togglePlaybackByRightClick = newValue }
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
        imageView.startAnimating()
        player.play()
    }

    /// Pauses playback of the media.
    open func pause() {
        imageView.pauseAnimating()
        player.pause()
    }

    /// Stops playback of the media.
    open func stop() {
        imageView.stopAnimating()
        player.stop()
    }

    /// Toggles the playback between play and pause.
    open func togglePlayback() {
        imageView.toggleAnimating()
        player.togglePlayback()
    }
        
    /// The playback state of the displayed media.
    open var playbackState: PlaybackState {
        get {
            switch mediaType {
            case .video:
                switch player.state {
                case .isPlaying: return .isPlaying
                case .isPaused: return .isPaused
                default: return .isStopped
                }
            case .image, .gif:
                return .init(rawValue: imageView.animationPlaybackState.rawValue)!
            case nil:
                return .isStopped
            }
        }
        set {
            guard mediaType != nil else { return }
            switch newValue {
            case .isPlaying: play()
            case .isPaused: pause()
            case .isStopped: stop()
            }
        }
    }
        
    /// Sets the playback state of the displayed media.
    @discardableResult
    open func playbackState(_ playbackState: PlaybackState) -> Self {
        self.playbackState = playbackState
        return self
    }
        
    /// The media playback state.
    public enum PlaybackState: Int {
        /// Is playing.
        case isPlaying
        /// Is paused.
        case isPaused
        /// Is stopped.
        case isStopped
    }

    /**
     Requests that the player seek to a specified time.

     - Parameters:
        - time: The time to which to seek.
        - tolerance: The tolerance.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value indicating whether the seek operation completed.
     */
    open func seekVideo(to interval: TimeDuration, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        player.seek(to: interval, tolerance: tolerance, completionHandler: completionHandler)
    }

    /**
     Requests that the player seek to a specified percentage.

     - Parameters:
        - percentage: The percentage to which to seek (between `0.0` and `1.0`).
        - tolerance: The tolerance.
        - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
            - finished: A Boolean value indicating whether the seek operation completed.
     */
    open func seekVideo(toPercentage percentage: Double, tolerance: TimeDuration? = nil, completionHandler: ((Bool) -> Void)? = nil) {
        player.seek(toPercentage: percentage, tolerance: tolerance, completionHandler: completionHandler)
    }

    /// The duration of the current video.
    open var videoDuration: TimeDuration {
        player.duration
    }
        
    /// The playback time of the current video.
    open var videoPlaybackTime: TimeDuration {
        get { player.currentTimeDuration }
        set { player.currentTimeDuration = newValue }
    }
        
    /// Sets the playback time of the current video.
    @discardableResult
    open func videoPlaybackTime(_ videoPlaybackTime: TimeDuration) -> Self {
        self.videoPlaybackTime = videoPlaybackTime
        return self
    }

    /// The playback percentage of the current video (between `0` and `1.0`).
    open var videoPlaybackPercentage: Double {
        get { player.playbackPercentage }
        set { player.playbackPercentage = newValue }
    }
        
    /// Sets the playback percentage of the current video (between `0` and `1.0`).
    @discardableResult
    open func videoPlaybackPercentage(_ percentage: Double) -> Self {
        self.videoPlaybackPercentage = percentage
        return self
    }
        
    /// The handler that is called whenever the playback reached to the end time.
    open var playbackReachedEndHandler: (() -> Void)? {
        didSet { player.itemHandlers.playedToEnd = playbackReachedEndHandler }
    }

    /// The handler that is called whenever the playback position changes.
    open var playbackPositionHandler: ((TimeDuration) -> Void)? {
        didSet { setupPlaybackHandler() }
    }
        
    /// Sets the handler that is called whenever the playback position changes.
    @discardableResult
    open func playbackPositionHandler(_ handler: ((TimeDuration) -> Void)?) -> Self {
        self.playbackPositionHandler = handler
        return self
    }
        
    /// The time interval at which the system invokes the handler during normal playback, according to progress of the current playback position.
    open var playbackPositionHandlerInterval: TimeInterval = 0.1 {
        didSet {
            guard oldValue != playbackPositionHandlerInterval else { return }
            setupPlaybackHandler()
        }
    }
        
    // MARK: - Transition
        
    /// The transition animation when changing the displayed image.
    open var transitionAnimation: TransitionAnimation = .none
        
    /// Sets the transition animation when changing the displayed media.
    @discardableResult
    open func transitionAnimation(_ transition: TransitionAnimation) -> Self {
        transitionAnimation = transition
        return self
    }
        
    /// The duration of the transition animation.
    open var transitionDuration: TimeInterval = 0.2
        
    /// Sets the duration of the transition animation.
    @discardableResult
    open func transitionDuration(_ duration: TimeInterval) -> Self {
        self.transitionDuration = duration
        return self
    }
        
    /// Constants that specify the transition animation when changing between displayed media.
    public enum TransitionAnimation: Hashable, CustomStringConvertible {
        /// No transition animation.
        case none
        /// The new media fades in.
        case fade
        /// The new media slides into place over any existing media from the specified direction.
        case moveIn(_ direction: Direction = .fromLeft)
        /// The new media pushes any existing media as it slides into place from the specified direction.
        case push(_ direction: Direction = .fromLeft)
        /// The new media is revealed gradually in the specified direction.
        case reveal(_ direction: Direction = .fromLeft)
            
        /// The direction of the transition.
        public enum Direction: String, Hashable {
            /// From left.
            case fromLeft
            /// From right.
            case fromRight
            /// From bottom.
            case fromBottom
            /// From top.
            case fromTop
            var subtype: CATransitionSubtype {
                CATransitionSubtype(rawValue: rawValue)
            }
        }
            
        public var description: String {
            switch self {
            case .none: return "TransitionAnimation.none"
            case .fade: return "TransitionAnimation.fade"
            case .moveIn(let direction): return "TransitionAnimation.moveIn(\(direction.rawValue))"
            case .push(let direction): return "TransitionAnimation.push(\(direction.rawValue))"
            case .reveal(let direction): return "TransitionAnimation.reveal(\(direction.rawValue))"
            }
        }
            
        var type: CATransitionType? {
            switch self {
            case .fade: return .fade
            case .moveIn: return .moveIn
            case .push: return .push
            case .reveal: return .reveal
            case .none: return nil
            }
        }
            
        var subtype: CATransitionSubtype? {
            switch self {
            case .moveIn(let direction), .push(let direction), .reveal(let direction):
                return direction.subtype
            default: return nil
            }
        }
            
        func transition(_ duration: TimeInterval) -> CATransition? {
            guard let type = type else { return nil }
            return CATransition(type, subtype: subtype, duration: duration)
        }
    }
        
    /*
        
     // MARK: - Media Drop
        
     /**
      The media types that the user can drop to the media view.
         
      If the user drops any of the specified media types to the view, the action is called.
      */
     open var allowedMediaDroping: [MediaType]  = [] {
         didSet {
             guard oldValue != allowedMediaDroping else { return }
             if allowedMediaDroping.isEmpty {
                 overlayContentView.dropHandlers.canDrop = nil
                 overlayContentView.dropHandlers.didDrop = nil
             } else if overlayContentView.dropHandlers.canDrop == nil {
                 overlayContentView.dropHandlers.canDrop = { [weak self] contents,_,_ in
                     guard let self = self else { return false }
                     let content = self.processPasteboard(contents)
                     return content.image != nil || content.fileURL != nil
                 }
                 overlayContentView.dropHandlers.didDrop = { [weak self] contents,_,_ in
                     guard let self = self else { return }
                     let content = self.processPasteboard(contents)
                     if let image = content.image {
                         self.image = image
                         self.performAction()
                     } else if let fileURL = content.fileURL {
                         self.mediaURL = fileURL
                         if self.mediaURL != nil {
                             self.performAction()
                         }
                     }
                 }
             }
         }
     }
        
     /**
      Sets the media types that the user can drop to the media view.
         
      If the user drops any of the specified media types to the view, the action is called.
      */
     @discardableResult
     open func allowedMediaDroping(_ mediaTypes: [MediaType]) -> Self {
      allowedMediaDroping = mediaTypes
      return self
     }
        
     func processPasteboard(_ contents: [PasteboardContent]) -> (image: NSImage?, fileURL: URL?) {
         let image = allowedMediaDroping.contains(.image) ? contents.images.first : nil
         let fileTypes = allowedMediaDroping.compactMap({$0.fileType})
         let fileURL = contents.fileURLs.filter({if let fileType = $0.fileType, fileTypes.contains(fileType) { return true} else { return false }}).first
         return (image, fileURL)
     }
     */
        
    // MARK: - Layout
        
    /**
     A view for hosting layered content on top of the media view.

     Use this view to host content that you want layered on top of the media view. This view is managed by the media view itself and is automatically sized to fill the media view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
         
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public let overlayContentView = NSView()

    open override var fittingSize: CGSize {
        if mediaURL?.fileType == .image || mediaURL?.fileType == .gif {
            return imageView.fittingSize
        } else if mediaURL?.fileType == .video {
            return videoView.fittingSize
        }
        return .zero
    }
        
    open override var intrinsicContentSize: NSSize {
        switch mediaType {
        case .video: return videoView.intrinsicContentSize
        case .image, .gif: return imageView.intrinsicContentSize
        case nil: return super.intrinsicContentSize
        }
    }
        
    // MARK: - Init

    /// Creates a media view that displays the media at the specified url.
    public init(mediaURL: URL) {
        super.init(frame: .zero)
        self.mediaURL = mediaURL
    }
        
    /// Creates a media view that plays the specified asset.
    public init(image: NSImage) {
        super.init(frame: .zero)
        self.image = image
    }
        
    /// Creates a media view that plays the specified asset.
    public init(asset: AVAsset) {
        super.init(frame: .zero)
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
        wantsLayer = true
        clipsToBounds = true
        mediaScaling = .scaleToFit
        videoView.controlsStyle = .inline
        videoView.player = player
        player.volume = 0.8
        overlayContentView.clipsToBounds = true
        addSubview(withConstraint: videoView)
        addSubview(withConstraint: imageView)
    }
        
    // MARK: - Private
        
    private func showImageView() {
        imageView.isHidden = false
        // imageView.overlayContentView.addSubview(withConstraint: overlayContentView)
        hideVideoView()
    }

    private func hideImageView() {
        imageView.image = nil
        imageView.isHidden = true
    }

    private func showVideoView() {
        videoView.isHidden = false
        // videoView.resizingContentOverlayView.addSubview(withConstraint: overlayContentView)
        setupPlaybackHandler()
        hideImageView()
    }

    private func hideVideoView() {
        updatePreviousPlaybackState()
        player.pause()
        playbackObserver = nil
        assetStatusObservation = nil
        player.replaceCurrentItem(with: nil)
        videoView.isHidden = true
    }

    private func updatePreviousPlaybackState() {
        if player.currentItem != nil {
            previousVideoPlaybackState = player.state
        }
    }
        
    private func setupPlaybackHandler(replace: Bool = true) {
        if let playbackPositionHandler = playbackPositionHandler {
            guard mediaType == .video else { return }
            playbackObserver = player.addPlaybackObserver(timeInterval: playbackPositionHandlerInterval) { time in
                playbackPositionHandler(time)
            }
        } else {
            playbackObserver = nil
        }
    }
        
    open override var menu: NSMenu? {
        didSet {
            imageView.menu = menu
            videoView.menu = menu
        }
    }
}

extension CGFloat {
    var unified: CGFloat {
        copysign(1, self)
    }
}

#endif
