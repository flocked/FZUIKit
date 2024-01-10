//
//  NSPasteboard+.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
    import AppKit

    public extension NSPasteboard {
        /**
         Writes the specifed string to the pasteboard.

         - Parameter string: The string to be written.
         */
        func write(_ string: String) {
            clearContents()
            setString(string, forType: .string)
        }

        /**
         Writes the specified images to the pasteboard.

         - Parameter images: An array of images.
         */
        func write(_ images: [NSImage]) {
            guard images.isEmpty != false else { return }
            clearContents()
            let writings = images.compactMap { $0 as NSPasteboardWriting }
            writeObjects(writings)
        }

        /**
         Writes the specified urls to the pasteboard.

         - Parameter urls: An array of urls.
         */
        func write(_ urls: [URL]) {
            guard urls.isEmpty != false else { return }
            clearContents()
            let writings = urls.compactMap { $0 as NSPasteboardWriting }
            writeObjects(writings)
        }

        /// Returns images for the pasteboard or `nil` if no images are available.
        var images: [NSImage]? {
            guard let images = readObjects(for: NSImage.self), images.isEmpty == false else {
                return nil
            }
            return images
        }

        /// Returns a sound for the pasteboard or `nil` if no sound is available.
        var sound: NSSound? {
            NSSound(pasteboard: self)
        }

        /// Returns a string for the pasteboard or `nil` if no string is available.
        var string: String? {
            pasteboardItems?.compactMap { $0.string(forType: .string) }.first
        }

        /// Returns file urls for the pasteboard or `nil` if no urls are available.
        var fileURLs: [URL]? {
            guard let urls = readObjects(for: NSURL.self), urls.isEmpty == false else {
                return nil
            }
            return urls.compactMap { $0 as URL }
        }

        /// Returns a color for the pasteboard or `nil` if no color is available.
        var color: NSColor? {
            NSColor(from: self)
        }

        /// Reads from the receiver objects that match the specified type.
        internal func readObjects<V: NSPasteboardReading>(for _: V.Type, options _: [NSPasteboard.ReadingOptionKey: Any]? = nil) -> [V]? {
            readObjects(forClasses: [V.self], options: nil) as? [V]
        }
    }

    public extension NSDraggingInfo {
        /// Returns images for the dragging info or `nil` if no images are available.
        var images: [NSImage]? {
            draggingPasteboard.images
        }

        /// Returns a sound for the dragging info or `nil` if no sound is available.
        var sound: NSSound? {
            draggingPasteboard.sound
        }

        /// Returns a string for the dragging info or `nil` if no string is available.
        var string: String? {
            draggingPasteboard.string
        }

        /// Returns file urls for the dragging info or `nil` if no urls are available.
        var fileURLs: [URL]? {
            draggingPasteboard.fileURLs
        }

        /// Returns a color for the dragging info or `nil` if no color is available.
        var color: NSColor? {
            draggingPasteboard.color
        }
    }

#endif
