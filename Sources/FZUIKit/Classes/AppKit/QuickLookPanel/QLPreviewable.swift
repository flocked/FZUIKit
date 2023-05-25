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

    public protocol QLPreviewable: QLPreviewItem {
        var previewItemFrame: CGRect? { get }
        var previewItemTransitionImage: NSImage? { get }
    }

    public extension QLPreviewable {
        var previewItemFrame: CGRect? {
            return nil
        }

        var previewItemTransitionImage: NSImage? {
            return nil
        }

        var previewItemTitle: String? {
            return nil
        }
    }

    public extension QLPreviewable where Self: NSView {
        var previewItemFrame: CGRect? {
            return frame
        }

        var previewItemTransitionImage: NSImage? {
            return renderedImage
        }
    }

    public extension QLPreviewable where Self: NSCollectionViewItem {
        var previewItemFrame: CGRect? {
            return view.frame
        }

        var previewItemTransitionImage: NSImage? {
            return view.renderedImage
        }
    }

    public extension QLPreviewable where Self: NSTableCellView {
        var previewItemFrame: CGRect? {
            return rowView?.frame ?? frame
        }

        var previewItemTransitionImage: NSImage? {
            return rowView?.renderedImage ?? renderedImage
        }
    }

    internal extension QLPreviewable {
        var _itemView: NSView? {
            return (self as? NSView) ?? (self as? NSCollectionViewItem)?.view ?? (self as? NSWindow)?.contentView
        }

        var previewItemView: NSView? {
            get { getAssociatedValue(key: "_previewItemView", object: self) }
            set { set(weakAssociatedValue: newValue, key: "_previewItemView", object: self) }
        }

        func frameOnScreen(inside window: NSWindow) -> CGRect? {
            guard let previewItemFrame = previewItemFrame else { return nil }
            guard let contentView = window.contentView else { return nil }
            let frameInWindow = contentView.convert(previewItemFrame, to: nil)
            let pointOnScreen = contentView.window?.convertToScreen(frameInWindow)
            return pointOnScreen
        }
    }
#endif
