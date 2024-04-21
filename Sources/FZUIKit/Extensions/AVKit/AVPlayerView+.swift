//
//  AVPlayerView+.swift
//
//
//  Created by Florian Zand on 22.02.24.
//

#if os(macOS)
import AVKit
import FZSwiftUtils
import UniformTypeIdentifiers

extension AVPlayerView {
    /// Sets the value that determines how the player view displays video content within its bounds.
    @discardableResult
    func videoGravity(_ videoGravity: AVLayerVideoGravity) -> Self {
        self.videoGravity = videoGravity
        return self
    }
    
    /// Sets the control style.
    @discardableResult
    func controlStyle(_ style: AVPlayerViewControlsStyle) -> Self {
        controlsStyle = style
        return self
    }
        
    /// The media content that a player view can display.
    public enum AVMediaContent: Int, Hashable {
        /// Video media content.
        case video
        /// Audio media content.
        case audio
        /// Image media content.
        case image
        /// GIF image media content.
        case gif
        
        var fileType: FileType {
            switch self {
            case .video: return .video
            case .audio: return .audio
            case .image: return .image
            case .gif: return .gif
            }
        }
        
        @available(macOS 11.0, *)
        var contentType: UTType {
            switch self {
            case .video: return .audiovisualContent
            case .audio: return .audio
            case .image: return .image
            case .gif: return .gif
            }
        }
    }
        
    /**
     The media types that the user can drop to the player view to change it's content.
     
     The default value is an empty array which indicates that the user can't drop any new media to the player view.
     */
    public var droppableMedia: [AVMediaContent]  {
        get { getAssociatedValue("dropMediaContent", initialValue: []) }
        set {
            let newValue = newValue.uniqued()
            setAssociatedValue(newValue, key: "dropMediaContent")
            guard newValue != droppableMedia else { return }
            if !newValue.isEmpty {
                dropHandlers.canDrop = { [weak self] items,_,_ in
                    guard let self = self else { return false }
                    return self.firstMediaURL(for: items.fileURLs) != nil
                }
                dropHandlers.didDrop = { [weak self] items,_,_ in
                    guard let self = self else { return }
                    let mediaURL = self.firstMediaURL(for: items.fileURLs)
                    if let mediaURL = mediaURL {
                        self.player?.replaceCurrentItem(with: AVPlayerItem(url: mediaURL))
                    }
                }
            } else {
                dropHandlers.canDrop = nil
                dropHandlers.didDrop = nil
            }
        }
    }
    
    func firstMediaURL(for urls: [URL]) -> URL? {
        return urls.first(where: {
            if #available(macOS 11.0, *) {
                if let contentType = $0.contentType, contentType.conforms(toAny: droppableMedia.compactMap({$0.contentType})) {
                    return true
                }
            }
            if let fileType = $0.fileType {
                return droppableMedia.compactMap({$0.fileType}).contains(fileType)
            }
            return false
        })
    }
    
    /**
     A view that displays between the video content and the playback controls that automatically resizes to the video bounds.
     
     Use the content overlay view to add noninteractive custom views, such as a logo or watermark, between the video content and the controls.
     
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public var resizingContentOverlayView: NSView {
        if let view: NSView = getAssociatedValue("resizingContentOverlayView") {
            return view
        }
                
        let overlayView = NSView()
        overlayView.clipsToBounds = true
        if let contentOverlayView = self.contentOverlayView {
            contentOverlayView.addSubview(overlayView)
        } else {
            addSubview(overlayView)
        }
        overlayView.frame = videoBounds
        setAssociatedValue(overlayView, key: "resizingContentOverlayView")
        videoBoundsObservation = observeChanges(for: \.videoBounds, handler: { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingContentOverlayView.frame = new
        })
        return overlayView
    }
    
    var videoBoundsObservation: KeyValueObservation? {
        get { getAssociatedValue("videoBoundsObservation", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "videoBoundsObservation") }
    }
}

#endif
