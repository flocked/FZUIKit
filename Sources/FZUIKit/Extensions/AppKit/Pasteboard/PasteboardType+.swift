//
//  PasteboardContentItem.swift
//
//
//  Created by Florian Zand on 11.02.24.
//

#if os(macOS)
import AppKit

extension NSPasteboard.PasteboardType {
    /// Type for codable values.
    public static let codable = NSPasteboard.PasteboardType("PasteboardType.Codable")
    
    /// Type for objects.
    public static let object = NSPasteboard.PasteboardType("PasteboardType.Object")

}

/*
/// A type that can be used as pasteboard content.
public protocol PasteboardContentItem: Codable, PasteboardContent {
    /// The pasteboard type of the object. The default value is `codable`.
    static var pasteboardType: NSPasteboard.PasteboardType { get }
    
    /// Creates a pasteboard item for the object.
    var pasteboardItem: NSPasteboardItem { get }
    
    /// Creates the object from the specified pasteboard item.
    init?(pasteboardItem: NSPasteboardItem)
}

extension PasteboardContentItem {
    public static var pasteboardType: NSPasteboard.PasteboardType {
        return .codable
    }
    
    public var pasteboardWriting: NSPasteboardWriting {
        pasteboardItem
    }
    public var pasteboardItem: NSPasteboardItem {
        NSPasteboardItem(self)!
    }
    
    public init?(pasteboardItem: NSPasteboardItem) {
        guard let content = pasteboardItem.content(Self.self) else {
            return nil
        }
        self = content
    }
}

public class CodablePasteboardItem<Content: Codable>: NSObject, NSPasteboardWriting, NSPasteboardReading, PasteboardContent {
    public static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        [.codable]
    }
    
    public static func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
        .asData
    }
    
    public required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        guard let data = propertyList as? Data else { return nil }
        guard let content = try? PropertyListDecoder().decode(Content.self, from: data) else { return nil }
        self.content = content
    }
    
    public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        [.codable]
    }
    
    public func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.WritingOptions {
        .promised
    }
    
    public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        guard type == .codable else { return nil }
        return try? PropertyListEncoder().encode(content)
    }
    
    public let content: Content
    public init(content: Content) {
        self.content = content
    }
    
    public init(_ content: Content) {
        self.content = content
    }
}
*/

#endif
