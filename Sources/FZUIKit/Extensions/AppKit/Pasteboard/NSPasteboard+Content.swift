//
//  File.swift
//  
//
//  Created by Florian Zand on 03.03.25.
//

import AppKit
import FZSwiftUtils
import UniformTypeIdentifiers

public extension NSDraggingInfo {
    /// The content of the pasteboard.
    var pasteboardContent: PasteboardContent {
        FZSwiftUtils.getAssociatedValue("pasteboardContent", object: self, initialValue: .init(pasteboard: draggingPasteboard))
    }
    
    /// Object to validate the content of the pasteboard.
    var pasteboardContentValidation: PasteboardContentValidation {
        FZSwiftUtils.getAssociatedValue("pasteboardContentValidation", object: self, initialValue: .init(pasteboard: draggingPasteboard))
    }
}

/// Object to validate the content of a pasteboard.
public class PasteboardContentValidation {
    private weak var pasteboard: NSPasteboard?
    private var hasItems: [PasteboardType: Bool] = [:]
    private var lastChangeCount = -1
    
    /// Initializes the `PasteboardContentValidation` with the given pasteboard.
    public init(pasteboard: NSPasteboard) {
        self.pasteboard = pasteboard
    }
    
    /// Checks if the pasteboard contains items conforming to the specified type identifiers.
    @available(macOS 11.0, *)
    public func hasItemsConforming(toTypeIdentifiers typeIdentifiers: [UTType]) -> Bool {
        pasteboard?.canReadItem(withDataConformingToTypes: typeIdentifiers.map { $0.identifier }) ?? false
    }
    
    /// Checks if the pasteboard can read objects of the specified classes.
    public func canReadObjects(for classes: [NSPasteboardReading.Type]) -> Bool {
        pasteboard?.canReadObject(forClasses: classes) ?? false
    }
    
    public var pasteboardTyoes: [NSPasteboard.PasteboardType] {
        pasteboard?.types ?? []
    }
    
    public func availablePasteboardType(from types: [NSPasteboard.PasteboardType]) -> NSPasteboard.PasteboardType? {
        pasteboard?.availableType(from: types)
    }
    
    /// Returns whether the pasteboard contains string objects.
    public var hasStrings: Bool {
        value(for: .strings)
    }
    
    /// Returns whether the pasteboard contains attributed string objects.
    public var hasAttributedStrings: Bool {
        value(for: .attributedStrings)
    }
    
    /// Returns whether the pasteboard contains color objects.
    public var hasColors: Bool {
        value(for: .colors)
    }
    
    /// Returns whether the pasteboard contains image objects.
    public var hasImages: Bool {
        value(for: .images)
    }
    
    /// Returns whether the pasteboard contains sound objects.
    public var hasSounds: Bool {
        value(for: .sounds)
    }
    
    /// Returns whether the pasteboard contains file promise receivers.
    public var hasFilePromiseReceivers: Bool {
        value(for: .filePromiseReceivers)
    }
    
    /// Returns whether the pasteboard contains URL objects.
    public var hasURLs: Bool {
        value(for: .urls)
    }
    
    /// Returns whether the pasteboard contains file URL objects.
    public var hasFileURLs: Bool {
        value(for: .fileURLs)
    }
    
    /// Checks if the pasteboard contains URLs conforming to the specified content types.
    @available(macOS 11.0, *)
    public func hasURLs(contentTypes: [UTType]) -> Bool {
        hasURLs(types: contentTypes.compactMap({$0.identifier}))
    }
    
    /// Checks if the pasteboard contains URLs of the specified file types.
    public func hasURLs(types: [FileType]) -> Bool {
        hasURLs(types: types.compactMap({$0.identifier}))
    }
    
    /// Checks if the pasteboard contains file URLs conforming to the specified content types.
    @available(macOS 11.0, *)
    public func hasFileURLs(contentTypes: [UTType]) -> Bool {
        hasURLs(fileOnly: true, types: contentTypes.compactMap({$0.identifier}))
    }
    
    /// Checks if the pasteboard contains file URLs of the specified file types.
    public func hasFileURLs(types: [FileType]) -> Bool {
        hasURLs(fileOnly: true, types: types.compactMap({$0.identifier}))
    }
    
