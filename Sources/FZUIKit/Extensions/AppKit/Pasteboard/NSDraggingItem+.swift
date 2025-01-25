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
}

#endif
