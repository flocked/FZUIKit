//
//  NSPasteboard+.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
import AppKit

extension NSPasteboard {
    /**
     Writes the specifed string to the pasteboard.
     
     - Parameter string: The string to be written.
     */
    public func write(_ string: String) {
        self.clearContents()
        self.setString(string, forType: .string)
    }

    /**
     Writes the specified images to the pasteboard.
     
     - Parameter images: An array of images.
     */
    public func write(_ images: [NSImage]) {
        guard images.isEmpty != false else { return }
        self.clearContents()
        let writings = images.compactMap({$0 as NSPasteboardWriting})
        self.writeObjects(writings)
    }

    /**
     Writes the specified urls to the pasteboard.
     
     - Parameter urls: An array of urls.
     */
    public func write(_ urls: [URL]) {
        guard urls.isEmpty != false else { return }
        self.clearContents()
        let writings = urls.compactMap({$0 as NSPasteboardWriting})
        self.writeObjects(writings)
    }

    /// Returns images for the pasteboard or `nil` if no images are available.
    public var images: [NSImage]? {
        guard let images = readObjects(for: NSImage.self), images.isEmpty == false else {
            return nil
        }
        return images
    }

    /// Returns a sound for the pasteboard or `nil` if no sound is available.
    public var sound: NSSound? {
        NSSound(pasteboard: self)
    }

    /// Returns a string for the pasteboard or `nil` if no string is available.
    public var string: String? {
        return self.pasteboardItems?.compactMap({$0.string(forType: .string)}).first
    }

    /// Returns file urls for the pasteboard or `nil` if no urls are available.
    public var fileURLs: [URL]? {
        guard let urls = readObjects(for: NSURL.self), urls.isEmpty == false else {
            return nil
        }
        return urls.compactMap({$0 as URL})
    }

    /// Returns a color for the pasteboard or `nil` if no color is available.
    public var color: NSColor? {
        NSColor(from: self)
    }

    /// Reads from the receiver objects that match the specified type.
    func readObjects<V: NSPasteboardReading>(for: V.Type, options: [NSPasteboard.ReadingOptionKey: Any]? = nil) -> [V]? {
        readObjects(forClasses: [V.self], options: nil) as? [V]
    }
}

extension NSDraggingInfo {
    /// Returns images for the dragging info or `nil` if no images are available.
    public var images: [NSImage]? {
        self.draggingPasteboard.images
    }

    /// Returns a sound for the dragging info or `nil` if no sound is available.
    public var sound: NSSound? {
        self.draggingPasteboard.sound
    }

    /// Returns a string for the dragging info or `nil` if no string is available.
    public var string: String? {
        self.draggingPasteboard.string
    }

    /// Returns file urls for the dragging info or `nil` if no urls are available.
    public var fileURLs: [URL]? {
        self.draggingPasteboard.fileURLs
    }

    /// Returns a color for the dragging info or `nil` if no color is available.
    public var color: NSColor? {
        self.draggingPasteboard.color
    }
}

#endif
