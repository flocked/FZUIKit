//
//  NSPasteboard+PasteboardReadWriting.swift
//
//
//  Created by Florian Zand on 31.12.23.
//

#if os(macOS)
import AppKit

/// A type that can be read from and written to a pasteboard (`String`, `URL`, `NSColor`, `NSImage` or `NSSound`).
public protocol PasteboardReadWriting { }

extension String: PasteboardReadWriting { }
extension URL: PasteboardReadWriting { }
extension NSColor: PasteboardReadWriting { }
extension NSImage: PasteboardReadWriting { }
extension NSSound: PasteboardReadWriting { }

extension PasteboardReadWriting {
    /// Writes the object to the the general pasteboard.
    public func writeToPasteboard() {
        NSPasteboard.general.write([self])
    }
}

extension Collection where Element == (any PasteboardReadWriting) {
    /// Writes the objects to the the general pasteboard.
    public func writeToPasteboard() {
        NSPasteboard.general.write(self)
    }
}

extension Collection where Element: PasteboardReadWriting {
    /// Writes the objects to the the general pasteboard.
    public func writeToPasteboard() {
        NSPasteboard.general.write(Array(self))
    }
}

extension PasteboardReadWriting {
    var nsPasteboardWriting: NSPasteboardWriting? {
        return (self as? NSPasteboardWriting) ?? (self as? NSURL)
    }
}

extension NSPasteboard {
    /**
     Writes the specified `PasteboardReadWriting` objects to the pasteboard.
     
     - Parameter objects: An array of `PasteboardReadWriting` objects.
     */
    public func write<O: Collection<PasteboardReadWriting>>(_ objects: O) {
        guard objects.isEmpty != false else { return }
        self.clearContents()
        let writings = objects.compactMap({$0.nsPasteboardWriting})
        self.writeObjects(writings)
    }

    /// The current `PasteboardReadWriting` objects of the pasteboard.
    public func pasteboardReadWritings() -> [PasteboardReadWriting] {
        var items: [PasteboardReadWriting] = []

        if let fileURLs = self.fileURLs {
            items.append(contentsOf: fileURLs)
        }

        if let color = self.color {
            items.append(color)
        }

        if let string = self.string {
            items.append(string)
        }

        if let sound = self.sound {
            items.append(sound)
        }

        if let images = self.images {
            items.append(contentsOf: images)
        }

        return items
    }
}

extension NSDraggingInfo {
    /// The current `PasteboardReadWriting` objects of the dragging info.
    public func pasteboardReadWritings() -> [PasteboardReadWriting] {
        return self.draggingPasteboard.pasteboardReadWritings()
    }
}

#endif
