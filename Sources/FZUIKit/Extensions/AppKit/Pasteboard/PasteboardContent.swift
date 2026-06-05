//
//  PasteboardContent.swift
//  
//
//  Created by Florian Zand on 03.03.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import UniformTypeIdentifiers

/// An object to read the content of a pasteboard.
public class NSPasteboardContent {
    private let pasteboard: NSPasteboard
    private var lastChangeCount = -1
    private var values: [Key : Any] = [:]
    private var hasItems: [Key: Bool] = [:]
    
    /// Creates the object to read the content of the specified pasteboard.
    public init(pasteboard: NSPasteboard) {
        self.pasteboard = pasteboard
    }
    
    /// The strings on the pasteboard.
    public var strings: [String] {
        value(for: String.self)
    }
    
    /// The attributed strings on the pasteboard.
    public var attributedStrings: [NSAttributedString] {
        value(for: NSAttributedString.self)
    }
    
    /// The urls on the pasteboard.
    public var urls: [URL] {
        value(for: URL.self)
    }
    
    /// The urls with the specified content types on the pasteboard.
    public func urls(contentTypes: [UTType]) -> [URL] {
        urls.filter { $0.contentType?.conforms(toAny: contentTypes) == true }
    }
    
    /// The urls with the specified types  on the pasteboard.
    public func urls(types: [FileType]) -> [URL] {
        urls.filter { $0.fileType?.exists(in: types) == true }
    }
    
    /// The file urls on the pasteboard.
    public var fileURLs: [URL] {
        value(for: URL.self, filesOnly: true)
    }
    
    
    /// The file urls with the specified content types on the pasteboard.
    public func fileURLs(contentTypes: [UTType]) -> [URL] {
        fileURLs.filter { $0.contentType?.conforms(toAny: contentTypes) == true }
    }
    
    /// The file urls with the specified file types on the pasteboard.
    public func fileURLs(types: [FileType]) -> [URL] {
        fileURLs.filter { $0.fileType?.exists(in: types) == true }
    }
        
    /// The colors on the pasteboard.
    public var colors: [NSColor] {
        value(for: NSColor.self)
    }
    
    /// The images on the pasteboard.
    public var images: [NSImage] {
        value(for: NSImage.self)
    }
    
    /// The sounds on the pasteboard.
    public var sounds: [NSSound] {
        value(for: NSSound.self)
    }
    
    /// The file promise receivers on the pasteboard.
    public var filePromiseReceivers: [NSFilePromiseReceiver] {
        value(for: NSFilePromiseReceiver.self)
    }
    
    /// The pasteboard items on the pasteboard.
    public var pasteboardItems: [NSPasteboardItem] {
        pasteboard.pasteboardItems ?? []
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func values<T: NSPasteboardReading>(for type: T.Type = T.self) -> [T] {
        value(for: type)
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func values<T>(for type: T.Type = T.self) -> [T] where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        value(for: T._ObjectiveCType.self)
    }
    
    private func value<V>(for type: AnyClass, filesOnly: Bool = false) -> [V] {
        let key = Key(for: type, filesOnly: filesOnly)
        if !didChange, let values = values[key] as? [V] {
            return values
        }
        let values = pasteboard.readObjects(forClasses: [type], options: key.options) as? [V] ?? []
        self.values[key] = values
        return values
    }
    
    private func value<T>(for type: T.Type, filesOnly: Bool = false) -> [T] where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        value(for: T._ObjectiveCType.self, filesOnly: filesOnly) as [T]
    }
    
    private struct Key: Hashable {
        let value: String
        let contentTypes: [String]
        let filesOnly: Bool
        
        var options: [NSPasteboard.ReadingOptionKey : Any]? {
            var options: [NSPasteboard.ReadingOptionKey : Any] = [:]
            options[.urlReadingFileURLsOnly] = filesOnly ? true : nil
            options[.urlReadingContentsConformToTypes] = !contentTypes.isEmpty ? contentTypes : nil
            return !options.isEmpty ? options : nil
        }
        
        init(for cls: AnyClass, contentTypes: [String] = [], filesOnly: Bool = false) {
            self.value = NSStringFromClass(cls)
            self.contentTypes = contentTypes
            self.filesOnly = filesOnly
        }
    }
    
    private var didChange: Bool {
        guard pasteboard.changeCount != lastChangeCount else { return false }
        values.removeAll()
        hasItems.removeAll()
        return true
    }
}

extension NSPasteboardContent {
    /// Returns a Boolean value indiciating whether the pasteboard contains strings.
    public var hasStrings: Bool {
        hasValues(for: NSString.self)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains attributed strings.
    public var hasAttributedStrings: Bool {
        hasValues(for: NSAttributedString.self)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains colors.
    public var hasColors: Bool {
        hasValues(for: NSColor.self)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains images.
    public var hasImages: Bool {
        hasValues(for: NSImage.self)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains sounds.
    public var hasSounds: Bool {
        hasValues(for: NSSound.self)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains file promise receivers.
    public var hasFilePromiseReceivers: Bool {
        hasValues(for: NSFilePromiseReceiver.self)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains URLs.
    public var hasURLs: Bool {
        hasValues(for: NSURL.self)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains URLs conforming to the specified content types.
    public func hasURLs(contentTypes: [UTType]) -> Bool {
        hasValues(for: NSURL.self, contentTypes: contentTypes.map({$0.identifier}))
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains URLs with the specified file types.
    public func hasURLs(types: [FileType]) -> Bool {
        hasValues(for: NSURL.self, contentTypes: types.map({$0.identifier}))
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains file URLs.
    public var hasFileURLs: Bool {
        hasValues(for: NSURL.self, filesOnly: true)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains file URLs conforming to the specified content types.
    public func hasFileURLs(contentTypes: [UTType]) -> Bool {
        hasValues(for: NSURL.self, filesOnly: true, contentTypes: contentTypes.map({$0.identifier}))
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains file URLs with the specified file types.
    public func hasFileURLs(types: [FileType]) -> Bool {
        hasValues(for: NSURL.self, filesOnly: true, contentTypes: types.map({$0.identifier}))
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard can read objects of the specified type.
    public func canRead<T: NSPasteboardReading>(_ type: T.Type) -> Bool {
        pasteboard.canRead(type)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard can read objects of the specified type.
    public func canRead<T>(_ type: T.Type) -> Bool where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        pasteboard.canRead(type)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard can read objects of the specified types.
    public func canRead(_ types: [(any NSPasteboardReading).Type]) -> Bool {
        pasteboard.canRead(types)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard can read objects of the specified types.
    public func canRead(_ types: [(any PasteboardReading).Type]) -> Bool {
        pasteboard.canRead(types)
    }
    
    private func hasValues(for type: AnyClass, filesOnly: Bool = false, contentTypes: [String] = []) -> Bool {
        let key = Key(for: type, contentTypes: contentTypes, filesOnly: filesOnly)
        if !didChange, let canRead = hasItems[key] {
            return canRead
        }
        let canRead = pasteboard.canReadObject(forClasses: [type], options: key.options)
        hasItems[key] = canRead
        return canRead
    }
}

extension NSDraggingInfo {
    /// The content of the pasteboard.
    var pasteboardContent: NSPasteboardContent {
        FZSwiftUtils.getAssociatedValue("pasteboardContent", object: self, initialValue: .init(pasteboard: draggingPasteboard))
    }
}
#endif
 
