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
        self.frame = frame ?? CGRect(.zero, image.size)
    }
    
    /// Creates a dragging image component for the specified image.
    public convenience init(image: CGImage, frame: CGRect? = nil, key: NSDraggingItem.ImageComponentKey = .icon) {
        self.init(key: key)
        contents = image
        self.frame = frame ?? CGRect(.zero, image.size)
    }
    
    /// Creates a dragging image component for the specified view.
    public convenience init(view: NSView) {
        self.init(key: .icon)
        contents = view.renderedImage
        frame = CGRect(.zero, view.bounds.size)
    }
    
    /// The image of the component.
    public var image: NSImage? {
        contents as? NSImage ?? CGImage(contents)?.nsImage
    }
}

#endif
