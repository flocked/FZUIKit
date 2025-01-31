//
//  PasteboardWriting.swift
//  
//
//  Created by Florian Zand on 31.01.25.
//

#if os(macOS)
import AppKit

public protocol PasteboardWriting {
    /// A representation of the content that can be written to a pasteboard.
    var pasteboardWriting: NSPasteboardWriting { get }
}

extension PasteboardWriting where Self: NSPasteboardWriting {
    public var pasteboardWriting: NSPasteboardWriting {
        self as NSPasteboardWriting
    }
}

public extension NSPasteboard {
    /**
     Writes the specified `PasteboardWriting` objects to the pasteboard.
     
     - Parameter objects: An array of `PasteboardWriting` objects.
     */
    func write<O: Collection<PasteboardWriting>>(_ objects: O) {
        guard objects.isEmpty == false else { return }
        clearContents()
        let writings = objects.compactMap(\.pasteboardWriting)
        writeObjects(writings)
    }
}

extension NSString: PasteboardWriting { }
extension NSAttributedString: PasteboardWriting { }
extension NSURL: PasteboardWriting { }
extension NSColor: PasteboardWriting { }
extension NSImage: PasteboardWriting { }
extension NSSound: PasteboardWriting { }
extension NSFilePromiseProvider: PasteboardWriting { }
extension NSPasteboardItem: PasteboardWriting { }

extension String: PasteboardWriting {
    public var pasteboardWriting: NSPasteboardWriting {
        self as NSPasteboardWriting
    }
}

@available(macOS 12, *)
extension AttributedString: PasteboardWriting {
    public var pasteboardWriting: NSPasteboardWriting {
        NSAttributedString(self).pasteboardWriting
    }
}

extension URL: PasteboardWriting {
    public var pasteboardWriting: NSPasteboardWriting {
        self as NSPasteboardWriting
    }
}

public extension Collection where Element == (any PasteboardWriting) {
    /// The strings of the pasteboard content.
    var strings: [String] {
        compactMap({$0 as? String})
    }
    
    /// The attributed strings of the pasteboard content.
    var attributedStrings: [NSAttributedString] {
        compactMap({$0 as? NSAttributedString})
    }
    
    /// The images of the pasteboard content.
    var images: [NSImage] {
        compactMap({$0 as? NSImage})
    }
    
    /// The urls of the pasteboard content.
    var urls: [URL] {
        compactMap({$0 as? URL}).filter({ !$0.isFileURL })
    }
    
    /// The file urls of the pasteboard content.
    var fileURLs: [URL] {
        compactMap({$0 as? URL}).filter({ $0.isFileURL })
    }
    
    /// The sounds of the pasteboard content.
    var sounds: [NSSound] {
        compactMap({$0 as? NSSound})
    }
    
    /// The colors of the pasteboard content.
    var colors: [NSColor] {
        compactMap({$0 as? NSColor})
    }
    
    /// The file promise providers of the pasteboard content.
    var filePromiseProviders: [NSFilePromiseProvider] {
        compactMap({$0 as? NSFilePromiseProvider})
    }
    
    /// The pasteboard items of the pasteboard content.
    var pasteboardItems: [NSPasteboardItem] {
        compactMap({$0 as? NSPasteboardItem})
    }
    
    func content<Content: Codable>(_ content: Content.Type) -> [Content] {
        pasteboardItems.compactMap({$0.content(content)})
    }
}

extension NSDraggingItem {
    /// Creates and returns a dragging item using the specified content.
    public convenience init(_ content: PasteboardWriting) {
        self.init(pasteboardWriter: content.pasteboardWriting)
    }
}

extension NSPasteboardItem {
    /// Creates a pasteboard item with the specified content.
    public convenience init(content: PasteboardWriting) {
        self.init(content: [content])
    }
    
    /// Creates a pasteboard item with the specified content.
    public convenience init(content: [PasteboardWriting]) {
        self.init()
        tiffImage = content.images.first
        url = content.urls.first
        fileURL = content.fileURLs.first
        color = content.colors.first
        string = content.strings.first
        attributedString = content.attributedStrings.first
        sound = content.sounds.first
    }
}
#endif
