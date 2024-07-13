//
//  NSUIImage+Codable.swift
//  
//
//  Created by Florian Zand on 13.07.24.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension NSUIImage: Codable {
    public enum CodingErrors: Error {
        case encodingFailed
        case decodingFailed
    }
    
    public func encode(to encoder: Encoder) throws {
        #if os(macOS)
        if let data = tiffData() {
            var container = encoder.singleValueContainer()
            try container.encode(data)
        } else {
            throw NSUIImage.CodingErrors.encodingFailed
        }
        #else
        if let data = self.pngData() {
            var container = encoder.singleValueContainer()
            try container.encode(data)
        } else {
            throw NSUIImage.CodingErrors.encodingFailed
        }
        #endif
    }
}

extension Decodable where Self: NSUIImage {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        if let image = Self.init(data: data) {
            self = image
        } else {
            throw NSUIImage.CodingErrors.decodingFailed
        }
    }
}
