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

public class MediaView: NSView {
    public enum VideoPlaybackOption {
        case autostart
        case previousPlaybackState
        case off
    }

    public var autoAnimatesImages: Bool {
        get { imageView.autoAnimates }
        set { imageView.autoAnimates = newValue }
    }
    
    /**
     The amount of time it takes to go through one cycle of the images.
     
     The time duration is measured in seconds. The default value of this property is 0.0, which causes the image view to use a duration equal to the number of images multiplied by 1/30th of a second. Thus, if you had 30 images, the duration would be 1 second.
     */
    public var animationDuration: TimeInterval {
        get {  imageView.animationDuration }
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

    public var overlayView: NSView? = nil {
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

    public var contentScaling: CALayerContentsGravity = .resizeAspect {
        didSet {
            imageView.imageScaling = contentScaling
            videoView.videoGravity = AVLayerVideoGravity(caLayerContentsGravity: contentScaling) ?? .resizeAspectFill
        }
    }
    
    public override var intrinsicContentSize: NSSize {
        if imageView.displayingImage != nil {
            return imageView.intrinsicContentSize
        }
        if mediaType == .video, let videoSize = asset?.videoNaturalSize {
            return videoSize
        }
        return .zero
    }

    public private(set) var mediaType: FileType? = nil

    public var mediaURL: URL? = nil {
        didSet {
            self.pause()
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
            self.invalidateIntrinsicContentSize()
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
                self.pause()
                mediaType = .video
                videoSize = asset.videoNaturalSize
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
            self.invalidateIntrinsicContentSize()
        }
    }

    /// The image displayed in the media view.
    public var image: NSImage? {
        get {
            if mediaType == .image || mediaType == .gif { return imageView.image }
            return nil
        }
        set {
            self.pause()
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
            self.invalidateIntrinsicContentSize()
        }
    }

    /// The images displayed in the media view.
    public var images: [NSImage] {
        get { return imageView.images }
        set {
            self.pause()
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
            self.invalidateIntrinsicContentSize()
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
        if self.mediaType == .image || self.mediaType == .gif {
            return imageView.isAnimating
        } else if self.mediaType == .video {
            return videoView.player?.state == .isPlaying
        }
        return false
    }
    
    public func seek(to interval: TimeDuration) {
        if self.mediaType == .video {
            videoView.player?.seek(to: interval)
        }
    }
    
    public func seek(toPercentage percentage: Double) {
        if self.mediaType == .video {
            videoView.player?.seek(toPercentage: percentage)
        }
    }
    
    public var videoPlaybackTime: TimeDuration {
        get { guard let seconds = videoView.player?.currentItem?.currentTime().seconds else { return .zero }
            return .seconds(seconds) }
        set { videoView.player?.seek(to: newValue) }
    }
    
    public var videoDuration: TimeDuration {
        get { .seconds(videoView.player?.currentItem?.duration.seconds ?? 0)}
    }
    
    public var videoPlaybackPosition: Double {
        get { videoView.player?.currentItem?.playbackPercentage ?? .zero }
        set { videoView.player?.seek(toPercentage: newValue) }
    }
    
    internal var playbackObserver: Any? = nil
    public var videoPlaybackPositionHandler: ((TimeDuration)->())? {
        didSet {
            if let playbackObserver = self.playbackObserver {
                videoView.player?.removeTimeObserver(playbackObserver)
                self.playbackObserver = nil
            }
            if let videoPlaybackPositionHandler = self.videoPlaybackPositionHandler {
                self.playbackObserver = videoView.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds:0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main, using: { time in
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

    private enum VideoPlaybackState {
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
    private var videoSize: CGSize? = nil

    private func updateVideoViewConfiguration() {
        videoView.player?.volume = volume
        videoView.controlsStyle = videoViewControlStyle
        videoView.videoGravity = AVLayerVideoGravity(caLayerContentsGravity: contentScaling) ?? .resizeAspectFill
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

    internal lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.imageScaling = self.contentScaling
        imageView.isHidden = true
        return imageView
    }()

    public lazy var videoView: NoKeyDownPlayerView = {
        let videoView = NoKeyDownPlayerView()
        videoView.isHidden = true
        videoView.videoGravity = AVLayerVideoGravity(caLayerContentsGravity: self.contentScaling) ?? .resizeAspectFill
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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        wantsLayer = true
        contentScaling = .resizeAspectFill
        addSubview(withConstraint: imageView)
        addSubview(withConstraint: videoView)
    }
}

public class NoKeyDownPlayerView: AVPlayerView {
    public var ignoreKeyDown = true
    override public func keyDown(with event: NSEvent) {
        if ignoreKeyDown {
            nextResponder?.keyDown(with: event)
        } else {
            super.keyDown(with: event)
        }
    }
}

#endif
