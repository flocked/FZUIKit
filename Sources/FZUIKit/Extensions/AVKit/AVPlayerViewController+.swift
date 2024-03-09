//
//  AVPlayerViewController+.swift
//
//
//  Created by Florian Zand on 22.02.24.
//

#if os(iOS) || os(tvOS)
import AVKit
import FZSwiftUtils

extension AVPlayerViewController {
    /**
     A view that displays between the video content and the playback controls that automatically resizes to the video bounds.
     
     Use the content overlay view to add noninteractive custom views, such as a logo or watermark, between the video content and the controls.
     
     The view in this property clips its subviews to its bounds rectangle by default, but you can change that behavior using the `clipsToBounds` property.
     */
    public var resizingContentOverlayView: UIView {
        if let view: UIView = getAssociatedValue(key: "resizingContentOverlayView", object: self) {
            return view
        }
        
        let overlayView = UIView()
        overlayView.clipsToBounds = true
        if let contentOverlayView = self.contentOverlayView {
            contentOverlayView.addSubview(overlayView)
        } else {
            view.addSubview(overlayView)
        }
        overlayView.frame = videoBounds
        set(associatedValue: overlayView, key: "resizingContentOverlayView", object: self)
        #if os(iOS)
        videoBoundsObservation = observeChanges(for: \.videoBounds, handler: { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingContentOverlayView.frame = new
        })
        #else
        videoViewControllerObserver?.add(\.view?.frame) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingContentOverlayView.frame = self.videoBounds
        }
        videoViewControllerObserver?.add(\.videoGravity) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingContentOverlayView.frame = self.videoBounds
        }
        videoViewControllerObserver?.add(\.player?.currentItem) { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingContentOverlayView.frame = self.videoBounds
        }
        #endif
        return overlayView
    }
    
    #if os(iOS)
    var videoBoundsObservation: KeyValueObservation? {
        get { getAssociatedValue(key: "videoBoundsObservation", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "videoBoundsObservation", object: self) }
    }
    #else
    var videoViewControllerObserver: KeyValueObserver<AVPlayerViewController>? {
        get { getAssociatedValue(key: "videoBoundsObservation", object: self, initialValue: KeyValueObserver(self)) }
    }
    
    /**
     The size and position of the video image within the bounds of the view controller’s view.
 
     The size and position of this rectangle depend on the aspect ratio of the media (like 16:9 or 4:3), the bounds of the player view controller’s view, and the view controller’s `videoGravity`.
     */
    public var videoBounds: CGRect {
        guard var videoSize = player?.currentItem?.asset.videoNaturalSize, let frameSize = view?.frame.size else {
            return .zero
        }
        switch videoGravity {
        case .resizeAspect:
            videoSize = videoSize.scaled(toFit: frameSize)
        case .resizeAspectFill:
            videoSize = videoSize.scaled(toFill: frameSize)
        default:
            return CGRect(.zero, frameSize)
        }
        var rect = CGRect(.zero, videoSize)
        rect.center = CGRect(.zero, frameSize).center
        return rect
    }
    #endif
}
#endif
