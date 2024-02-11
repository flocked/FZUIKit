//
//  NSPasteboard+PasteboardReadWriting.swift
//
//
//  Created by Florian Zand on 31.12.23.
//

#if os(macOS)
    import AppKit

    /// A type that can be read from and written to a pasteboard (`String`, `URL`, `NSColor`, `NSImage` or `NSSound`).
    public protocol PasteboardReadWriting {}

    extension String: PasteboardReadWriting {}
    extension URL: PasteboardReadWriting {}
    extension NSColor: PasteboardReadWriting {}
    extension NSImage: PasteboardReadWriting {}
    extension NSSound: PasteboardReadWriting {}

    public extension PasteboardReadWriting {
        /// Writes the object to the the general pasteboard.
        func writeToPasteboard() {
            NSPasteboard.general.write([self])
        }
    }

extension NSDraggingItem {
    /// Creates and returns a dragging item using the specified content.
    public convenience init(_ content: PasteboardReadWriting) {
        self.init(pasteboardWriter: content.nsPasteboardWriting!)
    }
}

    public extension Collection where Element == (any PasteboardReadWriting) {
        /// Writes the objects to the the general pasteboard.
        func writeToPasteboard() {
            NSPasteboard.general.write(self)
        }
    }

    public extension Collection where Element: PasteboardReadWriting {
        /// Writes the objects to the the general pasteboard.
        func writeToPasteboard() {
            NSPasteboard.general.write(Array(self))
        }
    }

    extension PasteboardReadWriting {
        var nsPasteboardWriting: NSPasteboardWriting? {
            (self as? NSPasteboardWriting) ?? (self as? NSURL)
        }
    }

    public extension NSPasteboard {
        /**
         Writes the specified `PasteboardReadWriting` objects to the pasteboard.

         - Parameter objects: An array of `PasteboardReadWriting` objects.
         */
        func write<O: Collection<PasteboardReadWriting>>(_ objects: O) {
            guard objects.isEmpty != false else { return }
            clearContents()
            let writings = objects.compactMap(\.nsPasteboardWriting)
            writeObjects(writings)
        }

        /// The current `PasteboardReadWriting` objects of the pasteboard.
        func pasteboardReadWritings() -> [PasteboardReadWriting] {
            var items: [PasteboardReadWriting] = []

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
        /// The current `PasteboardReadWriting` objects of the dragging info.
        func pasteboardReadWritings() -> [PasteboardReadWriting] {
            draggingPasteboard.pasteboardReadWritings()
        }
    }

#endif
