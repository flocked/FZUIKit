//
//  NSPasteboard+PasteboardContent.swift
//
//
//  Created by Florian Zand on 31.12.23.
//

#if os(macOS)
import AppKit

/// A type that can be written to a pasteboard.
public protocol PasteboardContent {
    /// A representation of the content that can be written to a pasteboard.
    var pasteboardWriting: NSPasteboardWriting { get }
}

extension PasteboardContent where Self: NSPasteboardWriting {
    public var pasteboardWriting: NSPasteboardWriting {
        self as NSPasteboardWriting
    }
}

extension NSString: PasteboardContent { }
extension NSAttributedString: PasteboardContent { }
extension NSURL: PasteboardContent { }
extension NSColor: PasteboardContent { }
extension NSImage: PasteboardContent { }
extension NSSound: PasteboardContent { }
extension NSFilePromiseProvider: PasteboardContent { }
extension NSPasteboardItem: PasteboardContent { }

extension String: PasteboardContent {
    public var pasteboardWriting: NSPasteboardWriting {
        self as NSPasteboardWriting
    }
}

@available(macOS 12, *)
extension AttributedString: PasteboardContent {
    public var pasteboardWriting: NSPasteboardWriting {
        NSAttributedString(self).pasteboardWriting
    }
}

extension URL: PasteboardContent {
    public var pasteboardWriting: NSPasteboardWriting {
        self as NSPasteboardWriting
    }
}

public extension PasteboardContent {
    /// Writes the object to the the general pasteboard.
    func writeToPasteboard(_ pasteboard: NSPasteboard = .general) {
        pasteboard.write([self])
    }
}

extension NSDraggingItem {
    /// Creates and returns a dragging item using the specified content.
    public convenience init(_ content: PasteboardContent) {
        self.init(pasteboardWriter: content.pasteboardWriting)
    }
}

class TestClass: NSPasteboardItem {
    func tes() {
        TestClass.init(content: [])
    }
}

extension NSPasteboardItem {
    /// Creates a pasteboard item with the specified content.
    public convenience init(content: PasteboardContent) {
        self.init(content: [content])
    }
    
    /// Creates a pasteboard item with the specified content.
    public convenience init(content: [PasteboardContent]) {
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

public extension Collection where Element == (any PasteboardContent) {
    /// Writes the objects to the the specified pasteboard.
    func writeToPasteboard(_ pasteboard: NSPasteboard = .general) {
        pasteboard.write(self)
    }
    
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
        compactMap({$0 as? URL})
    }
    
    /// The file urls of the pasteboard content.
    var fileURLs: [URL] {
        urls.filter({$0.isFileURL})
    }
    
    /// The sounds of the pasteboard content.
    var sounds: [NSSound] {
        compactMap({$0 as? NSSound})
    }
    
    /// The colors of the pasteboard content.
    var colors: [NSColor] {
        compactMap({$0 as? NSColor})
    }
    
    /// The pasteboard items of the pasteboard content.
    var pasteboardItems: [NSPasteboardItem] {
        compactMap({$0 as? NSPasteboardItem})
    }
    
    func content<Content: Codable>(_ content: Content.Type) -> [Content] {
        pasteboardItems.compactMap({$0.content(content)})
    }
}

public extension Collection where Element: PasteboardContent {
    /// Writes the objects to the the specified pasteboard.
    func writeToPasteboard(_ pasteboard: NSPasteboard = .general) {
        pasteboard.write(Array(self))
    }
}

public extension NSPasteboard {
    /**
     Writes the specified `PasteboardContent` objects to the pasteboard.
     
     - Parameter objects: An array of `PasteboardContent` objects.
     */
    func write<O: Collection<PasteboardContent>>(_ objects: O) {
        guard objects.isEmpty == false else { return }
        clearContents()
        let writings = objects.compactMap(\.pasteboardWriting)
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
        
        if let attributedStrings = attributedStrings {
            items.append(contentsOf: attributedStrings)
        }
        
        let pasteboardItems = (pasteboardItems ?? []).filter({ !$0.types.contains(any: [.color, .string, .rtf, .sound, .fileURL, .URL, .tiff, .png]) || $0.content != nil })
        items.append(contentsOf: pasteboardItems)
        
        return items
    }
}

#endif
