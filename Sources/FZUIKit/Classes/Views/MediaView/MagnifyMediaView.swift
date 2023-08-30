//
//  Magnee.swift
//  CombTest
//
//  Created by Florian Zand on 30.05.22.
//

#if os(macOS)
import AVKit
import AppKit
import Foundation
import FZSwiftUtils


/// A magnifiable view that presents media.
open class MagnifyMediaView: NSView {
    public let mediaView = MediaView()
    private let scrollView = NSScrollView()

    override open var acceptsFirstResponder: Bool {
        return true
    }

    open var overlayView: NSView? {
        get { return mediaView.overlayView }
        set { mediaView.overlayView = newValue }
    }

    open var tintColor: NSColor? {
        get { mediaView.tintColor }
        set { mediaView.tintColor = newValue }
    }

    open var doubleClickZoomFactor: CGFloat = 0.5
    override open func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        if event.clickCount == 2 {
            if magnification != 1.0 {
                setMagnification(1.0)
            } else {
                let mousePoint = event.location(in: self)
                zoomIn(factor: doubleClickZoomFactor, centeredAt: mousePoint)
            }
        }
    }

    override open func rightMouseDown(with _: NSEvent) {
        mediaView.videoView.player?.togglePlayback()
    }

    override open func keyDown(with event: NSEvent) {
        if event.keyCode == 30 { // Zoom In
            if event.modifierFlags.contains(.command) {
                setMagnification(maxMagnification)
            } else {
                zoomIn(factor: 0.3)
            }
        } else if event.keyCode == 44 { // Zoom Out
            if event.modifierFlags.contains(.command) {
                //  self.setMagnification(self.minMagnification, animationDuration: 0.1)
                setMagnification(1.0)
            } else {
                zoomOut(factor: 0.3)
            }
        } else {
            super.keyDown(with: event)
        }
    }

    override open var mouseDownCanMoveWindow: Bool {
        return true
    }

    open func scroll(to point: CGPoint) {
        scrollView.contentView.setBoundsOrigin(point)
        scrollView.scroll(scrollView.contentView, to: point)
    }

    open func scroll(to point: CGPoint, animationDuration: TimeInterval) {
        scrollView.scroll(point, animationDuration: animationDuration)
    }

    open func zoomIn(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
        zoom(factor: factor, centeredAt: centeredAt, animationDuration: animationDuration)
    }

    open func zoomOut(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
        zoom(factor: -factor, centeredAt: centeredAt, animationDuration: animationDuration)
    }

    open func zoom(factor: CGFloat = 0.5, centeredAt: CGPoint? = nil, animationDuration: TimeInterval? = nil) {
        if allowsMagnification {
            let range = maxMagnification - minMagnification
            if range > 0.0 {
                let factor = factor.clamped(to: -1.0 ... 1.0)
                let newMag = (magnification + (range * factor)).clamped(to: minMagnification ... maxMagnification)
                setMagnification(newMag, centeredAt: centeredAt, animationDuration: animationDuration)
            }
        }
    }

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
        get { return mediaView.mediaURL }
        set {
            mediaView.mediaURL = newValue
            mediaView.frame.size = mediaView.intrinsicContentSize
            magnification = 1
            updateMagnification()
        }
    }

    open var image: NSImage? {
        get { return mediaView.image }
        set {
            mediaView.image = newValue
            mediaView.frame.size = mediaView.intrinsicContentSize
            magnification = 1
            updateMagnification()
        }
    }

    open var images: [NSImage] {
        get { return mediaView.images }
        set {
            mediaView.images = newValue
            mediaView.frame.size = mediaView.intrinsicContentSize
            magnification = 1
            updateMagnification()
        }
    }

    @available(macOS 12.0, iOS 13.0, *)
    open var symbolConfiguration: NSUIImage.SymbolConfiguration? {
        get { mediaView.symbolConfiguration }
        set { mediaView.symbolConfiguration = newValue }
    }

    open var asset: AVAsset? {
        get { return mediaView.asset }
        set {
            mediaView.asset = newValue
            mediaView.frame.size = mediaView.intrinsicContentSize
            magnification = 1
            updateMagnification()
        }
    }

    open var isMuted: Bool {
        get { mediaView.isMuted }
        set { mediaView.isMuted = newValue }
    }

    open var volume: Float {
        get { mediaView.volume }
        set { mediaView.volume = newValue }
    }

    open var videoPlaybackOption: MediaView.VideoPlaybackOption {
        get { mediaView.videoPlaybackOption }
        set { mediaView.videoPlaybackOption = newValue }
    }

    open var autoAnimatesImages: Bool {
        get { mediaView.autoAnimatesImages }
        set { mediaView.autoAnimatesImages = newValue }
    }

    open var loopVideos: Bool {
        get { mediaView.loopVideos }
        set { mediaView.loopVideos = newValue }
    }

    open var videoViewControlStyle: AVPlayerViewControlsStyle {
        get { mediaView.videoViewControlStyle }
        set { mediaView.videoViewControlStyle = newValue }
    }

    open var contentScaling: CALayerContentsGravity {
        get { mediaView.contentScaling }
        set { mediaView.contentScaling = newValue }
    }

    open var mediaType: URL.FileType? { return mediaView.mediaType }

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
        return mediaView.isPlaying
    }

    override open var fittingSize: NSSize {
        return mediaView.fittingSize
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

    /*
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
    
    */

    override open var enclosingScrollView: NSScrollView? {
        return scrollView
    }
    
    private var boundsSize = CGSize(-1, -1)
    open override func layout() {
        super.layout()
        guard self.bounds.size != boundsSize else { return }
        self.boundsSize = self.bounds.size
        scrollView.frame.size = self.bounds.size
        updateMagnification()
    }
    
    /*
    private func updateMagnification(reset: Bool = false) {
        let mediaViewSize =  mediaView.intrinsicContentSize
        Swift.print("updateMagnification", self.bounds.size)
        Swift.print("mediaView.intrinsicContentSize", mediaView.intrinsicContentSize)
        let minMagnification: CGFloat
        let maxMagnification: CGFloat
        if mediaViewSize.height > mediaViewSize.width {
            minMagnification = self.bounds.height / mediaViewSize.height
            maxMagnification = self.bounds.height*3 / mediaViewSize.height
        } else {
            minMagnification = self.bounds.width / mediaViewSize.width
            maxMagnification = self.bounds.width*3 / mediaViewSize.width
        }
        Swift.print("minMagnification", minMagnification, maxMagnification)
        
        let magnificationRange = scrollView.maxMagnification - scrollView.minMagnification
        let percentage = (scrollView.magnification - scrollView.minMagnification) / magnificationRange
        scrollView.minMagnification = minMagnification
        scrollView.maxMagnification = maxMagnification
        let newMagnificationRange = scrollView.maxMagnification - scrollView.minMagnification
        scrollView.magnification = reset ? scrollView.minMagnification : (scrollView.minMagnification + (newMagnificationRange * percentage))
    }
     */
    
    private var _magnification: CGFloat = 1.0
    private var _minMagnification: CGFloat = 1.0
    private var _maxMagnification: CGFloat = 3.0
    
    public var minMagnification: CGFloat {
        get { _minMagnification }
        set { guard newValue != minMagnification else { return }
            _minMagnification = newValue
            updateMagnification()
        }
    }
    
    public var maxMagnification: CGFloat {
        get { _maxMagnification }
        set { guard newValue != maxMagnification else { return }
            _maxMagnification = newValue
            updateMagnification()
        }
    }
    
    public var magnification: CGFloat {
        get { _magnification }
        set { guard newValue != _magnification else { return }
            _magnification = newValue
            updateMagnification()
        }
    }
    
   private func updateMagnification() {
        let mediaViewSize =  mediaView.intrinsicContentSize
        if mediaViewSize.height > mediaViewSize.width {
            scrollView.minMagnification = (self.bounds.height*_minMagnification) / mediaViewSize.height
            scrollView.maxMagnification = (self.bounds.height*_maxMagnification) / mediaViewSize.height
        } else {
            scrollView.minMagnification = (self.bounds.height*_minMagnification) / mediaViewSize.width
            scrollView.maxMagnification = (self.bounds.height*_maxMagnification) / mediaViewSize.width
        }
        let magnificationRange = _maxMagnification - _minMagnification
        let scrollViewMagnificationRange = scrollView.maxMagnification - scrollView.minMagnification
        let percentage = (_magnification - _minMagnification) / magnificationRange
        scrollView.magnification = (scrollView.minMagnification + (scrollViewMagnificationRange * percentage))
    }

    public init(mediaURL: URL) {
        super.init(frame: .zero)
        self.mediaURL = mediaURL
    }

    public init(frame: CGRect, mediaURL: URL) {
        super.init(frame: frame)
        self.mediaURL = mediaURL
    }

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    public var backgroundColor: NSUIColor? {
        get { self.layer?.backgroundColor?.nsColor }
        set {
            self.layer?.backgroundColor = newValue?.cgColor
            self.enclosingScrollView?.backgroundColor = newValue
        }
    }

    private func sharedInit() {
        wantsLayer = true
        mediaView.wantsLayer = true
        mediaView.frame = bounds
        scrollView.frame = bounds
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        scrollView.contentView = CenteredClipView()

        scrollView.contentView.frame.size = CGSize(width: 50, height: 50)
        scrollView.drawsBackground = false

        scrollView.documentView = mediaView
        mediaView.constraint(to: scrollView.contentView)

        allowsMagnification = true
        contentScaling = .resizeAspect
        minMagnification = 1.0
        maxMagnification = 3.0
        backgroundColor = .black
        enclosingScrollView?.backgroundColor = .black
    }
}

fileprivate class CenteredScrollView: NSScrollView {
    override func smartMagnify(with event: NSEvent) {
        super.smartMagnify(with: event)
    }
}

fileprivate class CenteredClipView: NSClipView {
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var rect = super.constrainBoundsRect(proposedBounds)

        if let containerView = documentView {
            if rect.size.width > containerView.frame.size.width {
                rect.origin.x = (containerView.frame.width - rect.width) / 2
            }

            if rect.size.height > containerView.frame.size.height {
                rect.origin.y = (containerView.frame.height - rect.height) / 2
            }
        }

        return rect
    }
}
#endif
