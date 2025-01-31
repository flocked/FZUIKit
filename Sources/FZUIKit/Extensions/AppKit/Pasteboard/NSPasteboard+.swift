//
//  NSPasteboard+.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

#if os(macOS)
    import AppKit

    extension NSPasteboard {
        /// The string of the pasteboard or `nil` if no string is available.
        public var string: String? {
            get { strings?.first }
            set { strings = newValue != nil ? [newValue!] : [] }
        }
        
        /**
         The strings of the pasteboard or `nil` if no strings are available.
         
         Setting this property replaces all current items in the pasteboard with the new items.
         */
        public var strings: [String]? {
            get { read(for: NSString.self) as? [String] }
            set { write(newValue ?? []) }
        }
        
        /**
         The attributed strings of the pasteboard or `nil` if no attributed strings are available.
         
         Setting this property replaces all current items in the pasteboard with the new items.
         */
        public var attributedStrings: [NSAttributedString]? {
            get { read(for: NSAttributedString.self) }
            set { write(newValue ?? []) }
        }
        
        /**
         The images of the pasteboard or `nil` if no images are available.
         
         Setting this property replaces all current items in the pasteboard with the new items.
         */
        public var images: [NSImage]? {
            get { read(for: NSImage.self) }
            set { write(newValue ?? []) }
        }

        /**
         The file urls of the pasteboard or `nil` if no file urls are available.
         
         Setting this property replaces all current items in the pasteboard with the new items.
         */
        public var fileURLs: [URL]? {
            get { read(for: NSURL.self, options: [.urlReadingFileURLsOnly: true]) as? [URL] }
            set { write(newValue ?? []) }
        }
        
        /**
         The urls of the pasteboard or `nil` if no urls are available.
         
         Setting this property replaces all current items in the pasteboard with the new items.
         */
        public var urls: [URL]? {
            get { read(for: NSURL.self) as? [URL] }
            set { write(newValue ?? []) }
        }

        /**
         The colors of the pasteboard or `nil` if no colors are available.
         
         Setting this property replaces all current items in the pasteboard with the new items.
         */
        public var colors: [NSColor]? {
            get { read(for: NSColor.self) }
            set { write(newValue ?? [] ) }
        }
        
        /**
         The sounds of the pasteboard or `nil` if no sounds are available.
         
         Setting this property replaces all current items in the pasteboard with the new items.
         */
        public var sounds: [NSSound]? {
            get { read(for: NSSound.self) }
            set { write(newValue ?? []) }
        }
        
        /// The file promise receivers of the pasteboard or `nil` if none are available.
        public var filePromiseReceivers: [NSFilePromiseReceiver]? {
            get { read(for: NSFilePromiseReceiver.self) }
        }
        
        /// The contents of the specified content type  or `nil` if no content is available.
        public func content<Content>(_ : Content.Type) -> [Content]? {
            pasteboardItems?.compactMap({$0.content(Content.self)})
        }
        
        func write<Value: NSPasteboardWriting>(_ values: [Value]) {
            guard !values.isEmpty else { return }
            clearContents()
            writeObjects(values)
        }

        /// Reads from the receiver objects that match the specified type.
        func read<V: NSPasteboardReading>(for _: V.Type, options: [NSPasteboard.ReadingOptionKey: Any]? = nil) -> [V]? {
            if let objects = readObjects(forClasses: [V.self], options: options) as? [V], !objects.isEmpty {
                return objects
            }
            return nil
        }
        
        func readAll() -> [NSPasteboardReading] {
            readObjects(forClasses: [NSString.self, NSAttributedString.self, NSURL.self, NSColor.self, NSImage.self, NSSound.self, NSPasteboardItem.self], options: nil) as? [NSPasteboardReading] ?? []
        }
    }
#endif