    private func hasURLs(fileOnly: Bool? = nil, types: [String]) -> Bool {
        var options: [NSPasteboard.ReadingOptionKey : Any] = [.urlReadingContentsConformToTypes : types]
        options[.urlReadingFileURLsOnly] = fileOnly
        return pasteboard?.canReadObject(forClasses: [NSURL.self], options: options) ?? false
    }
    
    private func value(for type: PasteboardType) -> Bool {
        guard let pasteboard = pasteboard else { return false }
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            hasItems.removeAll()
        } else if let canRead = hasItems[type] {
            return canRead
        }
        let canRead = pasteboard.canReadObject(forClasses: [type.pasteboardReading], options: type == .fileURLs ? [.urlReadingFileURLsOnly: true] : nil)
        hasItems[type] = canRead
        return canRead
    }
}

/// Object to read the content of a pasteboard.
public class PasteboardContent {
    private weak var pasteboard: NSPasteboard?
    private var lastChangeCount = -1
    private var values: [PasteboardType : Any] = [:]
    
    public init(pasteboard: NSPasteboard) {
        self.pasteboard = pasteboard
    }
    
    public func readObjects<T: NSPasteboardReading>(for type: T.Type) -> [T] {
        (pasteboard?.readObjects(forClasses: [T.self]) ?? []).compactMap { $0 as? T }
    }
    
    public func readObjects(for types: [NSPasteboardReading.Type]) -> [NSPasteboardReading] {
        (pasteboard?.readObjects(forClasses: types) ?? []).compactMap { $0 as? NSPasteboardReading }
    }
    
    public var pasteboardItems: [NSPasteboardItem] {
        pasteboard?.pasteboardItems ?? []
    }
    
    public var strings: [String] {
        value(for: .strings)
    }
    
    public var attributedStrings: [NSAttributedString] {
        value(for: .attributedStrings)
    }
    
    public var urls: [URL] {
        value(for: .urls)
    }
    
    public var fileURLs: [URL] {
        value(for: .fileURLs)
    }
    
    public var colors: [NSColor] {
        value(for: .colors)
    }
    
    public var images: [NSImage] {
        value(for: .images)
    }
    
    public var sounds: [NSSound] {
        value(for: .sounds)
    }
    
    public var filePromiseReceivers: [NSFilePromiseReceiver] {
        value(for: .filePromiseReceivers)
    }
    
    @available(macOS 11.0, *)
    public func urls(contentTypes: [UTType]) -> [URL] {
        urls.filter { $0.contentType?.conforms(toAny: contentTypes) == true }
    }
    
    public func urls(types: [FileType]) -> [URL] {
        urls.filter { $0.fileType?.exists(in: types) == true }
    }
    
    @available(macOS 11.0, *)
    public func fileURLs(contentTypes: [UTType]) -> [URL] {
        fileURLs.filter { $0.contentType?.conforms(toAny: contentTypes) == true }
    }
    
    public func fileURLs(types: [FileType]) -> [URL] {
        fileURLs.filter { $0.fileType?.exists(in: types) == true }
    }
    
    private func value<V>(for type: PasteboardType) -> [V] {
        guard let pasteboard = pasteboard else { return [] }
        if lastChangeCount != pasteboard.changeCount {
            lastChangeCount = pasteboard.changeCount
            values.removeAll()
        } else if let values = values[type] as? [V] {
            return values
        }
        let values = pasteboard.readObjects(forClasses: [type.pasteboardReading], options: type == .fileURLs ? [.urlReadingFileURLsOnly: true] : nil) as? [V] ?? []
        self.values[type] = values
        return values
    }
}

fileprivate enum PasteboardType: CaseIterable {
    case strings, attributedStrings, colors, images, sounds, filePromiseReceivers, urls, fileURLs
    
    var pasteboardReading: NSPasteboardReading.Type  {
        switch self {
        case .strings: return NSString.self
        case .attributedStrings: return NSAttributedString.self
        case .colors: return NSColor.self
        case .images: return NSImage.self
        case .sounds: return NSSound.self
        case .filePromiseReceivers: return NSFilePromiseReceiver.self
        case .urls: return NSURL.self
        case .fileURLs: return NSURL.self
        }
    }
}
