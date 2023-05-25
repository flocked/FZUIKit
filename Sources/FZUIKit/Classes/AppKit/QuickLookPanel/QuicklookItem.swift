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
    public let previewContent: QLPreviewableContent?
    public var previewItemURL: URL! {
        return previewContent?.previewURL
    }

    internal var _previewItemFrame: CGRect?
    public var previewItemFrame: CGRect? {
        get { return _previewItemFrame ?? previewItemView?.frameOnScreen }
        set { _previewItemFrame = newValue }
    }

    internal var _previewItemTitle: String?
    public var previewItemTitle: String? {
        get { return _previewItemTitle ?? previewContent?.previewTitle }
        set { _previewItemTitle = newValue }
    }

    internal var _previewItemTransitionImage: NSImage?
    public var previewItemTransitionImage: NSImage? {
        get { return _previewItemTransitionImage ?? previewContent?.previewTransitionImage ?? previewItemView?.renderedImage }
        set { _previewItemTransitionImage = newValue }
    }

    public convenience init(content: QLPreviewableContent, title: String? = nil, frame: CGRect? = nil, transitionImage: NSImage? = nil) {
        self.init(content, title: title, frame: frame, transitionImage: transitionImage)
    }

    internal init(_ content: QLPreviewableContent?, title: String? = nil, frame: CGRect? = nil, transitionImage: NSImage? = nil) {
        previewContent = content
        _previewItemFrame = frame
        _previewItemTitle = title
        _previewItemTransitionImage = transitionImage
    }
}

#endif
