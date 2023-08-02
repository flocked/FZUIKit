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
     - Parameters string: The string to be written.
     */
    func write(_ string: String) {
        self.clearContents()
        self.setString(string, forType: .string)
    }
    
    /**
     Writes the specified images to the pasteboard.
     - Parameters images: An array of images.
     */
    func write(_ images: [NSImage]) {
        self.clearContents()
        let writings = images.compactMap({$0 as NSPasteboardWriting})
        self.writeObjects(writings)
    }
    
    /**
     Writes the specified urls to the pasteboard.
     - Parameters urls: An array of urls.
     */
    func write(_ urls: [URL]) {
        self.clearContents()
        let writings = urls.compactMap({$0 as NSPasteboardWriting})
        self.writeObjects(writings)
    }
    
    /**
     Returns images for the pasteboard.
     - Returns: The array of images or nil if no images are available.
     */
    func images() -> [NSImage]? {
        guard let images = readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage] else {
            return nil
        }
        return images.count == 0 ? nil : images
    }
    
    /**
     Returns a string for the pasteboard.
     - Returns: The string or nil if no string is available.
     */
    func string() -> String? {
        return self.pasteboardItems?.compactMap({$0.string(forType: .string)}).first
    }
    
    /**
     Returns file urls for the pasteboard.
     - Returns: The array of file urls or nil if no urls are available.
     */
    func fileURLs() -> [URL]? {
        guard let objs = self.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL] else {
            return nil
        }
        let urls = objs.compactMap { $0 as URL }
        return urls.count == 0 ? nil : urls
    }
}

public extension NSDraggingInfo {
    /**
     Returns images for the dragging info.
     - Returns: The array of images or nil if no images are available.
     */
    func images() -> [NSImage]? {
        self.draggingPasteboard.images()
    }
    
    /**
     Returns a string for thedragging info.
     - Returns: The string or nil if no string is available.
     */
    func string() -> String? {
        self.draggingPasteboard.string()
    }
    
    /**
     Returns file urls for the dragging info.
     - Returns: The array of file urls or nil if no urls are available.
     */
    func fileURLs() -> [URL]? {
        self.draggingPasteboard.fileURLs()
    }
}
#endif
