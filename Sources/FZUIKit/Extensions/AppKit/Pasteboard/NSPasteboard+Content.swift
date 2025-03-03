//
//  File.swift
//  
//
//  Created by Florian Zand on 03.03.25.
//

import AppKit
import FZSwiftUtils
import UniformTypeIdentifiers

public extension NSPasteboard {
    var validation: PasteboardValidation {
        getAssociatedValue("PasteboardValidation", initialValue: .init(self))
    }
    
    var reader: PasteboardContent {
        getAssociatedValue("PasteboardContent", initialValue: .init(self))
    }
}

public class PasteboardValidation {
    private weak var pasteboard: NSPasteboard?
    private var hasItems: [PasteboardType: Bool] = [:]
    private var lastChangeCount = -1
    
    /// Initializes the `PasteboardValidation` with the given pasteboard.
    init(_ pasteboard: NSPasteboard) {
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
    
    /// Returns whether the pasteboard contains string objects.
    public var hasStrings: Bool {
        refreshIfNeeded(for: .strings)
    }
    
    /// Returns whether the pasteboard contains attributed string objects.
    public var hasAttributedStrings: Bool {
        refreshIfNeeded(for: .attributedStrings)
    }
    
    /// Returns whether the pasteboard contains color objects.
    public var hasColors: Bool {
        refreshIfNeeded(for: .colors)
    }
    
    /// Returns whether the pasteboard contains image objects.
    public var hasImages: Bool {
        refreshIfNeeded(for: .images)
    }
    
    /// Returns whether the pasteboard contains sound objects.
    public var hasSounds: Bool {
        refreshIfNeeded(for: .sounds)
    }
    
    /// Returns whether the pasteboard contains file promise receivers.
    public var hasFilePromiseReceivers: Bool {
        refreshIfNeeded(for: .filePromiseReceivers)
    }
    
    /// Returns whether the pasteboard contains URL objects.
    public var hasURLs: Bool {
        refreshIfNeeded(for: .urls)
    }
    
    /// Returns whether the pasteboard contains file URL objects.
    public var hasFileURLs: Bool {
        refreshIfNeeded(for: .fileURLs)
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
    
    private func refreshIfNeeded(for type: PasteboardType) -> Bool {
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

public class PasteboardContent {
    private weak var pasteboard: NSPasteboard?
    private var lastChangeCount = -1
    private var values: [PasteboardType : Any] = [:]
    
    init(_ pasteboard: NSPasteboard) {
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
        refreshIfNeeded(for: .strings)
    }
    
    public var attributedStrings: [NSAttributedString] {
        refreshIfNeeded(for: .attributedStrings)
    }
    
    public var urls: [URL] {
        refreshIfNeeded(for: .urls)
    }
    
    public var fileURLs: [URL] {
        refreshIfNeeded(for: .fileURLs)
    }
    
    public var colors: [NSColor] {
        refreshIfNeeded(for: .colors)
    }
    
    public var images: [NSImage] {
        refreshIfNeeded(for: .images)
    }
    
    public var sounds: [NSSound] {
        refreshIfNeeded(for: .sounds)
    }
    
    public var filePromiseReceivers: [NSFilePromiseReceiver] {
        refreshIfNeeded(for: .filePromiseReceivers)
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
    
    private func refreshIfNeeded<V>(for type: PasteboardType) -> [V] {
        guard let pasteboard = pasteboard else { return [] }
        if lastChangeCount != pasteboard.changeCount {
            lastChangeCount = pasteboard.changeCount
            values.removeAll()
        } else if let values = values[type] as? [V] {
            return values
        }
        var values: [V] = []
        if type == .fileURLs {
            values = (urls.filter({ $0.isFileURL }) as? [V] ?? [])
        }
        values = readObjects(for: type.pasteboardReading) as? [V] ?? []
        self.values[type] = values
        return values
    }
    
    /*
    private func refreshIfNeeded(for type: PasteboardType) {
        guard let currentChangeCount = pasteboard?.changeCount else { return }
        guard lastChangeCounts[type] != currentChangeCount else { return }
        lastChangeCounts[type] = currentChangeCount
        switch type {
        case .strings:
            _strings = readObjects(for: NSString.self) as [String]
        case .attributedStrings:
            _attributedStrings = readObjects(for: NSAttributedString.self)
        case .urls:
            _urls = readObjects(for: NSURL.self) as [URL]
            _fileURLs = _urls.filter { $0.isFileURL }
        case .colors:
            _colors = readObjects(for: NSColor.self)
        case .images:
            _images = readObjects(for: NSImage.self)
        case .sounds:
            _sounds = readObjects(for: NSSound.self)
        case .filePromiseReceivers:
            _filePromiseReceivers = readObjects(for: NSFilePromiseReceiver.self)
        default: break
        }
    }
     */
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
