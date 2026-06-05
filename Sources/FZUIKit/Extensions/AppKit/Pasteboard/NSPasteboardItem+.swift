//
//  NSPasteboardItem+.swift
//
//
//  Created by Florian Zand on 01.02.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils
import UniformTypeIdentifiers
// Can I write a NSFilePromiseProvider or NSFilePromiseReceiver to NSPasteboardItem?
extension NSPasteboardItem {
    /// An array of uniform type identifiers of the data types that the receiver supports.
    public var contentTypes: [UTType] { types.compactMap({ $0.uttype }) }
    
    /// Returns the content types supported by the pasteboard item that conform to the specified type.
    public func contentTypes(conformingTo contentType: UTType) -> [UTType] {
        contentTypes.filter({ $0.conforms(to: contentType) })
    }
    
    /// The string of the pasteboard item.
    public var string: String? {
        get { string(forType: .string) }
        set { setValue(newValue, forType: .string) }
    }
    
    /// The attributed string of the pasteboard item.
    public var attributedString: NSAttributedString? {
        get { value(forType: .rtf) }
        set {
            guard let newValue = newValue, let data = newValue.rtf(from: newValue.string.nsRange) else { return }
            setString(newValue.string, forType: .string)
            setData(data, forType: .rtf)
        }
    }
    
    /// The png image of the pasteboard item.
    public var pngImage: NSImage? {
        get { value(forType: .png) }
        set { setValue(newValue, forType: .png) }
    }
    
    /// The tiff image of the pasteboard item.
    public var tiffImage: NSImage? {
        get { value(forType: .tiff) }
        set { setValue(newValue, forType: .tiff) }
    }
    
    /// The color of the pasteboard item.
    public var color: NSColor? {
        get { value(forType: .color) }
        set { setValue(newValue, forType: .color) }
    }
    
    /// The sound of the pasteboard item.
    public var sound: NSSound? {
        get { value(forType: .sound) }
        set { setValue(newValue, forType: .sound) }
    }
    
    /// The url of the pasteboard item.
    public var url: URL? {
        get { value(forType: .URL) }
        set { setValue(newValue, forType: .URL) }
    }
    
    /// The file url of the pasteboard item.
    public var fileURL: URL? {
        get { value(forType: .fileURL) }
        set {
            guard newValue?.isFileURL == true else { return }
            setValue(newValue, forType: .fileURL)
        }
    }
    
    /// Returns a concatenation of the strings for the specified type from all the items in the receiver that contain the type.
    @_disfavoredOverload
    public func string(forType type: UTType) -> String? {
        string(forType: NSPasteboard.PasteboardType(type.identifier))
    }
    
    /// Returns the data for the specified type from the first item in the receiver that contains the type.
    @_disfavoredOverload
    public func data(forType type: UTType) -> Data? {
        data(forType: NSPasteboard.PasteboardType(type.identifier))
    }
    
    /// Returns the property list for the specified type from the first item in the receiver that contains the type.
    @_disfavoredOverload
    public func propertyList(forType type: UTType) -> Any? {
        propertyList(forType: NSPasteboard.PasteboardType(type.identifier))
    }
    
    /**
     Sets the value for a specified type as a string.
     
     - Parameters:
        - string: A string for the representation specified by type.
        - type: A uniform type identifier.
     - Returns: `true` if the value was set successfully, otherwise `false`.
     */
    @_disfavoredOverload
    public func setString(_ string: String, forType type: UTType) -> Bool {
        setString(string, forType: NSPasteboard.PasteboardType(type.identifier))
    }
    
    /**
     Sets the value for a specified type as a data.
     
     - Parameters:
        - data: The data containing the value for the representation specified by type.
        - type: A uniform type identifier.
     - Returns: `true` if the value was set successfully, otherwise `false`.
     */
    @_disfavoredOverload
    public func setData(_ data: Data, forType type: UTType) -> Bool {
        setData(data, forType: NSPasteboard.PasteboardType(type.identifier))
    }
    
    /**
     Sets the value for a specified type as a property list.
     
     - Parameters:
        - propertyList: A property list object containing the value for the representation specified by type.
        - type: A uniform type identifier.
     - Returns: `true` if the value was set successfully, otherwise `false`.
     */
    @_disfavoredOverload
    public func setPropertyList(_ propertyList: Any, forType type: UTType) -> Bool {
        setPropertyList(propertyList, forType: NSPasteboard.PasteboardType(type.identifier))
    }
    
