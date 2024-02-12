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
    func writeToPasteboard() {
        NSPasteboard.general.write([self])
    }
}

extension NSDraggingItem {
    /// Creates and returns a dragging item using the specified content.
    public convenience init(_ content: PasteboardContent) {
        self.init(pasteboardWriter: content.pasteboardWriting)
    }
}

    public extension Collection where Element == (any PasteboardContent) {
        /// Writes the objects to the the specified pasteboard.
        func writeToPasteboard(_ pasteboard: NSPasteboard = .general) {
            pasteboard.write(self)
        }
        
        var strings: [String] {
            compactMap({$0 as? String})
        }
        
        var images: [NSImage] {
            compactMap({$0 as? NSImage})
        }
        
        var urls: [URL] {
            compactMap({$0 as? URL})
        }
        
        var fileURLs: [URL] {
            urls.filter({$0.isFileURL})
        }
                
        var sounds: [NSSound] {
            compactMap({$0 as? NSSound})
        }
        
        var colors: [NSColor] {
            compactMap({$0 as? NSColor})
        }
        
        var attributedStrings: [NSAttributedString] {
            compactMap({$0 as? NSAttributedString})
        }
        
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
            
            if let pasteboardItems = pasteboardItems?.filter({$0.content != nil}) {
                items.append(contentsOf: pasteboardItems)
            }

            return items
        }
    }

    public extension NSDraggingInfo {
        /// The current `PasteboardContent` objects of the dragging info.
        func content() -> [PasteboardContent] {
            draggingPasteboard.content()
        }
    }

#endif
