//
//  NSUIImage+GifData.swift
//
//
//  Created by Florian Zand on 24.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import MobileCoreServices
import UIKit
#endif

public extension NSUIImage {
    class func gifData(from images: [NSUIImage], duration: TimeInterval) -> Data? {
        let frameDuration = duration / TimeInterval(images.count)
        return gifData(from: images, frameDuration: frameDuration)
    }

    class func gifData(from images: [NSUIImage], frameDuration: TimeInterval) -> Data? {
        let data = NSMutableData()
        let frameDuration = frameDuration * 2
        guard let dest = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypePNG, images.count, nil) else { return nil }
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        CGImageDestinationSetProperties(dest, fileProperties as CFDictionary)
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDuration]]
        for image in images {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(dest, cgImage, gifProperties as CFDictionary?)
            }
        }
        CGImageDestinationFinalize(dest)
        return data as Data
    }
}
#endif
