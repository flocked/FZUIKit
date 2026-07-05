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

extension AttributedString: PasteboardWriting {
    public typealias PasteboardWritingType = NSAttributedString
    public var pasteboardWriting: NSPasteboardWriting { NSAttributedString(self) }
}

public extension Sequence where Element == any PasteboardWriting {
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
    public convenience init(_ pasteboardWriter: PasteboardWriting) {
        self.init(pasteboardWriter: pasteboardWriter.pasteboardWriting)
    }
}

#endif
