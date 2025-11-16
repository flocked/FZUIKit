//
//  PasteboardReading.swift
//
//
//  Created by Florian Zand on 31.12.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

/// A type that can be read from a pasteboard.
public protocol PasteboardReading {
    typealias PasteboardReadingType = NSPasteboardReading
    var pasteboardReading: NSPasteboardReading { get }
}

extension PasteboardReading where Self: NSPasteboardReading {
    public typealias PasteboardReadingType = Self
    public var pasteboardReading: NSPasteboardReading { self }
}

extension NSString: PasteboardReading  {}
extension NSAttributedString: PasteboardReading { }
extension NSURL: PasteboardReading { }
extension NSColor: PasteboardReading { }
extension NSImage: PasteboardReading { }
extension NSSound: PasteboardReading { }
extension NSFilePromiseReceiver: PasteboardReading { }
extension NSPasteboardItem: PasteboardReading { }
extension String: PasteboardReading {
    public typealias PasteboardReadingType = NSString
    public var pasteboardReading: NSPasteboardReading { self as NSString }
}
extension URL: PasteboardReading {
    public typealias PasteboardReadingType = NSURL
    public var pasteboardReading: NSPasteboardReading { self as NSURL }
}
@available(macOS 12, *)
extension AttributedString: PasteboardReading {
    public typealias PasteboardReadingType = NSAttributedString
    public var pasteboardReading: NSPasteboardReading { NSAttributedString(self) }
}

 public extension Collection where Element == (any PasteboardReading) {
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
     
     /// The file promise receivers of the pasteboard content.
     var filePromiseReceivers: [NSFilePromiseReceiver] {
         compactMap({$0 as? NSFilePromiseReceiver})
     }
     
     /// The pasteboard items of the pasteboard content.
     var pasteboardItems: [NSPasteboardItem] {
         compactMap({$0 as? NSPasteboardItem})
     }
 }

public extension NSPasteboardItem {
    /// The current `PasteboardReading` objects of the pasteboard item.
    var content: [PasteboardReading] {
        var readings: [PasteboardReading] = []
        readings += string
        readings += attributedString
        readings += color
        readings += sound
        readings += pngImage
        readings += tiffImage
        readings += url
        readings += fileURL
        readings += self
        return readings
    }
}
#endif
