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
    public func encode(to encoder: Encoder) throws {
        #if os(macOS)
        if let data = tiffData() {
            var container = encoder.singleValueContainer()
            try container.encode(data)
        } else {
            throw EncodingError.invalidValue(NSNull(), .init(codingPath: encoder.codingPath, debugDescription: "The image must provide tiff data to be encodable."))
        }
        #else
        if let data = self.pngData() {
            var container = encoder.singleValueContainer()
            try container.encode(data)
        } else {
            throw EncodingError.invalidValue(NSNull(), .init(codingPath: encoder.codingPath, debugDescription: "The image must provide png data to be encodable."))
        }
        #endif
    }
}

extension Decodable where Self: NSUIImage {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let image = Self.init(data: try container.decode()) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid cookie properties")
        }
        self = image
    }
}
