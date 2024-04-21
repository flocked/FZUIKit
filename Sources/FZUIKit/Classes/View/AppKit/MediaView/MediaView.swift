//
//  MediaView.swift
//
//
//  Created by Florian Zand on 30.05.22.
//

/*
#if os(macOS)
    import AppKit
    import AVKit
    import Foundation
    import FZSwiftUtils

    /// A view that displays media.
    open class MediaView: NSView {
        public enum VideoPlaybackOption: Int, Hashable {
            case autostart
            case previousPlaybackState
            case off
        }
        
        open var imagePlayback: ImageView.AnimationPlaybackOption {
            get { imageView.animationPlayback }
            set { imageView.animationPlayback = newValue }
        }

        /**
         The amount of time it takes to go through one cycle of the images.

         The time duration is measured in seconds. The default value of this property is 0.0, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
         */
        public var animationDuration: TimeInterval {
            get { imageView.animationDuration }
            set { imageView.animationDuration = newValue }
        }

        /**
         Specifies the number of times to repeat the animation.

         The default value is 0, which specifies to repeat the animation indefinitely.
         */
        public var animationRepeatCount: Int {
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

        public var tintColor: NSColor? {
            get { imageView.tintColor }
            set { imageView.tintColor = newValue }
        }

        public var loopVideos: Bool = true
        public var isMuted: Bool = false { didSet { updateVideoViewConfiguration() } }
        public var volume: Float = 0.2 { didSet { updateVideoViewConfiguration() } }
        public var videoPlaybackOption: VideoPlaybackOption = .autostart
        public var videoViewControlStyle: AVPlayerViewControlsStyle = .inline {
            didSet { updateVideoViewConfiguration() }
        }

        /// The scaling of the media.
        public var contentScaling: ImageView.ImageScaling = .scaleToFit {
            didSet {
                imageView.imageScaling = contentScaling
                videoView.videoGravity = AVLayerVideoGravity(imageScaling: contentScaling)
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

        public private(set) var mediaType: FileType?

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
            get {
                if mediaType == .video { return videoView.player?.currentItem?.asset }
                return nil
            }
            set {
                if let asset = newValue {
                    showVideoView()
                    pause()
                    mediaType = .video
                    mediaSize = asset.videoNaturalSize
                    if videoView.player == nil {
                        videoView.player = AVPlayer()
                    }
                    let item = AVPlayerItem(asset: asset)
                    videoView.player?.pause()
                    videoView.player?.replaceCurrentItem(with: item)
                    switch videoPlaybackOption {
                    case .autostart:
                        videoView.player?.play()
                    case .previousPlaybackState:
                        switch previousVideoPlaybackState {
                        case .isPlaying:
                            videoView.player?.play()
                        default:
                            videoView.player?.pause()
                        }
                    case .off:
                        videoView.player?.pause()
                    }
                    hideImageView()
                } else if mediaType == .video {
                    hideVideoView()
                    mediaURL = nil
                    mediaType = nil
                }
                invalidateIntrinsicContentSize()
            }
        }

        /// The image displayed in the media view.
        public var image: NSImage? {
            get {
                if mediaType == .image || mediaType == .gif { return imageView.image }
                return nil
            }
            set {
                pause()
                if let image = newValue {
                    showImageView()
                    imageView.image = image
                    hideVideoView()
                    mediaType = .image
                } else if mediaType == .image {
                    hideImageView()
                    mediaURL = nil
                    mediaType = nil
                }
                invalidateIntrinsicContentSize()
            }
        }

        /// The images displayed in the media view.
        public var images: [NSImage] {
            get { imageView.images }
            set {
                pause()
                imageView.images = newValue
                if newValue.isEmpty == false {
                    showImageView()
                    hideVideoView()
                    mediaType = .image
                } else if mediaType == .image {
                    hideImageView()
                    mediaURL = nil
                    mediaType = nil
                }
                invalidateIntrinsicContentSize()
            }
        }

        @available(macOS 12.0, iOS 13.0, *)
        public var symbolConfiguration: NSUIImage.SymbolConfiguration? {
            get { imageView.symbolConfiguration }
            set { imageView.symbolConfiguration = newValue }
        }

        public func play() {
            imageView.startAnimating()
            videoView.player?.play()
        }

        public func pause() {
            imageView.pauseAnimating()
            videoView.player?.pause()
        }

        public func stop() {
            imageView.stopAnimating()
            videoView.player?.stop()
        }

        public func togglePlayback() {
            imageView.toggleAnimating()
            videoView.player?.togglePlayback()
        }

        public var isPlaying: Bool {
            if mediaType == .image || mediaType == .gif {
                return imageView.isAnimating
            } else if mediaType == .video {
                return videoView.player?.state == .isPlaying
            }
            return false
        }

        public func seek(to interval: TimeDuration) {
            if mediaType == .video {
                videoView.player?.seek(to: interval)
            }
        }

        public func seek(toPercentage percentage: Double) {
            if mediaType == .video {
                videoView.player?.seek(toPercentage: percentage)
            }
        }

        public var videoPlaybackTime: TimeDuration {
            get { guard let seconds = videoView.player?.currentItem?.currentTime().seconds else { return .zero }
                return .seconds(seconds)
            }
            set { videoView.player?.seek(to: newValue) }
        }

        public var videoDuration: TimeDuration { .seconds(videoView.player?.currentItem?.duration.seconds ?? 0) }

        public var videoPlaybackPosition: Double {
            get { videoView.player?.currentItem?.playbackPercentage ?? .zero }
            set { videoView.player?.seek(toPercentage: newValue) }
        }

        var playbackObserver: Any?
        public var videoPlaybackPositionHandler: ((TimeDuration) -> Void)? {
            didSet {
                if let playbackObserver = self.playbackObserver {
                    videoView.player?.removeTimeObserver(playbackObserver)
                    self.playbackObserver = nil
                }
                if let videoPlaybackPositionHandler = self.videoPlaybackPositionHandler {
                    self.playbackObserver = videoView.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main, using: { time in
                        videoPlaybackPositionHandler(.seconds(time.seconds))
                    })
                }
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
            imageView.frame = frame
            imageView.imageScaling = contentScaling
            imageView.isHidden = false
        }

        private func hideImageView() {
            imageView.image = nil
            imageView.isHidden = true
        }

        private func showVideoView() {
            updateVideoViewConfiguration()
            setupPlayerItemDidReachEnd()
            videoView.isHidden = false
        }

        private func hideVideoView() {
            updatePreviousPlaybackState()
            if let player = videoView.player {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            }
            videoView.player?.pause()
            videoView.player?.replaceCurrentItem(with: nil)
            videoView.isHidden = true
        }

        private var previousVideoPlaybackState: AVPlayer.State = .isStopped
        private var mediaSize: CGSize?

        private func updateVideoViewConfiguration() {
            videoView.player?.volume = volume
            videoView.controlsStyle = videoViewControlStyle
            videoView.videoGravity =  AVLayerVideoGravity(imageScaling: contentScaling)
            videoView.player?.isMuted = isMuted
        }

        private func updatePreviousPlaybackState() {
            if let player = videoView.player {
                previousVideoPlaybackState = player.state
            }
        }

        private func setupPlayerItemDidReachEnd() {
            if mediaURL?.fileType == .video, let player = videoView.player {
                player.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(playerItemDidReachEnd(notification:)),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: player.currentItem)
            }
        }

        @objc private func playerItemDidReachEnd(notification: Notification) {
            if let playerItem = notification.object as? AVPlayerItem {
                if loopVideos {
                    playerItem.seek(to: CMTime.zero, completionHandler: nil)
                }
            }
        }

        lazy var imageView: ImageView = {
            let imageView = ImageView()
            imageView.imageScaling = self.contentScaling
            imageView.isHidden = true
            return imageView
        }()

        lazy var videoView: NoMenuPlayerView = {
            let videoView = NoMenuPlayerView()
            videoView.isHidden = true
            videoView.videoGravity =  AVLayerVideoGravity(imageScaling: contentScaling)
            return videoView
        }()

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
            contentScaling = .scaleToFit
            addSubview(withConstraint: imageView)
            addSubview(withConstraint: videoView)
        }

        /*
         /// The scaling of the media.
         open var scaling: CALayerContentsGravity = .resizeAspect {
             didSet {
                 if let videoSize = asset?.videoNaturalSize {

                 } else if let image = imageView.displayingImage {

                 }
             }
         }

         func updateScaling() {
             var mediaSize = intrinsicContentSize
             if mediaSize != .zero {
                 switch scaling {
                 case .resizeAspect:
                     mediaSize = mediaSize.scaled(toFit: bounds.size)
                 case .resizeAspectFill:
                     mediaSize = mediaSize.scaled(toFill: bounds.size)
                 case .resize:
                     mediaSize = bounds.size
                 default:
                     break
                 }
                 imageView.frame.size = mediaSize
                 videoView.frame.size = mediaSize
                 switch scaling {
                 case .bottom:
                     imageView.frame.bottom = bounds.bottom
                     videoView.frame.bottom = bounds.bottom
                 case .bottomLeft:
                     imageView.frame.bottom = .zero
                     videoView.frame.bottom = .zero
                 case .bottomRight:
                     imageView.frame.bottomRight = bounds.bottomRight
                     videoView.frame.bottomRight = bounds.bottomRight
                 case .left:
                     imageView.frame.left = bounds.left
                     videoView.frame.left = bounds.left
                 case .right:
                     imageView.frame.right = bounds.right
                     videoView.frame.right = bounds.right
                 case .topLeft:
                     imageView.frame.topLeft = bounds.topLeft
                     videoView.frame.topLeft = bounds.topLeft
                 case .top:
                     imageView.frame.top = bounds.top
                     videoView.frame.top = bounds.top
                 case .topRight:
                     imageView.frame.topRight = bounds.topRight
                     videoView.frame.topRight = bounds.topRight
                 default:
                     imageView.center = bounds.center
                     videoView.center = bounds.center
                 }
             } else {
                 imageView.frame.size = bounds.size
                 videoView.frame.size = bounds.size
                 imageView.frame.bottom = .zero
                 videoView.frame.bottom = .zero
             }
         }
          */

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
*/
