//
//  NSDraggingItem+.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit

extension NSDraggingItem {
    /**
     Sets the item’s dragging image.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    public func setDraggingImage(_ image: NSImage, frame: CGRect? = nil) {
        setDraggingFrame(frame ?? CGRect(.zero, image.size), contents: image)
    }
    
    /// Sets the item’s dragging image using the specified view.
    public func setDraggingImage(view: NSView) {
        setDraggingImage(view.renderedImage)
    }
    
    /// Creates and returns a dragging item using the specified content.
    convenience init(pasteboardWriting: PasteboardWriting) {
        self.init(pasteboardWriter: pasteboardWriting.pasteboardWriting)
    }
}

#endif
