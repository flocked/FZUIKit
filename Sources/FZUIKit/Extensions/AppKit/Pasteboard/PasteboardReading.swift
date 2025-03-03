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
     /// A representation of the content that can be read from a pasteboard.
     var pasteboardReading: NSPasteboardReading { get }
     
     /// The class type used for pasteboard reading.
     static var pasteboardReadingType: NSPasteboardReading.Type { get }
 }

 extension PasteboardReading where Self: NSPasteboardReading {
     public var pasteboardReading: NSPasteboardReading {
         self as NSPasteboardReading
     }
     
     public static var pasteboardReadingType: NSPasteboardReading.Type { self }
 }

 extension NSString: PasteboardReading { }
 extension NSAttributedString: PasteboardReading { }
 extension NSURL: PasteboardReading { }
 extension NSColor: PasteboardReading { }
 extension NSImage: PasteboardReading { }
 extension NSSound: PasteboardReading { }
 extension NSFilePromiseReceiver: PasteboardReading { }
 extension NSPasteboardItem: PasteboardReading { }

 extension String: PasteboardReading {
     public var pasteboardReading: NSPasteboardReading {
         self as NSPasteboardReading
     }
     
     public static var pasteboardReadingType: NSPasteboardReading.Type { NSString.self }
 }

 @available(macOS 12, *)
 extension AttributedString: PasteboardReading {
     public var pasteboardReading: NSPasteboardReading {
         NSAttributedString(self).pasteboardReading
     }
     
     public static var pasteboardReadingType: NSPasteboardReading.Type { NSAttributedString.self }
 }

 extension URL: PasteboardReading {
     public var pasteboardReading: NSPasteboardReading {
         self as NSPasteboardReading
     }
     
     public static var pasteboardReadingType: NSPasteboardReading.Type { NSURL.self }
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

 public extension NSPasteboard {
     /// The current `PasteboardReading` objects of the pasteboard.
     var content: [PasteboardReading] {
         return readAll() + (pasteboardItems ?? [])
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
