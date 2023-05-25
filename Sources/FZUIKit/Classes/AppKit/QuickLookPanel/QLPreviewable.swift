//
//  QLPreviewable.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import Quartz

/**
 A protocol that defines a set of properties you implement to make a preview that can be displayed by QuicklookPanel and QuicklookItem.
 */
public protocol QLPreviewable: QLPreviewItem {
    /**
     The frame of the content on the screen.

     The default value for a content that is NSView is the view frame on the screen.
     */
    var previewItemFrame: CGRect? { get }
    /**
     The image to use for the transition zoom effect for the item.

     The default value for a content that is NSView is a rendered image of the view.
     */
    var previewItemTransitionImage: NSImage? { get }

    /**
     The content to preview by an QuickPanel or QuicklookView. The value is either a URL/NSURL to a file, NSImage, AVURLAsset, NSView or NSDocument.

     QuicklookPanel and QuicklookView display the provided content.
     */
    var previewContent: QLPreviewableContent? { get }
}

public extension QLPreviewable {
    var previewItemURL: URL! {
        return previewContent?.previewURL
    }

    var previewItemFrame: CGRect? {
        return previewItemView?.frameOnScreen
    }

    var previewItemTitle: String! {
        return previewContent?.previewTitle
    }

    var previewItemTransitionImage: NSImage? {
        return previewContent?.previewTransitionImage ?? previewItemView?.renderedImage
    }

    /// Returns a NSView if the QLPreviewable is a view.
    internal var previewItemView: NSView? {
        return (self as? NSView) ?? (self as? NSCollectionViewItem)?.view ?? (self as? NSWindow)?.contentView
    }
}
#endif
