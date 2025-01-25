//
//  DraggingItem.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit

/// A single dragged item within a dragging session.
class DraggingItem {
    let item: NSDraggingItem
    
    /// The content of the item.
    public let content: PasteboardContent
        
    /// The dragging image of the item.
    public var draggingImage: NSImage? {
        didSet {
            guard oldValue != draggingImage else { return }
            updateDraggingImage()
        }
    }
    
    /// The dragging image frame of the item.
    public var draggingImageFrame: CGRect? {
        didSet {
            guard oldValue != draggingImageFrame else { return }
            updateDraggingImage()
        }
    }
    
    func updateDraggingImage() {
        var components: [NSDraggingImageComponent] = []
        if let image = draggingImage {
            components = [NSDraggingImageComponent(image: image, frame: draggingImageFrame)]
        }
        item.imageComponentsProvider = { components }
    }
    
    /// Creates a dragging item with the specified pasteboard content.
    public init(_ content: PasteboardContent) {
        self.content = content
        self.item = .init(content)
    }
}
#endif
