//
//  PasteboardReading.swift
//
//
//  Created by Florian Zand on 11.02.24.
//

/*
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
extension NSPasteboardItem: PasteboardReading { }
extension NSFilePromiseReceiver: PasteboardReading { }

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

#endif
*/
