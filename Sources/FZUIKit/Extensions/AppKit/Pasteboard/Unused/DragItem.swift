//
//  DragItem.swift
//
//
//  Created by Florian Zand on 05.06.26.
//

/*
#if os(macOS)

import AppKit
import FZSwiftUtils

/**
 A single dragged item within a dragging session.
 
 ``DraggingItem`` objects have extremely limited lifetimes.
 When you call the NSDraggingSession method beginDraggingSession(with:event:source:), the system immediately consumes the dragging items that pass to the method, and doesn’t retain them. Any further changes to the dragging item associated with the returned NSDraggingSession must occur with the enumeration method enumerateDraggingItems(options:for:classes:searchOptions:using:). When enumerating, the system creates NSDraggingItem instances right before giving them to the enumeration block. After returning from the block, the dragging item is no longer valid.
 */
public class DraggingItem {
    private let item: NSDraggingItem
    
    /// The pasteboard content.
    public var content: Any { item.item }
    
    /**
     The frame of the dragging item.
     
     The dragging frame provides the spatial relationship between `DraggingItem` instances when you set the dragging formation to `none`.
     
     The exact coordinate space of this rectangle depends on where you use it. Examples are the view that initiates the drag using beginDraggingSession(with:event:source:) or the view you pass to the `DraggingSession` implementation of enumerateDraggingItems(options:for:classes:searchOptions:using:).
     */
    public var draggingFrame: CGRect {
        get { item.draggingFrame }
        set { item.draggingFrame = newValue }
    }
    
    public func setDraggingImage(_ image: NSImage, frame: CGRect? = nil) {
        self.imageComponents = [.icon(image, frame: frame)]
    }
    
    public func setDraggingImage(_ image: CGImage, frame: CGRect? = nil) {
        self.imageComponents = [.icon(image, frame: frame)]
    }
    
    public func setDraggingImage(_ view: NSView) {
        self.imageComponents = [.icon(view)]
    }
    
    /**
     An array of dragging image components to use to create the drag image.
     
     The array contains copies of the components. The drag does not reflect changes you make to these copies. If needed, the system calls the ``imageComponentsProvider`` block to generate the image components.
     */
    public var imageComponents: [ImageComponent]? {
        get { imageComponentsProvider?() }
        set {
            if let newValue = newValue {
                imageComponentsProvider = { newValue }
            } else {
                imageComponentsProvider = nil
            }
        }
    }
    
    /**
     An array of blocks that provide the dragging image components.
     
     The dragging image is the composite of an array of ``ImageComponent``.
     
     The dragging image components aren’t set directly. Instead, use a block to generate the components and the system calls the block if necessary.
     
     You can set the block to `nil`, meaning that the drag item has no image. Generally, only dragging destinations do this, and only if there’s at least one valid item in the drop, and the receiver isn’t that object.
     
     The system arranges the components in painting order. That is, the system paints each component in the array on top of the previous components in the array.
     */
    public var imageComponentsProvider: (() -> [ImageComponent])? = nil
    
    /// Keys that identify components of a dragging image.
    public struct ImageComponentKey: Hashable, RawRepresentable, ExpressibleByStringLiteral {
        public let rawValue: String
        
        /// A key for a corresponding value that is a dragging item’s image.
        public static let icon = ImageComponentKey("icon")
        
        /// A key for a corresponding value that represents a textual label for a dragging item, for example, a file name.
        public static let label = ImageComponentKey("label")
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
    }
    
    public struct ImageComponent: Hashable {
        /**
         The name of this image component.
         
         The key must be unique for each component in an `DraggingItem` instance.
         
         When an `DraggingItem` instances `imageComponents` are changed by one of the enumerateDraggingItemsWithOptions:forView:classes:searchOptions:usingBlock: methods the image associated with this key is morphed into the new image component’s image associated with the same key.
         */
        public var key: ImageComponentKey {
            get { .init(component.key.rawValue) }
            set { component.key = .init(newValue.rawValue) }
        }
        
        /// The image of the component.
        public var image: NSImage? {
            get { component.contents as? NSImage }
            set { component.contents = newValue }
        }
        
        /**
         The coordinate space is the bounds of the parent dragging item.
         
         The frame is `[[0,0], [draggingFrame.size.width, draggingFrame.size.height]]`.
         
         The coordinate space is the `bounds` of the parent `DraggingItem` instance’s `draggingFrame`.
         */
        public var frame: CGRect {
            get { component.frame }
            set { component.frame = newValue }
        }
        
        var component: NSDraggingImageComponent
        
        init(_ component: NSDraggingImageComponent) {
            self.component = component
        }
        
        /// Initializes and returns a dragging image component with the specified key, image and frame.
        public init(key: ImageComponentKey = .icon, image: NSImage? = nil, frame: CGRect? = nil) {
            component = NSDraggingImageComponent(key: .init(key.rawValue), image: image, frame: frame)
        }
        
        /// Initializes and returns a dragging image component with the specified key, image and frame.
        public init(key: ImageComponentKey = .icon, image: CGImage, frame: CGRect? = nil) {
            component = NSDraggingImageComponent(key: .init(key.rawValue), image: image, frame: frame)
        }
        
        /// Initializes and returns a dragging image component with the specified key, view and frame.
        public init(key: ImageComponentKey = .icon, view: NSView) {
            component = NSDraggingImageComponent(key: .init(key.rawValue), view: view)

        }
        
        /// Creates an icon dragging image component with the specified image.
        public static func icon(_ image: NSImage? = nil, frame: CGRect? = nil) -> Self {
            Self(key: .icon, image: image, frame: frame)
        }
        
        /// Creates an icon dragging image component with the specified image.
        public static func icon(_ image: CGImage, frame: CGRect? = nil) -> Self {
            Self(key: .icon, image: image, frame: frame)
        }
        
        /// Creates an icon dragging image component with an image of the specified view.
        public static func icon(_ view: NSView) -> Self {
            Self(key: .icon, view: view)
        }
        
        /// Creates a label dragging image component with the specified image.
        public static func label(_ image: NSImage? = nil, frame: CGRect? = nil) -> Self {
            Self(key: .label, image: image, frame: frame)
        }
        
        /// Creates a label dragging image component with the specified image.
        public static func label(_ image: CGImage, frame: CGRect? = nil) -> Self {
            Self(key: .label, image: image, frame: frame)
        }
        
        /// Creates a label dragging image component with an image of the specified view.
        public static func label(_ view: NSView) -> Self {
            Self(key: .label, view: view)
        }
    }
    
    init(_ item: NSDraggingItem) {
        self.item = item
        guard let provider = item.imageComponentsProvider else { return }
        imageComponentsProvider = {
            provider().map({ImageComponent($0)})
        }
    }
    
    init(content: PasteboardWriting) {
        self.item = .init(content)
    }
    
    init(content: PasteboardWriting, image: NSImage, frame: CGRect? = nil) {
        self.item = .init(content)
        self.setDraggingImage(image, frame: frame)
    }
    
    init(content: PasteboardWriting, image: CGImage, frame: CGRect? = nil) {
        self.item = .init(content)
        self.setDraggingImage(image, frame: frame)
    }
    
    init(content: PasteboardWriting, view: NSView) {
        self.item = .init(content)
        self.setDraggingImage(view)
    }
}

#endif
*/
