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
    open class MediaView: NSView {
        let imageView = ImageView().isHidden(true)
        let videoView = AVPlayerView().isHidden(true)
        private let player = AVPlayer()
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
        }
        
        /// The scaling of the media.
        public enum MediaScaling: Int {
            /// The media is resized to fit the entire bounds rectangle.
            case resize
            /// The media is resized to completely fill the bounds rectangle, while still preserving the aspect of the image.
            case scaleToFill
            /// The media is resized to fit the bounds rectangle, preserving the aspect of the image.
            case scaleToFit
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
        
        /// The url to the media displayed in the media view.
        open var mediaURL: URL? {
            get { _mediaURL }
            set {
                _mediaURL = newValue
                pause()
                if let mediaURL = newValue {
                    if mediaURL.fileType == .video {
                        setupAsset(AVAsset(url: mediaURL))
                    } else if mediaURL.fileType == .image || mediaURL.fileType == .gif, let image = NSImage(contentsOf: mediaURL) {
                        self.image = image
                    } else {
                        mediaType = nil
                        _mediaURL = nil
                        hideImageView()
                        hideVideoView()
                    }
                } else {
                    mediaType = nil
                    hideImageView()
                    hideVideoView()
                }
                invalidateIntrinsicContentSize()
            }
        }
        
        /// Sets the url to the media displayed in the media view.
        @discardableResult
        open func mediaURL(_ mediaURL: URL?) -> Self {
            set(\.mediaURL, to: mediaURL)
        }

        /// The image displayed in the media view.
        open var image: NSImage? {
            get { imageView.image }
            set {
                imageView.image = newValue
                if newValue != nil {
                    showImageView()
                    hideVideoView()
                    mediaType = imageView.isAnimatable ? .gif : .image
                    _mediaURL = nil
                    resizeOverlayView()
                } else if mediaType == .image {
                    hideImageView()
                    _mediaURL = nil
                    mediaType = nil
                }
            }
        }
        
        /// Sets the image displayed in the media view.
        @discardableResult
        open func image(_ image: NSImage?) -> Self {
            set(\.image, to: image)
        }

        /// The images displayed in the media view.
        open var images: [NSImage] {
            get { imageView.images }
            set {
                imageView.images = newValue
                if newValue.isEmpty == false {
                    showImageView()
                    hideVideoView()
                    mediaType = imageView.isAnimatable ? .gif : .image
                    _mediaURL = nil
                    resizeOverlayView()
                } else if mediaType == .image {
                    hideImageView()
                    _mediaURL = nil
                    mediaType = nil
                }
            }
        }
        
        /// Sets the images displayed in the media view.
        @discardableResult
        open func images(_ images: [NSImage]) -> Self {
            set(\.images, to: images)
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
            set(\.asset, to: asset)
        }
        
        private func setupAsset(_ asset: AVAsset?) {
            if let asset = asset {
                updatePreviousPlaybackState()
                player.pause()
                player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
                mediaType = .video
                showVideoView()
                hideImageView()
                resizeOverlayView()
                switch videoPlaybackOption {
                case .autostart:
                    player.play()
                case .previousPlaybackState:
                    switch previousVideoPlaybackState {
                    case .isPlaying:
                        player.play()
                    default:
                        player.pause()
                    }
                case .pause:
                    player.pause()
                }
            } else if mediaType == .video {
                hideVideoView()
                _mediaURL = nil
                mediaType = nil
            }
        }
        
        /// The media type currently displayed.
        open private(set) var mediaType: MediaType?
                
        /**
         A view for hosting layered content on top of the media view.

         Use this view to host content that you want layered on top of the media view. This view is managed by the media view itself and is automatically sized to fill the media view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
         
         The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
         */
        public let overlayContentView = NSView()
        
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
        
        /// The playback behavior for animated images.
        open var imageAnimationPlayback: ImageView.AnimationPlaybackOption {
            get { imageView.animationPlayback }
            set { imageView.animationPlayback = newValue }
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
            get { imageView.animationDuration }
            set { imageView.animationDuration = newValue }
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
            get { imageView.animationRepeatCount }
            set { imageView.animationRepeatCount = newValue }
        }
        
        /// Sets the number of times to repeat animated images.
        @discardableResult
        open func imageAnimationRepeatCount(_ repeatCount: Int) -> Self {
            set(\.imageAnimationRepeatCount, to: repeatCount)
        }

        /// A Boolean value that indicates whether media is looped.
        open var isLooping: Bool {
            get { player.isLooping }
            set { player.isLooping = newValue }
        }
        
        /// Sets the Boolean value that indicates whether media is looped.
        @discardableResult
        open func isLooping(_ isLooping: Bool) -> Self {
            set(\.isLooping, to: isLooping)
        }

        /// A value that indicates whether the volume can be modified by the user by scrolling up & down.
        open var volumeScrollControl: VolumeScrollControl = .normal
        
        /// Sets the value that indicates whether the volume can be modified by the user by scrolling up & down.
        @discardableResult
        open func volumeScrollControl(_ volumeScrollControl: VolumeScrollControl) -> Self {
            set(\.volumeScrollControl, to: volumeScrollControl)
        }
        
        /// A value that indicates whether the playback position can be modified by the user by scrolling left & right.
        open var playbackPositionScrollControl: PlaybackPositionScrollControl = .normal
        
        /// Sets the value that indicates whether the playback position can be modified by the user by scrolling left & right.
        @discardableResult
        open func playbackPositionScrollControl(_ playbackPositionScrollControl: PlaybackPositionScrollControl) -> Self {
            set(\.playbackPositionScrollControl, to: playbackPositionScrollControl)
        }
        
        /// The value that indicates whether the volume can be modified by the user by scrolling up & down.
        public enum VolumeScrollControl: Double {
            case slow = 0.25
            case normal = 0.5
            case fast = 0.75
            /// The volume can't be modified by scrolling.
            case off = 0.0
        }

        /// The value that indicates whether the playback position can be modified by the user by scrolling left & right.
        public enum PlaybackPositionScrollControl: Double {
            case slow = 0.1
            case normal = 0.25
            case fast = 0.5
            /// The playback position can't be modified by scrolling.
            case off = 0.0
            var mouse: Double {
                switch self {
                case .slow: return 1
                case .normal: return 2
                case .fast: return 4
                case .off: return 0
                }
            }
        }
        
        /// A Boolean value that indicates whether media is muted.
        open var isMuted: Bool {
            get { player.isMuted }
            set { player.isMuted = newValue }
        }
        
        /// Sets the Boolean value that indicates whether media is muted.
        @discardableResult
        open func isMuted(_ isMuted: Bool) -> Self {
            set(\.isMuted, to: isMuted)
        }
        
        /// The volume of the media.
        @objc dynamic open var volume: CGFloat {
            get { CGFloat(player.volume) }
            set { player.volume = Float(newValue) }
        }
        
        /// Sets the volume of the media.
        @discardableResult
        open func volume(_ volume: CGFloat) -> Self {
            set(\.volume, to: volume)
        }
        
        /// The control style for videos.
        open var videoViewControlStyle: AVPlayerViewControlsStyle  {
            get { videoView.controlsStyle }
            set { videoView.controlsStyle = newValue }
        }
        
        /// Sets the control style for videos.
        @discardableResult
        open func videoViewControlStyle(_ style: AVPlayerViewControlsStyle) -> Self {
            set(\.videoViewControlStyle, to: style)
        }
        
        /// The playback option when loading new media.
        open var videoPlaybackOption: VideoPlaybackOption = .autostart
        
        /// The playback option when loading new media.
        @discardableResult
        open func videoPlaybackOption(_ option: VideoPlaybackOption) -> Self {
            set(\.videoPlaybackOption, to: option)
        }
        
        /// Playback option when loading a new video.
        public enum VideoPlaybackOption: Int, Hashable {
            /// New videos automatically start.
            case autostart
            /// New videos keep the previous playback state.
            case previousPlaybackState
            /// New videos are paused.
            case pause
        }
        
        /// The scaling of the media.
        open var mediaScaling: MediaScaling = .scaleToFit {
            didSet {
                imageView.imageScaling = mediaScaling.imageScaling
                videoView.videoGravity = mediaScaling.videoGravity
                resizeOverlayView()
            }
        }
        
        /// Sets the scaling of the media.
        @discardableResult
        open func mediaScaling(_ mediaScaling: MediaScaling) -> Self {
            set(\.mediaScaling, to: mediaScaling)
        }

        /// The image symbol configuration.
        @available(macOS 12.0, iOS 13.0, *)
        open var imageSymbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { imageView.symbolConfiguration }
            set { imageView.symbolConfiguration = newValue }
        }
        
        /// Sets the image symbol configuration.
        @available(macOS 12.0, iOS 13.0, *)
        @discardableResult
        open func imageSymbolConfiguration(_ symbolConfiguration: NSUIImage.SymbolConfiguration?) -> Self {
            set(\.imageSymbolConfiguration, to: symbolConfiguration)
        }

        /// The image tint color for template and symbol images.
        open var imageTintColor: NSColor? {
            get { imageView.tintColor }
            set { imageView.tintColor = newValue }
        }
        
        /// Sets the image tint color for template and symbol images.
        @discardableResult
        open func imageTintColor(_ imageTintColor: NSColor?) -> Self {
            set(\.imageTintColor, to: imageTintColor)
        }
        
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

        /// A Boolean value that indicates whether the media is playing.
        open var isPlaying: Bool {
            imageView.isAnimating ? true : player.state == .isPlaying
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
            player.seek(to: interval, tolerance: tolerance, completionHandler: completionHandler)
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
            set(\.videoPlaybackTime, to: videoPlaybackTime)
        }

        /// The playback percentage of the current video (between `0` and `1.0`).
        open var videoPlaybackPercentage: Double {
            get { player.playbackPercentage }
            set { player.playbackPercentage = newValue }
        }
        
        /// Sets the playback percentage of the current video (between `0` and `1.0`).
        @discardableResult
        open func videoPlaybackPercentage(_ percentage: Double) -> Self {
            set(\.videoPlaybackPercentage, to: percentage)
        }

        /// The handler that is called whenever the playback position changes.
        open var playbackPositionHandler: ((TimeDuration) -> Void)? {
            didSet { setupPlaybackHandler() }
        }
        
        /// Sets the handler that is called whenever the playback position changes.
        @discardableResult
        open func playbackPositionHandler(_ handler: ((TimeDuration) -> Void)?) -> Self {
            set(\.playbackPositionHandler, to: handler)
        }
        
        /// The time interval at which the system invokes the handler during normal playback, according to progress of the current playback position.
        open var playbackPositionHandlerInterval: TimeInterval = 0.1 {
            didSet {
                guard oldValue != playbackPositionHandlerInterval else { return }
                setupPlaybackHandler()
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

        open func sizeToFit() {
            frame.size = fittingSize
        }

        private func showImageView() {
            imageView.isHidden = false
            imageView.overlayContentView.addSubview(overlayContentView)
        }

        private func hideImageView() {
            imageView.image = nil
            imageView.isHidden = true
        }

        private func showVideoView() {
            videoView.isHidden = false
            videoView.resizingContentOverlayView.addSubview(overlayContentView)
            setupPlaybackHandler()
        }

        private func hideVideoView() {
            updatePreviousPlaybackState()
            player.pause()
            playbackObserver = nil
            player.replaceCurrentItem(with: nil)
            videoView.isHidden = true
        }

        private func updatePreviousPlaybackState() {
            if player.currentItem != nil {
                previousVideoPlaybackState = player.state
            }
        }
        
        private func resizeOverlayView() {
            if let contentView = overlayContentView.superview {
                overlayContentView.frame.size = contentView.bounds.size
            }
        }
        
        open override func layout() {
            super.layout()
            resizeOverlayView()
        }

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
            addSubview(withConstraint: imageView)
            addSubview(withConstraint: videoView)
        }
        
        open override func scrollWheel(with event: NSEvent) {
            if (enclosingScrollView?.magnification ?? 1.0) == 1.0 || event.modifierFlags.contains(any: [.command, .shift]), mediaType == .video, (volumeScrollControl != .off || playbackPositionScrollControl != .off) {
                let isMouse = event.phase.isEmpty
                let isTrackpadBegan = event.phase.contains(.began)
                let isTrackpadEnd = event.phase.contains(.ended)
                var scrollDirection: NSUIUserInterfaceLayoutOrientation?
                
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

                if scrollDirection == .vertical, volumeScrollControl != .off {
                    var deltaY = (isPrecise ? Double(event.scrollingDeltaY) : event.scrollingDeltaY.unifiedDouble * 2)/100.0
                    if isNatural {
                        deltaY = -deltaY
                    }
                    let newVolume = (volume + (isMouse ? deltaY : volumeScrollControl.rawValue * deltaY)).clamped(to: 0...1.0)
                    volume = newVolume
                } else if scrollDirection == .horizontal, playbackPositionScrollControl != .off {
                    var deltaX = isPrecise ? Double(event.scrollingDeltaX) : event.scrollingDeltaX.unifiedDouble
                    if !isNatural {
                        deltaX = -deltaX
                    }
                    let seconds = (isMouse ? playbackPositionScrollControl.mouse : playbackPositionScrollControl.rawValue)*deltaX
                    if !isLooping {
                        videoPlaybackTime = .seconds((videoPlaybackTime.seconds + seconds).clamped(to: 0...videoDuration.seconds))
                    } else {
                        let duration = videoDuration.seconds
                        let truncating = (videoPlaybackTime.seconds+seconds).truncatingRemainder(dividingBy: duration)
                        if truncating < 0.0 {
                            videoPlaybackTime = .seconds(duration-(truncating * -1.0))
                        } else {
                            videoPlaybackTime = .seconds(truncating)
                        }
                    }
                }
            } else {
                super.scrollWheel(with: event)
            }
        }
    }

class NoMenuPlayerView: AVPlayerView {
    override var acceptsFirstResponder: Bool {
        false
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        false
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
    
    override var menu: NSMenu? {
        get { return nil }
        set { }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
    }
    
    override func rightMouseUp(with event: NSEvent) {
        
    }
    
    override func mouseDown(with event: NSEvent) {
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

extension CGFloat {
    var unifiedDouble: Double {
        Double(copysign(1, self))
    }
}

#endif
