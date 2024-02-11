//
//  NSPasteboard+PasteboardContent.swift
//
//
//  Created by Florian Zand on 31.12.23.
//

#if os(macOS)
import AppKit

/// A type that can be read from and written to a pasteboard (`String`, `URL`, `NSColor`, `NSImage` or `NSSound`).
public protocol PasteboardContent {}

extension String: PasteboardContent {}
extension NSString: PasteboardContent {}
extension URL: PasteboardContent {}
extension NSURL: PasteboardContent {}
extension NSColor: PasteboardContent {}
extension NSImage: PasteboardContent {}
extension NSSound: PasteboardContent {}

public extension PasteboardContent {
    /// `URL` pasteboard content.
    static func url(_ url: URL) -> PasteboardContent {
        return url
    }
    
    /// `String` pasteboard content.
    static func string(_ string: String) -> PasteboardContent {
        return string
    }
    
    /// `NSColor` pasteboard content.
    static func color(_ color: NSColor) -> PasteboardContent {
        return color
    }
    
    /// `NSImage` pasteboard content.
    static func image(_ image: NSImage) -> PasteboardContent {
        return image
    }
    
    /// `NSSound` pasteboard content.
    static func sound(_ sound: NSSound) -> PasteboardContent {
        return sound
    }
}

public extension PasteboardContent {
    /// Writes the object to the the general pasteboard.
    func writeToPasteboard() {
        NSPasteboard.general.write([self])
    }
}

extension NSDraggingItem {
    /// Creates and returns a dragging item using the specified content.
    public convenience init(_ content: PasteboardContent) {
        self.init(pasteboardWriter: content.nsPasteboardWriting!)
    }
}

extension NSDragOperation {
    /// A constant that indicates the drag cancelled.
    public static var none = NSDragOperation(rawValue: 0)
}

extension NSDraggingImageComponent {
    /// Creates a dragging image component for the specified view.
    public convenience init(view: NSView) {
        self.init(key: .icon)
        contents = view.renderedImage
        frame.origin = .zero
        frame.size = view.bounds.size
    }
}

    public extension Collection where Element == (any PasteboardContent) {
        /// Writes the objects to the the general pasteboard.
        func writeToPasteboard() {
            NSPasteboard.general.write(self)
        }
    }

    public extension Collection where Element: PasteboardContent {
        /// Writes the objects to the the general pasteboard.
        func writeToPasteboard() {
            NSPasteboard.general.write(Array(self))
        }
    }

    extension PasteboardContent {
        var nsPasteboardWriting: NSPasteboardWriting? {
            (self as? NSPasteboardWriting) ?? (self as? NSURL)
        }
    }

    public extension NSPasteboard {
        /**
         Writes the specified `PasteboardContent` objects to the pasteboard.

         - Parameter objects: An array of `PasteboardContent` objects.
         */
        func write<O: Collection<PasteboardContent>>(_ objects: O) {
            guard objects.isEmpty != false else { return }
            clearContents()
            let writings = objects.compactMap(\.nsPasteboardWriting)
            writeObjects(writings)
        }

        /// The current `PasteboardContent` objects of the pasteboard.
        func content() -> [PasteboardContent] {
            var items: [PasteboardContent] = []

            if let fileURLs = fileURLs {
                items.append(contentsOf: fileURLs)
            }

            if let colors = colors {
                items.append(contentsOf: colors)
            }

            if let strings = strings {
                items.append(contentsOf: strings)
            }

            if let sounds = sounds {
                items.append(contentsOf: sounds)
            }

            if let images = images {
                items.append(contentsOf: images)
            }

            return items
        }
    }

    public extension NSDraggingInfo {
        /// The current `PasteboardContent` objects of the dragging info.
        func content() -> [PasteboardContent] {
            draggingPasteboard.content()
        }
    }

#endif
