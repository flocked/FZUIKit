//
//  NSDraggingSession+.swift
//
//
//  Created by Florian Zand on 01.02.25.
//

#if os(macOS)
import AppKit

extension NSDraggingSession {
    /// The source of the drag.
    public var source: NSDraggingSource {
        value(forKey: "_source") as! NSDraggingSource
    }
    
    /// The start location of the drag.
    public var startLocation: CGPoint {
        value(forKey: "startLocation") as! CGPoint
    }

    /// The current destination window of the drag.
    public var destinationWindow: NSWindow? {
        NSApp.windows.first(where: { $0.frame.contains(draggingLocation)})
    }
    
    
    /// The current destination window location of the drag.
    public var destinationWindowLocation: CGPoint? {
        guard let window = destinationWindow else { return nil }
        return window.convertPoint(fromScreen: draggingLocation)
    }
    
    /// The current destination view of the drag.
    public var destinationView: NSView? {
        guard let window = destinationWindow, let contentView = window.contentView else { return nil }
        return contentView.hitTest(contentView.convertFromWindow(window.convertPoint(fromScreen: draggingLocation))) ?? contentView
    }
    
    /// The current destination view location of the drag.
    public var destinationViewLocation: CGPoint? {
        guard let window = destinationWindow, let contentView = window.contentView else { return nil }
        let location = contentView.convertFromWindow(window.convertPoint(fromScreen: draggingLocation))
        if let view = contentView.hitTest(location) {
            return contentView.convert(location, to: view)
        }
        return location
    }
    
    /// The destination of a drag.
    public enum Destination {
        /// Source view.
        case source
        /// Application.
        case application
        /// Outside application.
        case outsideApplication
    }
    
    /// The current destination of the drag.
    public var destination: Destination {
        guard destinationWindow != nil else { return .outsideApplication }
        if let view = destinationView, (source as? NSView) === view {
            return .source
        }
        return .application
    }
    
    /**
     Sets the image components of the dragging items provided by the handler.
     
     - Parameters:
        - readings: The types that the dragging items represent.
        - handler: The handler that provides image components for the dragging items.
     */
    public func setDraggingItemImageComponents(for types: [PasteboardReading.Type]? = nil, handler: @escaping (_ item: NSDraggingItem, _ imageComponents: [NSDraggingImageComponent]?)->([NSDraggingImageComponent]?)) {
        var classes: [AnyClass] = []
            for reading in types ?? [] {
                if let reading = reading as? NSPasteboardReading.Type {
                    classes.append(reading)
                } else if reading is String.Type {
                    classes.append(NSString.self)
                } else if reading is URL.Type {
                    classes.append(NSURL.self)
                }
                if #available(macOS 12, *) {
                    if reading is AttributedString.Type {
                        classes.append(NSString.self)
                    }
                }
            }
        if classes.isEmpty {
            classes.append(NSPasteboardItem.self)
        }
        enumerateDraggingItems(for: nil, classes: classes) { item, index, shouldStop in
            if let imageComponents = handler(item, item.imageComponents) {
                item.imageComponentsProvider = { imageComponents }
            }
        }
    }
}
#endif
