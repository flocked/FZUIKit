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
        import FZSwiftUtils

    public extension NSUIImage {
        /**
         Creates an animated image from the specified images.
         
         - Parameters:
            - url: The images to be used.
            - duration: The animation duration.
            - loopCount: The number of times that an animated image should play before stopping. A value of `0` indicates that the animated image doesn't stop.
         */
        class func animatedImage(with images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) -> NSUIImage? {
            guard let gifData = gifData(from: images, duration: duration, loopCount: loopCount) else { return nil }
            return NSUIImage(data: gifData)
        }
                
        /**
         Returns an animated image from the image at the specified url.
         
         - Parameters:
            - url: The url of the image.
            - duration: The animation duration, or `nil` to use the duration of the image.
            - loopCount: The number of times that an animated image should play before stopping, or `nil` to use the loop count of the image. A value of `0` indicates that the animated image doesn't stop.
         */
        class func animatedImage(from url: URL, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
            guard let imageSource = ImageSource(url: url), let images = try? imageSource.images().collect() else { return nil }
            let duration = duration ?? imageSource.animationDuration ?? (Double(imageSource.count) * ImageSource.defaultFrameDuration)
            let loopCount = imageSource.properties()?.loopCount ?? loopCount ?? 0
            return animatedImage(with: images.compactMap({$0.nsUIImage}), duration: duration, loopCount: loopCount)
        }
        
        /**
         Returns an animated image from the specified images and duration.
         
         - Parameters:
            - url: The images to be used.
            - duration: The animation duration.
            - loopCount: The number of times that an animated image should play before stopping. A value of `0` indicates that the animated image doesn't stop.
         */
        class func gifData(from images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) -> Data? {
            let frameDuration = duration / TimeInterval(images.count)
            return gifData(from: images, frameDuration: frameDuration, loopCount: loopCount)
        }

        internal class func gifData(from images: [NSUIImage], frameDuration: TimeInterval, loopCount: Int = 0) -> Data? {
            let data = NSMutableData()
            let frameDuration = frameDuration * 2
            guard let dest = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypePNG, images.count, nil) else { return nil }
            let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
            CGImageDestinationSetProperties(dest, fileProperties as CFDictionary)
            /// kCGImagePropertyGIFLoopCount
            let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDuration]]
            for image in images {
                if let cgImage = image.cgImage {
                    CGImageDestinationAddImage(dest, cgImage, gifProperties as CFDictionary?)
                }
            }
            if loopCount > 0 {
                let loopGiFProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]].cfDictionary
                CGImageDestinationSetProperties(dest, loopGiFProperties);
            }
            CGImageDestinationFinalize(dest)
            return data as Data
        }
    }
#endif
