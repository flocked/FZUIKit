//
//  PasteboardWriting.swift
//  
//
//  Created by Florian Zand on 31.01.25.
//

#if os(macOS)
import AppKit
/// A type that can be written to a pasteboard.
public protocol PasteboardWriting {
    typealias PasteboardWritingType = NSPasteboardWriting
    var pasteboardWriting: NSPasteboardWriting { get }
}

extension PasteboardWriting where Self: NSPasteboardWriting {
    public typealias PasteboardWritingType = Self
    public var pasteboardWriting: NSPasteboardWriting { self }
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
    public typealias PasteboardWritingType = NSString
    public var pasteboardWriting: NSPasteboardWriting { self as NSString }
}

extension URL: PasteboardWriting {
    public typealias PasteboardWritingType = NSURL
    public var pasteboardWriting: NSPasteboardWriting { self as NSURL }
}

@available(macOS 12, *)
extension AttributedString: PasteboardWriting {
    public typealias PasteboardWritingType = NSAttributedString
    public var pasteboardWriting: NSPasteboardWriting { NSAttributedString(self) }
}

public extension NSPasteboard {
    /**
     Writes the specified `PasteboardWriting` objects to the pasteboard.
     
     - Parameter objects: An array of `PasteboardWriting` objects.
     */
    func write(_ objects: [any PasteboardWriting]) {
        guard objects.isEmpty == false else { return }
        clearContents()
        writeObjects(objects.compactMap(\.pasteboardWriting))
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
    public convenience init(content: [any PasteboardWriting]) {
        self.init()
        content.forEach({ setValue($0) })
    }
    
    func setValue(_ value: PasteboardWriting) {
        if let value = value as? String {
            string = value
        }
        if let value = value as? NSImage {
            tiffImage = value
        } else if let value = value as? URL {
            if value.isFileURL {
                fileURL = value
            } else {
                url = value
            }
        } else if let value = value as? NSColor {
            color = value
        } else if let value = value as? NSSound {
            sound = value
        } else if let value = value as? NSAttributedString {
            attributedString = value
        } else {
            for type in value.pasteboardWriting.writableTypes(for: .general) {
                if let propertyList = value.pasteboardWriting.pasteboardPropertyList(forType: type) {
                    setPropertyList(propertyList, forType: type)
                }
            }
        }
    }
}

#endif
