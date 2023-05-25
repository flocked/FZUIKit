//
//  QuicklookItem.swift
//  FZExtensions
//
//  Created by Florian Zand on 06.03.23.
//

#if os(macOS)
    import AppKit
    import QuickLookUI

    public class QuicklookItem: NSObject, QLPreviewable {
        public let previewItemURL: URL
        public var previewItemFrame: CGRect?
        public var previewItemTitle: String?
        public var previewItemTransitionImage: NSImage?

        public init(url: URL, title: String? = nil, frame: CGRect? = nil, transitionImage: NSImage? = nil) {
            previewItemURL = url
            previewItemFrame = frame
            previewItemTitle = title
            previewItemTransitionImage = transitionImage
        }
    }

    public class QuicklookMediaItem: NSObject, QLPreviewableMedia {
        public let media: PreviewableMedia
        public var previewItemFrame: CGRect?
        public var previewItemTitle: String?
        public var previewItemTransitionImage: NSImage?
        public var previewItemURL: URL! {
            mediaPreviewItemURL()
        }

        public init(media: PreviewableMedia, title: String? = nil, frame: CGRect? = nil, transitionImage: NSImage? = nil) {
            self.media = media
            previewItemFrame = frame
            previewItemTitle = title
            previewItemTransitionImage = transitionImage ?? (media as? NSImage)
        }
    }

#endif
