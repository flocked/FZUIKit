//
//  NSPasteboard+.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
import AppKit

public extension NSPasteboard {
    func write(_ string: String) {
        self.clearContents()
        self.setString(string, forType: .string)
    }
    
    func write(_ images: [NSImage]) {
        self.clearContents()
        let writings = images.compactMap({$0 as NSPasteboardWriting})
        self.writeObjects(writings)
    }
    
    func write(_ urls: [URL]) {
        self.clearContents()
        let writings = urls.compactMap({$0 as NSPasteboardWriting})
        self.writeObjects(writings)
    }
    
    func images() -> [NSImage]? {
        guard let images = readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage] else {
            return nil
        }
        return images.count == 0 ? nil : images
    }
    
    func string() -> String? {
        return self.pasteboardItems?.compactMap({$0.string(forType: .string)}).first
    }
    
    func fileURLs() -> [URL]? {
        guard let objs = self.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL] else {
            return nil
        }
        let urls = objs.compactMap { $0 as URL }
        return urls.count == 0 ? nil : urls
    }
}

public extension NSDraggingInfo {
    func images() -> [NSImage]? {
        self.draggingPasteboard.images()
    }
    
    func string() -> String? {
        self.draggingPasteboard.string()
    }
    
    func fileURLs() -> [URL]? {
        self.draggingPasteboard.fileURLs()
    }
}
#endif
