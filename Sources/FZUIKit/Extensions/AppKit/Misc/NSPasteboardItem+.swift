//
//  NSPasteboardItem+.swift
//
//
//  Created by Florian Zand on 01.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSPasteboardItem {
    convenience init?(_ content: Codable, type: NSPasteboard.PasteboardType) {
        guard let data = try? PropertyListEncoder().encode(content) else {
            return nil
        }
        self.init(pasteboardPropertyList: data, ofType: type)
    }
    
    func content<Content: Codable>(_ content: Content.Type, for type: NSPasteboard.PasteboardType) -> Content? {
        if let data = propertyList(forType: type) as? Data {
            return try? PropertyListDecoder().decode(content, from: data)
        }
        return nil
    }
    
    /// The color of the pasteboard item.
    public var color: NSColor? {
        get {
            if let data = data(forType: .color), let color: NSColor = try? NSKeyedUnarchiver.unarchive(data) {
                return color
            }
            return nil
        }
        set {
            if let newValue = newValue, let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) {
                setData(data, forType: .color)
            }
        }
    }
    
    /// The string of the pasteboard item.
    public var string: String? {
        get { string(forType: .string) }
        set {
            if let newValue = newValue {
                setString(newValue, forType: .string)
            }
        }
    }
    
    /// The png image of the pasteboard item.
    public var pngImage: NSImage? {
        get {
            if let data = data(forType: .png), let image = NSImage(data: data) {
                return image
            }
            return nil
        }
        set {
            if let data = newValue?.pngData() {
                setData(data, forType: .png)
            }
        }
    }
    
    /// The tiff image of the pasteboard item.
    public var tiffImage: NSImage? {
        get {
            if let data = data(forType: .tiff), let image = NSImage(data: data) {
                return image
            }
            return nil
        }
        set {
            if let data = newValue?.tiffRepresentation {
                setData(data, forType: .tiff)
            }
        }
    }
    
    /// The url of the pasteboard item.
    public var url: URL? {
        get {
            if let data = data(forType: .URL), let url = URL(dataRepresentation: data, relativeTo: nil) {
                return url
            }
            return nil
        }
        set {
            if let data = newValue?.dataRepresentation {
                setData(data, forType: .URL)
            }
        }
    }
    
    /// The file url of the pasteboard item.
    public var fileURL: URL? {
        get {
            if let data = data(forType: .fileURL), let url = URL(dataRepresentation: data, relativeTo: nil) {
                return url
            }
            return nil
        }
        set {
            if let data = newValue?.dataRepresentation {
                setData(data, forType: .fileURL)
            }
        }
    }
}

#endif
