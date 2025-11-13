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

/// Object to read the content of a pasteboard.
public class PasteboardContent {
    private weak var pasteboard: NSPasteboard?
    private var lastChangeCount = -1
    private var values: [String : Any] = [:]
    private var hasItems: [String: Bool] = [:]
    
    /// Creates the object to read the content of the specified pasteboard.
    public init(pasteboard: NSPasteboard) {
        self.pasteboard = pasteboard
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func objects<T: NSPasteboardReading>(ofType type: T.Type) -> [T] {
        value(for: type)
    }
    
    /// Returns the objects on the pasteboard for the specified `NSPasteboardReading` type.
    public func objects<T>(ofType type: T.Type) -> [T] where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        value(for: T._ObjectiveCType.self)
    }
    
    /// The pasteboard items on the pasteboard.
    public var pasteboardItems: [NSPasteboardItem] {
        pasteboard?.pasteboardItems ?? []
    }
    
    /// The strings on the pasteboard.
    public var strings: [String] {
        value(for: NSString.self)
    }
    
    /// The attributed strings on the pasteboard.
    public var attributedStrings: [NSAttributedString] {
        value(for: NSAttributedString.self)
    }
    
    /// The urls on the pasteboard.
    public var urls: [URL] {
        value(for: NSURL.self)
    }
    
    /// The file urls on the pasteboard.
    public var fileURLs: [URL] {
        value(for: NSURL.self, filesOnly: true)
    }
    
    public lazy var fileURLsFiltered: [URL] = {
        if !fileURLFilters.isEmpty {
            var urls = fileURLs
            var matching: [URL] = []
            for fileURLFilter in fileURLFilters {
                matching += urls.removeAll(where: fileURLFilter)
            }
            return matching
        }
        return fileURLs
    }()
    
    var fileURLFilters: [(URL)->(Bool)] = []
        
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
    
    @available(macOS 11.0, *)
    /// The urls with the specified content types on the pasteboard.
    public func urls(contentTypes: [UTType]) -> [URL] {
        urls.filter { $0.contentType?.conforms(toAny: contentTypes) == true }
    }
    
    /// The urls with the specified types  on the pasteboard.
    public func urls(types: [FileType]) -> [URL] {
        urls.filter { $0.fileType?.exists(in: types) == true }
    }
    
    @available(macOS 11.0, *)
    /// The file urls with the specified content types on the pasteboard.
    public func fileURLs(contentTypes: [UTType]) -> [URL] {
        fileURLs.filter { $0.contentType?.conforms(toAny: contentTypes) == true }
    }
    
    /// The file urls with the specified file types on the pasteboard.
    public func fileURLs(types: [FileType]) -> [URL] {
        fileURLs.filter { $0.fileType?.exists(in: types) == true }
    }
    
    private func value<V>(for type: AnyClass, filesOnly: Bool = false) -> [V] {
        guard let pasteboard = pasteboard else { return [] }
        let typeName = NSStringFromClass(type)
        if lastChangeCount != pasteboard.changeCount {
            lastChangeCount = pasteboard.changeCount
            values.removeAll()
        } else if let values = values[typeName] as? [V] {
            return values
        }
        let values = pasteboard.readObjects(forClasses: [type], options: filesOnly ? [.urlReadingFileURLsOnly: true] : [:]) as? [V] ?? []
        self.values[typeName] = values
        return values
    }
}

extension PasteboardContent {
    @available(macOS 11.0, *)
    /// Returns a Boolean value indiciating whether the pasteboard contains items conforming to the specified content types.
    public func hasItems(conformingTo contentTypes: [UTType]) -> Bool {
        pasteboard?.canReadItem(withDataConformingToTypes: contentTypes.map { $0.identifier }) ?? false
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard can read objects of the specified classes.
    public func hasObjects<T: NSPasteboardReading>(ofType type: T.Type) -> Bool {
        pasteboard?.canReadObject(forClasses: [type]) ?? false
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard can read objects of the specified classes.
    public func hasObjects<T>(ofType type: T.Type) -> Bool where T : _ObjectiveCBridgeable, T._ObjectiveCType : NSPasteboardReading {
        pasteboard?.canReadObject(forClasses: [T._ObjectiveCType.self]) ?? false
    }
        
    /// The pastebord types that the pasteboard supports.
    public var pasteboardTypes: [NSPasteboard.PasteboardType] {
        pasteboard?.types ?? []
    }
    
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
    
    /// Returns a Boolean value indiciating whether the pasteboard contains file URLs.
    public var hasFileURLs: Bool {
        hasValues(for: NSURL.self, onlyFiles: true)
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains URLs conforming to the specified content types.
    @available(macOS 11.0, *)
    public func hasURLs(contentTypes: [UTType]) -> Bool {
        hasURLs(types: contentTypes.compactMap({$0.identifier}))
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains URLs with the specified file types.
    public func hasURLs(types: [FileType]) -> Bool {
        hasURLs(types: types.compactMap({$0.identifier}))
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains file URLs conforming to the specified content types.
    @available(macOS 11.0, *)
    public func hasFileURLs(contentTypes: [UTType]) -> Bool {
        hasURLs(fileOnly: true, types: contentTypes.compactMap({$0.identifier}))
    }
    
    /// Returns a Boolean value indiciating whether the pasteboard contains file URLs with the specified file types.
    public func hasFileURLs(types: [FileType]) -> Bool {
        hasURLs(fileOnly: true, types: types.compactMap({$0.identifier}))
    }
    
    
    private func hasURLs(fileOnly: Bool = false, types: [String]) -> Bool {
        pasteboard?.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly : fileOnly, .urlReadingContentsConformToTypes : types]) ?? false
    }
    
    private func hasValues(for type: AnyClass, onlyFiles: Bool = false) -> Bool {
        guard let pasteboard = pasteboard else { return false }
        let typeName = NSStringFromClass(type)
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            hasItems.removeAll()
        } else if let canRead = hasItems[typeName] {
            return canRead
        }
        let canRead = pasteboard.canReadObject(forClasses: [type], options: onlyFiles ? [.urlReadingFileURLsOnly: true] : [:])
        hasItems[typeName] = canRead
        return canRead
    }
}


extension NSDraggingInfo {
    /// The content of the pasteboard.
    var pasteboardContent: PasteboardContent {
        FZSwiftUtils.getAssociatedValue("pasteboardContent", object: self, initialValue: .init(pasteboard: draggingPasteboard))
    }
}
#endif
 
