//
//  NSDraggingItem+.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSDraggingItem {
    /**
     Sets the item’s dragging image.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    public func setDraggingImage(_ image: NSImage, frame: CGRect? = nil) {
        setDraggingFrame(frame ?? image.size.rect, contents: image)
    }
    
    /**
     Sets the item’s dragging image.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    public func setDraggingImage(_ image: CGImage, frame: CGRect? = nil) {
        setDraggingFrame(frame ?? image.size.rect, contents: image)
    }
    
    /// Sets the item’s dragging image using a rendered snapshot of the specified view.
    public func setDraggingImage(view: NSView) {
        setDraggingImage(view.renderedImage)
    }
}

#endif
