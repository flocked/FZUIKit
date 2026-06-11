//
//  NSDraggingItem+.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSDraggingItem {
    /**
     Creates a dragging item for the specified content.

     - Parameter content: The content of the dragging item.
     */
    convenience init(for content: [any NSPasteboardWriting]) {
        self.init(pasteboardWriter: NSPasteboardItem(content: content, for: .drag))
    }
    
    /**
     Creates a dragging item for the specified content.

     - Parameter content: The content of the dragging item.
     */
    @_disfavoredOverload
    convenience init(for content: [any PasteboardWriting]) {
        self.init(for: content.map({$0.pasteboardWriting}))
    }
    
    /**
     Creates a dragging item using the specified content and view.
     
     - Parameters:
        - content: The content of the dragging item.
        - View: he view associated with the dragging item. When beginning a dragging session, an image representation of the view is used as dragging image.
     */
    convenience init(for content: PasteboardWriting, view: NSView) {
        self.init(for: content.pasteboardWriting, view: view)
    }
    
    /**
     Creates a dragging item using the specified content and view.
     
     - Parameters:
        - content: The content of the dragging item.
        - View: he view associated with the dragging item. When beginning a dragging session, an image representation of the view is used as dragging image.
     */
    convenience init(for content: NSPasteboardWriting, view: NSView) {
        self.init(pasteboardWriter: content)
        self.view = view
    }
    
    /**
     Creates a dragging item using the specified content and view.
     
     - Parameters:
        - content: The content of the dragging item.
        - View: he view associated with the dragging item. When beginning a dragging session, an image representation of the view is used as dragging image.
     */
    convenience init(for content: [any NSPasteboardWriting], view: NSView) {
        self.init(for: content)
        self.view = view
    }
    
    /**
     Creates a dragging item using the specified content and view.
     
     - Parameters:
        - content: The content of the dragging item.
        - View: he view associated with the dragging item. When beginning a dragging session, an image representation of the view is used as dragging image.
     */
    @_disfavoredOverload
    convenience init(for content: [any PasteboardWriting], view: NSView) {
        self.init(for: content.map({$0.pasteboardWriting}), view: view)
    }
    
    /**
     The view associated with the dragging item that provides the dragging image.
     
     When a dragging session begins an image representation of the view is used to provide the dragging image.
     */
    var view: NSView? {
        get { getAssociatedValue("_view") }
        set {
            setAssociatedValue(weak: newValue, key: "_view")
            guard newValue != nil else { return }
            NSView.swizzleBeginDraggingSession()
        }
    }
    
    /**
     Sets the item’s dragging image.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    func setDraggingImage(_ image: NSImage, frame: CGRect? = nil) {
        setDraggingFrame(frame ?? image.size.rect, contents: image)
    }
    
    /**
     Sets the item’s dragging image.
     
     - Parameters:
        - image: The dragging image.
        - frame: The dragging image frame.
     */
    func setDraggingImage(_ image: CGImage, frame: CGRect? = nil) {
        setDraggingFrame(frame ?? image.size.rect, contents: image)
    }
    
    /// Sets the item’s dragging image using a rendered snapshot of the specified view.
    func setDraggingImage(view: NSView) {
        setDraggingImage(view.renderedImage)
    }
    
    /**
     Sets multiple images to be displayed for this dragging item using explicit frames.

     The dragging frame is automatically calculated as the union of all image frames.

     - Parameter images: The images and their corresponding frames in the coordinate space of the dragging item.
     */
    func setDraggingImages(_ images: [(image: NSImage, frame: CGRect)]) {
        guard !images.isEmpty else { return }
        let draggingFrame = images.map({$0.frame}).union()
        setDraggingFrame(draggingFrame, contents: nil)
        let images = images.map { NSDraggingImageComponent.icon($0, frame: CGRect(CGPoint($1.minX - draggingFrame.minX, $1.minY - draggingFrame.minY), $1.size)) }
        imageComponentsProvider = { images }
    }
    
    /**
     Sets multiple images to be displayed for this dragging item using explicit frames.

     The dragging frame is automatically calculated as the union of all image frames.

     - Parameter images: The images and their corresponding frames in the coordinate space of the dragging item.
     */
    func setDraggingImages(_ images: [(image: CGImage, frame: CGRect)]) {
        setDraggingImages(images.map({ ($0.image.nsImage, $0.frame) }))
    }
    
    /**
     Sets multiple images to be displayed for this dragging item.

     Images may be arranged horizontally, vertically, or overlap depending on the specified direction. The resulting dragging frame is automatically calculated from the image positions.

     - Parameters:
       - images: The images to display while dragging.
       - origin: The corner used to position the image arrangement within the combined dragging frame.
       - direction: The direction in which images are arranged,  or `nil` to position all images at the same location so they overlap completely.
     */
    func setDraggingImages(_ images: [NSImage], from origin: ImageOrigin = .bottomLeft, direction: ImageAlignment? = nil) {
        var cursor: CGFloat = 0
        var imageFrames = images.map { image in
            var frame = image.size.rect
            switch direction {
            case nil: break
            case .horizontal:
                frame.origin = CGPoint(x: cursor, y: 0)
                cursor += image.size.width
            case .vertical:
                frame.origin = CGPoint(x: 0, y: cursor)
                cursor += image.size.height
            }
            return (image: image, frame: frame)
        }
        let bounds = imageFrames.map({$0.frame}).union()
        imageFrames = imageFrames.map { image, frame in
            var adjusted = frame
            switch origin {
            case .bottomLeft: break
            case .bottomRight:
                adjusted.origin.x = bounds.maxX - frame.maxX
            case .topLeft:
                adjusted.origin.y = bounds.maxY - frame.maxY
            case .topRight:
                adjusted.origin.x = bounds.maxX - frame.maxX
                adjusted.origin.y = bounds.maxY - frame.maxY
            }
            return (image, adjusted)
        }
        setDraggingImages(imageFrames)
    }
    
    /**
     Sets multiple images to be displayed for this dragging item.

     Images may be arranged horizontally, vertically, or overlap depending on the specified direction. The resulting dragging frame is automatically calculated from the image positions.

     - Parameters:
       - images: The images to display while dragging.
       - origin: The corner used to position the image arrangement within the combined dragging frame.
       - direction: The direction in which images are arranged,  or `nil` to position all images at the same location so they overlap completely.
     */
    func setDraggingImages(_ images: [CGImage], from origin: ImageOrigin = .bottomLeft, direction: ImageAlignment? = nil) {
        setDraggingImages(images.map({$0.nsImage}), from: origin, direction: direction)
    }
    
    /// The corner from which multiple drag images are positioned.
    enum ImageOrigin {
        /// Positions images relative to the bottom-left corner of the combined dragging frame.
        case bottomLeft
        /// Positions images relative to the bottom-right corner of the combined dragging frame.
        case bottomRight
        /// Positions images relative to the top-left corner of the combined dragging frame.
        case topLeft
        /// Positions images relative to the top-right corner of the combined dragging frame.
        case topRight
    }

    /// The direction in which multiple drag images are arranged.
    enum ImageAlignment {
        /// Arranges images from left to right.
        case vertical
        /// Arranges images from bottom to top.
        case horizontal
    }
}

