//
//  NSDraggingInfo+.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit

public extension NSDraggingInfo {
    /**
     The current location of the mouse pointer in the specified view.
     
     - Parameter view: The view for the location.
     */
    func location(in view: NSView) -> CGPoint {
        view.convert(draggingLocation, from: nil)
    }
    
    /**
     Sets the image that visually represents the pasteboard content during the drag operation.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    func setDraggedImage(_ image: NSImage, frame: CGRect? = nil) {
        enumerateDraggingItems(options: [.clearNonenumeratedImages], for: nil, classes: [NSPasteboardItem.self]) { item, index, shouldStop in
            item.setDraggingImage(image, frame: frame)
            shouldStop.pointee = true
        }
    }
    
    /// Sets the image that visually represents the pasteboard content during the drag operation using the specified view.
    func setDraggedImage(view: NSView) {
        setDraggedImage(view.renderedImage)
    }
}

#endif