    /// Returns the value for the specified type as a codable type.
    public func value<Value: NSPasteboardReading>(forType type: NSPasteboard.PasteboardType) -> Value? {
        if Value.self == NSString.self {
            return string(forType: type) as? Value
        }
        guard let data = data(forType: type) else { return nil }
        if Value.self == NSURL.self {
            return URL(dataRepresentation: data, relativeTo: nil) as? Value
        } else if Value.self == NSImage.self {
            return NSImage(data: data) as? Value
        } else if Value.self == NSAttributedString.self {
            return NSAttributedString(rtf: data, documentAttributes: nil) as? Value
        } else if Value.self == NSSound.self {
            return NSSound(data: data) as? Value
        } else if Value.self == NSColor.self {
            return (try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)) as? Value
        }
        return nil
    }
    
    /// Returns the value for the specified type as a codable type.
    @_disfavoredOverload
    public func value<Value: PasteboardReading>(forType type: NSPasteboard.PasteboardType) -> Value? {
        if Value.self == String.self || Value.self == NSString.self {
            return string(forType: type) as? Value
        }
        guard let data = data(forType: type) else { return nil }
        if Value.self == URL.self || Value.self == NSURL.self {
            return URL(dataRepresentation: data, relativeTo: nil) as? Value
        } else if Value.self == NSImage.self {
            return NSImage(data: data) as? Value
        } else if Value.self == NSAttributedString.self {
            return NSAttributedString(rtf: data, documentAttributes: nil) as? Value
        } else if Value.self == NSSound.self {
            return NSSound(data: data) as? Value
        } else if Value.self == NSColor.self {
            return (try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)) as? Value
        } else if Value.self == AttributedString.self, let value: NSAttributedString = value(forType: type) {
            return AttributedString(value) as? Value
        }
        return nil
    }
    
    /// Returns the value for the specified type as a codable type.
    @_disfavoredOverload
    public func value<Value: Codable>(forType type: NSPasteboard.PasteboardType) -> Value? {
        if Value.self == String.self {
            return string(forType: type) as? Value
        }
        guard let data = data(forType: type) else { return nil }
        if Value.self == URL.self {
            return URL(dataRepresentation: data, relativeTo: nil) as? Value
        } else if Value.self == NSImage.self {
            return NSImage(data: data) as? Value
        } else if Value.self == NSAttributedString.self {
            return NSAttributedString(rtf: data, documentAttributes: nil) as? Value
        } else if Value.self == NSSound.self {
            return NSSound(data: data) as? Value
        } else if Value.self == NSColor.self {
            return (try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)) as? Value
        }
        return try? JSONDecoder().decode(Value.self, from: data)
    }
    
    /// Sets the value for a specified type as a codable type.
    @discardableResult
    public func setValue<Value: NSPasteboardWriting>(_ value: Value, forType type: NSPasteboard.PasteboardType) -> Bool {
        if let string = value as? NSString {
            return setString(string as String, forType: type)
        } else if let value = value as? NSURL {
            return setData(value.dataRepresentation, forType: type)
        } else if let value = value as? NSColor {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSSound {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSAttributedString {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSImage {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        }
        return false
    }

    /// Sets the value for a specified type as a codable type.
    @_disfavoredOverload
    @discardableResult
    public func setValue<Value: PasteboardWriting>(_ value: Value, forType type: NSPasteboard.PasteboardType) -> Bool {
        if let string = value as? String {
            return setString(string as String, forType: type)
        } else if let value = value as? URL {
            return setData(value.dataRepresentation, forType: type)
        } else if let value = value as? NSColor {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSSound {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSAttributedString {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSImage {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        }
        return false
    }
    
    /// Sets the value for a specified type as a codable type.
    @_disfavoredOverload
    @discardableResult
    public func setValue<Value: Codable>(_ value: Value, forType type: NSPasteboard.PasteboardType) -> Bool {
        if let string = value as? String {
            return setString(string, forType: type)
        } else if let value = value as? URL {
            return setData(value.dataRepresentation, forType: type)
        } else if let value = value as? NSColor {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSSound {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSAttributedString {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        } else if let value = value as? NSImage {
            guard let data = try? value.archivedData() else { return false }
            return setData(data, forType: type)
        }
        do {
            return setData(try JSONEncoder().encode(value), forType: type)
        } catch {
            return false
        }
    }
    
    private func setValue<Value: PasteboardWriting>(_ value: Value?, forType type: NSPasteboard.PasteboardType) {
        guard let value = value else { return }
        setValue(value, forType: type)
    }
}

public extension Sequence where Element: NSPasteboardItem {
    /// The strings of the pasteboard items.
    var strings: [String] {
        compactMap({$0.string})
    }
    
    /// The attributed strings of the pasteboard items.
    var attributedStrings: [NSAttributedString] {
        compactMap({$0.attributedString})
    }
    
    /// The images of the pasteboard items.
    var images: [NSImage] {
        compactMap({$0.tiffImage ?? $0.pngImage})
    }
    
    /// The urls of the pasteboard items.
    var urls: [URL] {
        compactMap({$0.url})
    }
    
    /// The file urls of the pasteboard items.
    var fileURLs: [URL] {
        compactMap({$0.fileURL})
    }
       
    /// The sounds of the pasteboard items.
    var sounds: [NSSound] {
        compactMap({$0.sound})
    }
    
    /// The colors of the pasteboard items.
    var colors: [NSColor] {
        compactMap({$0.color})
    }
}

#endif
