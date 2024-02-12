//
//  NSDraggingImageComponent+.swift
//
//
//  Created by Florian Zand on 11.02.24.
//

#if os(macOS)
import AppKit

extension NSDraggingImageComponent {
    /// Creates a dragging image component for the specified image.
    public convenience init(image: NSImage, frame: CGRect? = nil, key: NSDraggingItem.ImageComponentKey = .icon) {
        self.init(key: key)
        contents = image
        if let frame = frame {
            self.frame = frame
        } else {
            self.frame = CGRect(.zero, image.size)
        }
    }
    
    /// Creates a dragging image component for the specified image.
    public convenience init(image: CGImage, frame: CGRect? = nil, key: NSDraggingItem.ImageComponentKey = .icon) {
        self.init(key: key)
        contents = image
        if let frame = frame {
            self.frame = frame
        } else {
            self.frame = CGRect(.zero, image.size)
        }
    }
    
    /// Creates a dragging image component for the specified view.
    public convenience init(view: NSView) {
        self.init(key: .icon)
        contents = view.renderedImage
        frame.origin = .zero
        frame.size = view.bounds.size
    }
}

#endif
