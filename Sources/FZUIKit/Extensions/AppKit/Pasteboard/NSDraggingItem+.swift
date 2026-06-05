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
     Creates and returns a dragging item using the specified content and view.
     
     - Parameters:
        - content: The content of the dragging item.
        - View: he view associated with the dragging item. When beginning a dragging session, an image representation of the view is used as dragging image.
     */
    convenience init(_ content: PasteboardWriting, view: NSView) {
        self.init(content.pasteboardWriting, view: view)
    }
    
    /**
     Creates and returns a dragging item using the specified content and view.
     
     - Parameters:
        - content: The content of the dragging item.
        - View: he view associated with the dragging item. When beginning a dragging session, an image representation of the view is used as dragging image.
     */
    convenience init(_ content: NSPasteboardWriting, view: NSView) {
        self.init(pasteboardWriter: content)
        self.view = view
        NSView.swizzleBeginDraggingSession()
    }
    
    /**
     The view associated with the dragging item.
     
     When beginning a new dragging session, an image representation of the view is used as dragging image.
     */
    var view: NSView? {
        get { getAssociatedValue("_view") }
        set { setAssociatedValue(weak: newValue, key: "_view") }
    }
}

fileprivate extension NSView {
    static func swizzleBeginDraggingSession() {
        guard !isMethodHooked(#selector(NSView.beginDraggingSession(with:event:source:))) else { return }
        do {
            try hook(all: #selector(NSView.beginDraggingSession(with:event:source:)), closure: { original, view, selector, items, event, source in
                for item in items {
                    guard let itemView = item.view else { continue }
                    var components = item.imageComponents ?? []
                    guard !components.contains(where: {$0.key == .view }) else { continue }
                    components += .init(key: .view, image: itemView.renderedImage, frame: itemView.convert(itemView.bounds, to: view))
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
    static let view = Self.init("renderedView")
}

#endif
