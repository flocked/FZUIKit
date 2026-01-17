//
//  NSUIColor+Codable.swift
//  
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS) || canImport(UIKit)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIColor: Swift.Encodable, Swift.Decodable {
    fileprivate enum CodingKeys: String, CodingKey {
        case light
        case dark
        case name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        #if os(macOS)
        let isCustomDynamicColor = object_getClass(self) == NSClassFromString("NSCustomDynamicColor")
        #else
        let isCustomDynamicColor = object_getClass(self) == NSClassFromString("UIDynamicProviderColor")
        #endif
        if isCustomDynamicColor {
            let dynamic = dynamicColors
            try container.encode(try NSKeyedArchiver.archivedData(withRootObject: dynamic.light, requiringSecureCoding:  true), forKey: .light)
            try container.encode(try NSKeyedArchiver.archivedData(withRootObject: dynamic.dark, requiringSecureCoding:  true), forKey: .dark)
            #if os(macOS)
            guard let name = colorName, UUID(uuidString: name) == nil else { return }
            try container.encode(name, forKey: .name)
            #endif
        } else {
            try container.encode(try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true), forKey: .light)
        }
    }
}

extension Decodable where Self: NSUIColor {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lightColor = try Self.unarchive(try container.decode(Data.self, forKey: .light))
        if let darkData = try container.decodeIfPresent(Data.self, forKey: .dark) {
            let darkColor = try Self.unarchive(darkData)
            #if os(macOS)
            self = NSUIColor(name: try container.decodeIfPresent(String.self, forKey: .name), light: lightColor, dark: darkColor) as! Self
            #else
            self = NSUIColor(light: lightColor, dark: darkColor) as! Self
            #endif
        } else {
            self = lightColor
        }
    }
    
    private static func unarchive(_ data: Data) throws -> Self {
        //         guard let value = try NSKeyedUnarchiver.unarchivedObject(ofClass: Self.self, from: data) else {
        guard let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Self else { throw CocoaError(.coderReadCorrupt) }
        return color
    }
}
#endif
