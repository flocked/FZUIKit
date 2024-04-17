//
//  MediaViewAlt.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
    import AppKit
    import AVKit
    import Foundation
    import FZSwiftUtils

    open class MediaViewAlt: NSView {
        
        let imageView = ImageView().isHidden(true)
        let videoView = NoMenuPlayerView().isHidden(true)
        private let videoPlayer = AVPlayer()
        private var playbackObserver: AVPlayerTimeObservation?
        private var previousVideoPlaybackState: AVPlayer.State = .isStopped
        
        /// Media type.
        public enum MediaType {
            /// Video.
            case video
            /// Image.
            case image
            /// GIF.
            case gif
        }
        
        /// The media type currently displayed.
        public private(set) var mediaType: MediaType?
        
        /// The playback behavior for animated images.
        open var imageAnimationPlayback: ImageView.AnimationPlaybackOption {
            get { imageView.animationPlayback }
            set { imageView.animationPlayback = newValue }
        }

        /**
         The amount of time it takes to go through one cycle of an animated image.

         The time duration is measured in seconds. The default value of this property is `0.0`, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
         */
        public var imageAnimationDuration: TimeInterval {
            get { imageView.animationDuration }
            set { imageView.animationDuration = newValue }
        }

        /**
         Specifies the number of times to repeat animated images.

         The default value is `0`, which specifies to repeat the animation indefinitely.
         */
        public var imageAnimationRepeatCount: Int {
            get { imageView.animationRepeatCount }
            set { imageView.animationRepeatCount = newValue }
        }

        public var overlayView: NSView? {
            didSet {
                if let overlayView = overlayView, oldValue != overlayView {
                    oldValue?.removeFromSuperview()
                    addSubview(withConstraint: overlayView)
                } else {
                    oldValue?.removeFromSuperview()
                }
            }
        }

        /// A Boolean value that indicates whether videos loop.
        public var loopVideos: Bool {
            get { videoPlayer.isLooping }
            set { videoPlayer.isLooping = newValue }
        }
        
        /// A Boolean value that indicates whether the audio of videos is muted.
        public var isMuted: Bool {
            get { videoPlayer.isMuted }
            set { videoPlayer.isMuted = newValue }
        }
        
        /// The volume of videos.
        public var volume: Float {
            get { videoPlayer.volume }
            set { videoPlayer.volume = newValue }
        }
        
        /// The control style for videos.
        var videoViewControlStyle: AVPlayerViewControlsStyle  {
            get { videoView.controlsStyle }
            set { videoView.controlsStyle = newValue }
        }
        
        /// Playback option when loading a new video.
        public var videoPlaybackOption: VideoPlaybackOption = .autostart
        
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
                AVLayerVideoGravity(imageScaling: imageScaling)
            }
        }

        /// The scaling of the media.
        public var mediaScaling: MediaScaling = .scaleToFit {
            didSet {
                imageView.imageScaling = mediaScaling.imageScaling
                videoView.videoGravity = mediaScaling.videoGravity
            }
        }

        override public var intrinsicContentSize: NSSize {
            if imageView.displayingImage != nil {
                return imageView.intrinsicContentSize
            }
            if let videoSize = asset?.videoNaturalSize {
                return videoSize
            }
            return .zero
        }

        public var mediaURL: URL? {
            didSet {
                pause()
                if let mediaURL = mediaURL {
                    updatePreviousPlaybackState()
                    if mediaURL.fileType == .video {
                        asset = AVAsset(url: mediaURL)
                    } else if mediaURL.fileType == .image || mediaURL.fileType == .gif, let image = NSImage(contentsOf: mediaURL) {
                        self.image = image
                    } else {
                        mediaType = nil
                        self.mediaURL = nil
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

        public var asset: AVAsset? {
            get { videoPlayer.currentItem?.asset }
            set {
                if let asset = newValue {
                    showVideoView()
                    pause()
                    mediaType = .video
                    videoPlayer.pause()
                    videoPlayer.replaceCurrentItem(with: AVPlayerItem(asset: asset))
                    switch videoPlaybackOption {
                    case .autostart:
                        videoPlayer.play()
                    case .previousPlaybackState:
                        switch previousVideoPlaybackState {
                        case .isPlaying:
                            videoPlayer.play()
                        default:
                            videoPlayer.pause()
                        }
                    case .pause:
                        videoPlayer.pause()
                    }
                    hideImageView()
                } else if mediaType == .video {
                    hideVideoView()
                    mediaURL = nil
                    mediaType = nil
                }
            }
        }

        /// The image displayed in the media view.
        public var image: NSImage? {
            get { imageView.image }
            set {
                if let image = newValue {
                    showImageView()
                    imageView.image = image
                    hideVideoView()
                    mediaType = imageView.isAnimatable ? .gif : .image
                } else if mediaType == .image {
                    hideImageView()
                    mediaURL = nil
                    mediaType = nil
                }
            }
        }

        /// The images displayed in the media view.
        public var images: [NSImage] {
            get { imageView.images }
            set {
                imageView.images = newValue
                if newValue.isEmpty == false {
                    showImageView()
                    hideVideoView()
                    mediaType = imageView.isAnimatable ? .gif : .image
                } else if mediaType == .image {
                    hideImageView()
                    mediaURL = nil
                    mediaType = nil
                }
            }
        }

        @available(macOS 12.0, iOS 13.0, *)
        public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { imageView.symbolConfiguration }
            set { imageView.symbolConfiguration = newValue }
        }

        public var tintColor: NSColor? {
            get { imageView.tintColor }
            set { imageView.tintColor = newValue }
        }
        
        public func play() {
            imageView.startAnimating()
            videoPlayer.play()
        }

        public func pause() {
            imageView.pauseAnimating()
            videoPlayer.pause()
        }

        public func stop() {
            imageView.stopAnimating()
            videoPlayer.stop()
        }

        public func togglePlayback() {
            imageView.toggleAnimating()
            videoPlayer.togglePlayback()
        }

        public var isPlaying: Bool {
            imageView.isAnimating ? true : videoPlayer.state == .isPlaying
        }

        public func seek(to interval: TimeDuration, completionHandler: ((Bool) -> Void)? = nil) {
            if mediaType == .video {
                videoPlayer.seek(to: interval, completionHandler: completionHandler)
            }
        }

        public func seek(toPercentage percentage: Double, completionHandler: ((Bool) -> Void)? = nil) {
            if mediaType == .video {
                videoPlayer.seek(toPercentage: percentage)
            }
        }

        public var videoPlaybackTime: TimeDuration {
            get { 
                if let seconds = videoPlayer.currentItem?.currentTime().seconds {
                    return .seconds(seconds)
                }
                return .zero
            }
            set { videoPlayer.seek(to: newValue) }
        }

        public var videoDuration: TimeDuration { .seconds(videoPlayer.currentItem?.duration.seconds ?? 0) }

        public var videoPlaybackPosition: Double {
            get { videoPlayer.currentItem?.playbackPercentage ?? .zero }
            set { videoPlayer.seek(toPercentage: newValue) }
        }
        
        public var playbackHandlerInterval: TimeInterval = 0.1 {
            didSet {
                guard oldValue != playbackHandlerInterval else { return }
                setupPlaybackHandler()
            }
        }

        public var videoPlaybackHandler: ((TimeDuration) -> Void)? {
            didSet { setupPlaybackHandler() }
        }
        
        func setupPlaybackHandler() {
            if let videoPlaybackHandler = videoPlaybackHandler {
                playbackObserver = videoPlayer.addPlaybackObserver(timeInterval: playbackHandlerInterval) { time in
                    videoPlaybackHandler(time)
                }
            } else {
                playbackObserver = nil
            }
        }

        override public var fittingSize: NSSize {
            if mediaURL?.fileType == .image || mediaURL?.fileType == .gif {
                return imageView.fittingSize
            } else if mediaURL?.fileType == .video {
                return videoView.fittingSize
            }
            return .zero
        }

        public func sizeToFit() {
            frame.size = fittingSize
        }

        private enum VideoPlaybackState: Int, Hashable {
            case playing
            case paused
            case stopped
        }

        private func showImageView() {
            imageView.isHidden = false
        }

        private func hideImageView() {
            imageView.image = nil
            imageView.isHidden = true
        }

        private func showVideoView() {
            videoView.isHidden = false
        }

        private func hideVideoView() {
            updatePreviousPlaybackState()
            videoPlayer.pause()
            videoPlayer.replaceCurrentItem(with: nil)
            videoView.isHidden = true
        }

        private func updatePreviousPlaybackState() {
            if let player = videoView.player {
                previousVideoPlaybackState = player.state
            }
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

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }
        
        private func sharedInit() {
            wantsLayer = true
            clipsToBounds = true
            mediaScaling = .scaleToFit
            videoView.controlsStyle = .inline
            videoView.player = videoPlayer
            videoPlayer.volume = 0.2
            addSubview(withConstraint: imageView)
            addSubview(withConstraint: videoView)
        }
        
        /// The appearance of the media.
        public struct MediaAppearance: Hashable {
            /// The background color of the media.
            public var backgroundColor: NSColor?
            /// The corner radius of the media.
            public var cornerRadius: CGFloat = 0.0
            /// The border of the media.
            public var border: BorderConfiguration = .none()
            /// The shadow of the media.
            public var shadow: ShadowConfiguration = .none()
            /// The inner shadow of the media.
            public var innerShadow: ShadowConfiguration = .none()
        }

        /// The appearance of the media.
        open var mediaAppearance = MediaAppearance() {
            didSet {
                guard oldValue != mediaAppearance else { return }
                imageView.cornerRadius = mediaAppearance.cornerRadius
                videoView.cornerRadius = mediaAppearance.cornerRadius
                imageView.backgroundColor = mediaAppearance.backgroundColor
                videoView.backgroundColor = mediaAppearance.backgroundColor
                imageView.configurate(using: mediaAppearance.border)
                videoView.configurate(using: mediaAppearance.border)
                imageView.configurate(using: mediaAppearance.shadow, type: .outer)
                videoView.configurate(using: mediaAppearance.shadow, type: .outer)
                imageView.innerShadow = mediaAppearance.innerShadow
                videoView.innerShadow = mediaAppearance.innerShadow
            }
        }

        override open func keyDown(with event: NSEvent) {
            if (handlers.keyDown?(event) ?? false) == false {
                super.keyDown(with: event)
            }
        }

        override open func mouseDown(with event: NSEvent) {
            if (handlers.mouseDown?(event) ?? false) == false {
                super.mouseDown(with: event)
            }
        }

        override open func rightMouseDown(with event: NSEvent) {
            if (handlers.rightMouseDown?(event) ?? false) == false {
                super.rightMouseDown(with: event)
            }
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
