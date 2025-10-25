//
//  NSColorList+.swift
//
//
//  Created by Florian Zand on 24.10.25.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSColorList {
    /// All colors of the color list.
    public var colors: [NSColor] {
        value(forKeySafely: "_colorArray") as? [NSColor] ?? allKeys.compactMap({ color(withKey: $0) })
    }
    
    /// All colors and their corresponding keys of the color list.
    public var keyedColors: [(key: String, color: NSColor)] {
        get { allKeys.compactMap { key in color(withKey: key).map { (key, $0) } } }
        set {
            guard isEditable else { return }
            let newKeys = Set(newValue.map(\.key))
            allKeys.filter { !newKeys.contains($0) }.forEach(removeColor(withKey:))
            newValue.indexed().forEach { index, element in
                insertColor(element.color, key: element.key, at: index)
            }
        }
    }
    
    /// Returns the color and it's key for the specified index in the color list.
    public subscript(index: Int) -> (key: String, color: NSColor)? {
        get {
            guard let key = allKeys[safe: index], let color = color(withKey: key) else { return nil }
            return (key, color)
        }
        set {
            guard isEditable, let oldKey = allKeys[safe: index] else { return }
            if let newValue = newValue {
                if oldKey != newValue.key {
                    removeColor(withKey: oldKey)
                }
                insertColor(newValue.color, key: newValue.key, at: index)
            } else {
                removeColor(withKey: oldKey)
            }
        }
    }
    
    /// Returns the color for the specified key.
    public subscript(key: String) -> NSColor? {
        get { color(withKey: key) }
        set {
            if let color = newValue {
                setColor(color, forKey: key)
            } else {
                removeColor(withKey: key)
            }
        }
    }
    
    /// Returns the color at the specified index in the color list.
    public func color(at index: Int) -> NSColor? {
        guard let key = allKeys[safe: index] else { return nil }
        return color(withKey: key)
    }
    
    /// Returns the key at the specified index in the color list.
    public func key(at index: Int) -> String? {
        allKeys[safe: index]
    }
    
    /// Returns the index of the specified key in the color list..
    public func index(of key: String) -> Int? {
        allKeys.firstIndex(of: key)
    }
    
    /// Returns the index of the specified color in the color list..
    public func index(of color: NSColor) -> Int? {
        allKeys.firstIndex(where: { self.color(withKey: $0) == color })
    }
}

#endif
