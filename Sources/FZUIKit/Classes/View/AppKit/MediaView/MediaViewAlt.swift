//
//  MediaView.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
    import AppKit
    import AVKit
    import Foundation
    import FZSwiftUtils

    /// A view that displays media.
    open class MediaView: NSView {
        let imageView = ImageView().isHidden(true)
        let videoView = NoMenuPlayerView().isHidden(true)
        private let mediaPlayer = AVPlayer()
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
                AVLayerVideoGravity(imageScaling: imageScaling)
            }
        }
        
        public var mediaURL: URL? {
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

        /// The image displayed in the media view.
        public var image: NSImage? {
            get { imageView.image }
            set {
                imageView.image = newValue
                if let image = newValue {
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

        /// The images displayed in the media view.
        public var images: [NSImage] {
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
        
        /// The media asset played by the media view.
        public var asset: AVAsset? {
            get { mediaPlayer.currentItem?.asset }
            set {
                setupAsset(newValue)
                _mediaURL = (asset as? AVURLAsset)?.url
            }
        }
        
        private func setupAsset(_ asset: AVAsset?) {
            if let asset = asset {
                updatePreviousPlaybackState()
                mediaPlayer.pause()
                mediaPlayer.replaceCurrentItem(with: AVPlayerItem(asset: asset))
                mediaType = .video
                showVideoView()
                hideImageView()
                resizeOverlayView()
                switch videoPlaybackOption {
                case .autostart:
                    mediaPlayer.play()
                case .previousPlaybackState:
                    switch previousVideoPlaybackState {
                    case .isPlaying:
                        mediaPlayer.play()
                    default:
                        mediaPlayer.pause()
                    }
                case .pause:
                    mediaPlayer.pause()
                }
            } else if mediaType == .video {
                hideVideoView()
                _mediaURL = nil
                mediaType = nil
            }
        }
        
        /// The media type currently displayed.
        public private(set) var mediaType: MediaType?
                
        /**
         A view for hosting layered content on top of the media view.

         Use this view to host content that you want layered on top of the media view. This view is managed by the media view itself and is automatically sized to fill the media view’s frame rectangle. Add your subviews and use layout constraints to position them within the view.
         
         The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
         */
        public let overlayContentView = NSView()
        
        /// The current size and position of the media that displays within the media view’s bounds.
        public var mediaBounds: CGRect {
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

        /// A Boolean value that indicates whether media is looped.
        public var isLooping: Bool {
            get { mediaPlayer.isLooping }
            set { mediaPlayer.isLooping = newValue }
        }
        
        /// A Boolean value that indicates whether media is muted.
        public var isMuted: Bool {
            get { mediaPlayer.isMuted }
            set { mediaPlayer.isMuted = newValue }
        }
        
        /// The volume of the media.
        public var volume: Float {
            get { mediaPlayer.volume }
            set { mediaPlayer.volume = newValue }
        }
        
        /// The control style for videos.
        var videoViewControlStyle: AVPlayerViewControlsStyle  {
            get { videoView.controlsStyle }
            set { videoView.controlsStyle = newValue }
        }
        
        /// Playback option when loading new me dia.
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
        public var mediaScaling: MediaScaling = .scaleToFit {
            didSet {
                imageView.imageScaling = mediaScaling.imageScaling
                videoView.videoGravity = mediaScaling.videoGravity
                resizeOverlayView()
            }
        }

        /// The image symbol configuration.
        @available(macOS 12.0, iOS 13.0, *)
        public var imageSymbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { imageView.symbolConfiguration }
            set { imageView.symbolConfiguration = newValue }
        }

        /// The image tint color for template and symbol images.
        public var imageTintColor: NSColor? {
            get { imageView.tintColor }
            set { imageView.tintColor = newValue }
        }
        
        /// Starts playback of the media.
        public func play() {
            imageView.startAnimating()
            mediaPlayer.play()
        }

        /// Pauses playback of the media.
        public func pause() {
            imageView.pauseAnimating()
            mediaPlayer.pause()
        }

        /// Stops playback of the media.
        public func stop() {
            imageView.stopAnimating()
            mediaPlayer.stop()
        }

        /// Toggles the playback between play and pause.
        public func togglePlayback() {
            imageView.toggleAnimating()
            mediaPlayer.togglePlayback()
        }

        /// A Boolean value that indicates whether the media is playing.
        public var isPlaying: Bool {
            imageView.isAnimating ? true : mediaPlayer.state == .isPlaying
        }

        /**
         Requests that the player seek to a specified time.

         - Parameters:
            - time: The time to which to seek.
            - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
                - finished: A Boolean value that indicates whether the seek operation completed.
         */
        public func seekVideo(to interval: TimeDuration, completionHandler: ((Bool) -> Void)? = nil) {
            mediaPlayer.seek(to: interval, completionHandler: completionHandler)
        }

        /**
         Requests that the player seek to a specified percentage.

         - Parameters:
            - percentage: The percentage to which to seek.
            - completionHandler: The block to invoke when the seek operation has either been completed or been interrupted. The block takes one argument:
                - finished: A Boolean value that indicates whether the seek operation completed.
         */
        public func seekVideo(toPercentage percentage: Double, completionHandler: ((Bool) -> Void)? = nil) {
            mediaPlayer.seek(toPercentage: percentage)
        }

        /// The duration of the current video.
        public var videoDuration: TimeDuration {
            mediaPlayer.duration
        }
        
        /// The playback time of the current video.
        public var videoPlaybackTime: TimeDuration {
            get { mediaPlayer.currentTimeDuration }
            set { mediaPlayer.currentTimeDuration = newValue }
        }

        /// The playback percentage of the current video (between `0` and `1.0`).
        public var videoPlaybackPercentage: Double {
            get { mediaPlayer.playbackPercentage }
            set { mediaPlayer.playbackPercentage = newValue }
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
        
        func setupPlaybackHandler(replace: Bool = true) {
            if let videoPlaybackHandler = videoPlaybackHandler {
                guard mediaType == .video else { return }
                playbackObserver = mediaPlayer.addPlaybackObserver(timeInterval: playbackHandlerInterval) { time in
                    videoPlaybackHandler(time)
                }
            } else {
                playbackObserver = nil
            }
        }

        override public var fittingSize: CGSize {
            if mediaURL?.fileType == .image || mediaURL?.fileType == .gif {
                return imageView.fittingSize
            } else if mediaURL?.fileType == .video {
                return videoView.fittingSize
            }
            return .zero
        }
        
        override public var intrinsicContentSize: NSSize {
            switch mediaType {
            case .video: return videoView.intrinsicContentSize
            case .image, .gif: return imageView.intrinsicContentSize
            case nil: return super.intrinsicContentSize
            }
        }

        public func sizeToFit() {
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
            mediaPlayer.pause()
            playbackObserver = nil
            mediaPlayer.replaceCurrentItem(with: nil)
            videoView.isHidden = true
        }

        private func updatePreviousPlaybackState() {
            if mediaPlayer.currentItem != nil {
                previousVideoPlaybackState = mediaPlayer.state
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
        public init(asset: AVAsset) {
            super.init(frame: .zero)
            self.asset = asset
        }
        
        /// Creates a media view that plays the specified asset.
        public init(image: NSImage) {
            super.init(frame: .zero)
            self.image = image
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
            videoView.player = mediaPlayer
            mediaPlayer.volume = 0.8
            overlayContentView.clipsToBounds = true
            addSubview(withConstraint: imageView)
            addSubview(withConstraint: videoView)
        }
        
        /*
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
        */

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

class NoMenuPlayerView: AVPlayerView {
    public override var acceptsFirstResponder: Bool {
        false
    }
    
    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        false
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
    
    public override var menu: NSMenu? {
        get { return nil }
        set { }
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        Swift.print("video rightMouseDown")
    }
    
    public override func rightMouseUp(with event: NSEvent) {
        Swift.print("video rightMouseUp")
    }
    
    public override func mouseDown(with event: NSEvent) {
        Swift.print("video mouseDown")
    }
    
    public override func mouseUp(with event: NSEvent) {
        Swift.print("video mouseUp")
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
}

    public class NoKeyDownPlayerView: AVPlayerView {
        
        public override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            sharedInit()
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            sharedInit()
        }
        
        public init() {
            super.init(frame: .zero)
            sharedInit()
        }
        
        func sharedInit() {
            if #available(macOS 13.0, *) {
                allowsMagnification = false
                allowsVideoFrameAnalysis = false
            }
            allowsPictureInPicturePlayback = false
        }
                
        var _menu: NSMenu? = nil
        public override var menu: NSMenu? {
            get { _menu }
            set { _menu = newValue }
        }
        
        public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
            !ignoreMouseDown
        }

        /// A Boolean value that indicates whether to ignore `keyDown` events.
        public var ignoreKeyDown = true

        public var ignoreMouseDown = true

        /// Handlers for a player view.
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

        /// Handlers for the player view.
        public var handlers: Handlers = .init()

        override public func mouseDown(with event: NSEvent) {
            if (handlers.mouseDown?(event) ?? false) == false {
                if ignoreMouseDown {
                    nextResponder?.mouseDown(with: event)
                } else {
                    super.mouseDown(with: event)
                }
            }
        }
        
        public override func mouseUp(with event: NSEvent) {
            
        }
        
        public override var acceptsFirstResponder: Bool {
            return false
        }

        override public func rightMouseDown(with event: NSEvent) {
            if (handlers.rightMouseDown?(event) ?? false) == false {
                super.rightMouseDown(with: event)
            }
        }
    
        public override func rightMouseUp(with event: NSEvent) {
            
        }

        override public func keyDown(with event: NSEvent) {
            if (handlers.keyDown?(event) ?? false) == false {
                if ignoreKeyDown {
                    nextResponder?.keyDown(with: event)
                } else {
                    super.keyDown(with: event)
                }
            }
        }

        override public func flagsChanged(with event: NSEvent) {
            if (handlers.flagsChanged?(event) ?? false) == false {
                super.flagsChanged(with: event)
            }
        }
    }

extension AVLayerVideoGravity {
    init(imageScaling: ImageView.ImageScaling) {
        switch imageScaling {
        case .scaleToFill:
            self = .resizeAspectFill
        case .scaleToFit:
            self = .resizeAspect
        case .resize:
            self = .resize
        default:
            self = .resizeAspectFill
        }
    }
}

#endif