fileprivate extension NSView {
    static func swizzleBeginDraggingSession() {
        guard !isInstanceMethodHooked(#selector(NSView.beginDraggingSession(with:event:source:))) else { return }
        do {
            try NSView.hook(all: #selector(NSView.beginDraggingSession(with:event:source:)), closure: { original, view, selector, items, event, source in
                for item in items {
                    guard let itemView = item.view else { continue }
                    var components = item.imageComponentsProvider?() ?? []
                    guard !components.contains(where: {$0.key == .renderedView }) else { continue }
                    let bounds = (itemView as? NSImageView)?.imageBounds ?? (itemView as? ImageView)?.imageBounds ?? itemView.bounds
                    let image = (itemView as? NSImageView)?.image ?? (itemView as? ImageView)?.image ?? itemView.renderedImage
                    let frame = itemView.convert(bounds, to: view)
                    components += .init(key: .renderedView, image: image, frame: bounds)
                    item.draggingFrame = frame
                    item.imageComponentsProvider = { components }
                }
                return original(view, selector, items, event, source)
            } as @convention(block) ((NSView, Selector, [NSDraggingItem], NSEvent, any NSDraggingSource) -> NSDraggingSession, NSView, Selector, [NSDraggingItem], NSEvent, any NSDraggingSource) -> NSDraggingSession)
        } catch {
            Swift.print(error)
        }
    }
}

fileprivate extension NSDraggingItem.ImageComponentKey {
    static let renderedView = Self.init("renderedView")
}

#endif
