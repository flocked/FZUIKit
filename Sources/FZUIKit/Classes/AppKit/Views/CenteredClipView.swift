//
//  CenteredClipView.swift
//
//
//  Created by Florian Zand on 21.09.23.
//

#if os(macOS)
    import AppKit

    /// A `NSClipView` that is centered.
    open class CenteredClipView: NSClipView {
        override open func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
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
