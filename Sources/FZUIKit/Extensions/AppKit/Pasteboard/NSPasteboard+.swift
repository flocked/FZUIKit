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
            get { pasteboardItems?.compactMap { $0.string(forType: .string) }.first }
            set {
                if let newValue = newValue {
                    clearContents()
                    setString(newValue, forType: .string)
                }
            }
        }
        
        /**
         The strings of the pasteboard or `nil` if no strings are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var strings: [String]? {
            get { pasteboardItems?.compactMap { $0.string(forType: .string) } }
            set { write(newValue ?? []) }
        }
        
        /**
         The attributed strings of the pasteboard or `nil` if no attributed strings are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var attributedStrings: [NSAttributedString]? {
            get { read(for: NSAttributedString.self) }
            set { write(newValue ?? []) }
        }
        
        /**
         The images of the pasteboard or `nil` if no images are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var images: [NSImage]? {
            get { read(for: NSImage.self) }
            set { write(newValue ?? []) }
        }

        /**
         The file urls of the pasteboard or `nil` if no file urls are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var fileURLs: [URL]? {
            get { read(for: NSURL.self, options: [.urlReadingFileURLsOnly: true])?.compactMap { $0 as URL } }
            set { write(newValue ?? []) }
        }
        
        /**
         The urls of the pasteboard or `nil` if no urls are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var urls: [URL]? {
            get { read(for: NSURL.self)?.compactMap { $0 as URL } }
            set { write(newValue ?? []) }
        }

        /**
         The colors of the pasteboard or `nil` if no colors are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var colors: [NSColor]? {
            get { read(for: NSColor.self) }
            set { write(newValue ?? [] ) }
        }
        
        /**
         The sounds of the pasteboard or `nil` if no sounds are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var sounds: [NSSound]? {
            get { read(for: NSSound.self) }
            set { write(newValue ?? []) }
        }
        
        /**
         The specified codable objects of the pasteboard or `nil` if no objects are available.
         
         Setting this property replaces all current items in the pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public func content<Content: Codable>(_ content: Content.Type) -> [Content]? {
            pasteboardItems?.compactMap({$0.content(content)})
        }
        
        func write<Value: NSPasteboardWriting>(_ values: [Value]) {
            guard values.isEmpty == false else { return }
            clearContents()
            writeObjects(values)
        }

        /// Reads from the receiver objects that match the specified type.
        func read<V: NSPasteboardReading>(for _: V.Type, options: [NSPasteboard.ReadingOptionKey: Any]? = nil) -> [V]? {
            if let objects = readObjects(forClasses: [V.self], options: options) as? [V], objects.isEmpty == false {
                return objects
            }
            return nil
        }
    }

    extension NSDraggingInfo {
        /// The string of the dragging info or `nil` if no string is available.
        public var string: String? {
            get { draggingPasteboard.string }
            set { draggingPasteboard.string = newValue }
        }
        
        /**
         The strings of the dragging info or `nil` if no strings are available.
         
         Setting this property replaces all current items in the dragging pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var strings: [String]? {
            get { draggingPasteboard.strings }
            set { draggingPasteboard.strings = newValue }
        }
        
        /**
         The attributed strings of the dragging info or `nil` if no attributed strings are available.
         
         Setting this property replaces all current items in the dragging pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var attributedStrings: [NSAttributedString]? {
            get { draggingPasteboard.attributedStrings }
            set { draggingPasteboard.attributedStrings = newValue }
        }

        /**
         The file urls of the dragging info or `nil` if no file urls are available.
         
         Setting this property replaces all current items in the dragging pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var fileURLs: [URL]? {
            get { draggingPasteboard.fileURLs }
            set { draggingPasteboard.fileURLs = newValue }
        }
        
        /**
         The urls of the dragging info or `nil` if no urls are available.
         
         Setting this property replaces all current items in the dragging pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var urls: [URL]? {
            get { draggingPasteboard.urls }
            set { draggingPasteboard.urls = newValue }
        }
        
        /**
         The images of the dragging info or `nil` if no images are available.
         
         Setting this property replaces all current items in the dragging pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var images: [NSImage]? {
            get { draggingPasteboard.images }
            set { draggingPasteboard.images = newValue }
        }
        
        /**
         The colors of the dragging info or `nil` if no colors are available.
         
         Setting this property replaces all current items in the dragging pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var colors: [NSColor]? {
            get { draggingPasteboard.colors }
            set { draggingPasteboard.colors = newValue }
        }

        /**
         The sounds of the dragging info or `nil` if no sounds are available.
         
         Setting this property replaces all current items in the dragging pasteboard with the new items. The returned array may have fewer objects than the number of pasteboard items; this happens if a pasteboard item does not have a value of the indicated type.
         */
        public var sounds: [NSSound]? {
            get { draggingPasteboard.sounds }
            set { draggingPasteboard.sounds = newValue }
        }
    }

#endif
