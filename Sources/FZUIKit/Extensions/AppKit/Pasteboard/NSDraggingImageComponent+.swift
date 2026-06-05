//
//  NSDraggingImageComponent+.swift
//
//
//  Created by Florian Zand on 11.02.24.
//

#if os(macOS)
import AppKit

extension NSDraggingImageComponent {
    @_disfavoredOverload
    public convenience init(key: NSDraggingItem.ImageComponentKey, image: NSImage? = nil, frame: CGRect? = nil) {
        self.init(key: key)
        self.contents = image
        self.frame = frame ?? image?.size.rect ?? self.frame
    }
    
    public convenience init(key: NSDraggingItem.ImageComponentKey, image: CGImage, frame: CGRect? = nil) {
        self.init(key: key)
        self.contents = image
        self.frame = frame ?? image.size.rect
    }
    
    public convenience init(key: NSDraggingItem.ImageComponentKey, view: NSView) {
        self.init(key: key, image: view.renderedImage)
    }
    
    /// Creates an icon dragging image component with the specified image.
    public static func icon(_ image: NSImage? = nil, frame: CGRect? = nil) -> NSDraggingImageComponent {
        NSDraggingImageComponent(key: .icon, image: image, frame: frame)
    }
    
    /// Creates an icon dragging image component with the specified image.
    public static func icon(_ image: CGImage, frame: CGRect? = nil) -> NSDraggingImageComponent {
        NSDraggingImageComponent(key: .icon, image: image, frame: frame)
    }
    
    /// Creates an icon dragging image component with an image of the specified view.
    public static func icon(_ view: NSView) -> NSDraggingImageComponent {
        NSDraggingImageComponent(key: .icon, view: view)
    }
    
    /// Creates a label dragging image component with the specified image.
    public static func label(_ image: NSImage? = nil, frame: CGRect? = nil) -> NSDraggingImageComponent {
        NSDraggingImageComponent(key: .label, image: image, frame: frame)
    }
    
    /// Creates a label dragging image component with the specified image.
    public static func label(_ image: CGImage, frame: CGRect? = nil) -> NSDraggingImageComponent {
        NSDraggingImageComponent(key: .label, image: image, frame: frame)
    }
    
    /// Creates a label dragging image component with an image of the specified view.
    public static func label(_ view: NSView) -> NSDraggingImageComponent {
        NSDraggingImageComponent(key: .label, view: view)
    }
    
    /// The image of the component.
    public var image: NSImage? {
        contents as? NSImage ?? CGImage(contents)?.nsImage
    }
}

extension NSDraggingItem.ImageComponentKey: Swift.ExpressibleByStringLiteral, Swift.ExpressibleByStringInterpolation, Swift.ExpressibleByExtendedGraphemeClusterLiteral, Swift.ExpressibleByUnicodeScalarLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

#endif
