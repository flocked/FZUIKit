//
//  PasteboardReading.swift
//
//
//  Created by Florian Zand on 31.12.23.
//

#if os(macOS)
import AppKit

 /// A type that can be read from a pasteboard.
 public protocol PasteboardReading {
     /// A representation of the content that can be read from a pasteboard.
     var pasteboardReading: NSPasteboardReading { get }
 }

 extension PasteboardReading where Self: NSPasteboardReading {
     public var pasteboardReading: NSPasteboardReading {
         self as NSPasteboardReading
     }
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
 }

 @available(macOS 12, *)
 extension AttributedString: PasteboardReading {
     public var pasteboardReading: NSPasteboardReading {
         NSAttributedString(self).pasteboardReading
     }
 }

 extension URL: PasteboardReading {
     public var pasteboardReading: NSPasteboardReading {
         self as NSPasteboardReading
     }
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
     
     internal func content<Content: Codable>(_ content: Content.Type) -> [Content] {
         pasteboardItems.compactMap({$0.content(content)})
     }
 }

 public extension NSPasteboard {
     /// The current `PasteboardReading` objects of the pasteboard.
     func content() -> [PasteboardReading] {
         var items: [PasteboardReading] = []
         
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
         
         if let filePromiseReceivers = filePromiseReceivers {
             items.append(contentsOf: filePromiseReceivers)
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
