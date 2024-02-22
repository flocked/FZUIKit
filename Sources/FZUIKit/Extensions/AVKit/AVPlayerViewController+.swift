//
//  AVPlayerViewController+.swift
//
//
//  Created by Florian Zand on 22.02.24.
//

#if os(iOS)
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
        videoBoundsObservation = observeChanges(for: \.videoBounds, handler: { [weak self] old, new in
            guard let self = self, old != new else { return }
            self.resizingContentOverlayView.frame = new
        })
        return overlayView
    }
    
    var videoBoundsObservation: NSKeyValueObservation? {
        get { getAssociatedValue(key: "videoBoundsObservation", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "videoBoundsObservation", object: self) }
    }
}

#endif
