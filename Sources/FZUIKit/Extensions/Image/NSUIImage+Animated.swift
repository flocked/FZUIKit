//
//  NSUIImage+Animated.swift
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
    #if os(macOS)
    /**
     Creates and returns an animated image from an existing set of images.
     
     All images included in the animated image should share the same size and scale.

     - Parameters:
        - images: The images to be used.
        - duration: The animation duration.
        - loopCount: The number of times that an animated image should play before stopping. A value of `0` indicates that the animated image doesn't stop.
     */
    static func animatedImage(with images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) -> NSUIImage? {
        guard let gifData = gifData(from: images, duration: duration, loopCount: loopCount) else { return nil }
        return NSUIImage(data: gifData)
    }
    #else
    /**
     Creates and returns an animated image from an existing set of images.
     
     All images included in the animated image should share the same size and scale.

     - Parameters:
        - images: The images to be used.
        - duration: The animation duration.
        - loopCount: The number of times that an animated image should play before stopping. A value of `0` indicates that the animated image doesn't stop.
     */
    static func animatedImage(with images: [NSUIImage], duration: TimeInterval, loopCount: Int) -> NSUIImage? {
        if loopCount == 0 {
            return animatedImage(with: images, duration: duration)
        }
        guard let gifData = gifData(from: images, duration: duration, loopCount: loopCount) else { return nil }
        return NSUIImage(data: gifData)
    }
    #endif
    
    /**
     Creates and returns an animated image from an existing set of images.
     
     All images included in the animated image should share the same size and scale.

     - Parameters:
        - images: The images and their frame durations to be used.
        - loopCount: The number of times that an animated image should play before stopping. A value of `0` indicates that the animated image doesn't stop.
     */
    static func animatedImage(with images: [(image: NSUIImage, duration: TimeInterval)], loopCount: Int = 0) -> NSUIImage? {
        guard let gifData = gifData(from: images, loopCount: loopCount) else { return nil }
        return NSUIImage(data: gifData)
    }
    
    private static func animatedImage(imageSource: ImageSource, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
        guard let images = try? imageSource.images().collect().compactMap({$0.nsUIImage}), images.count > 1 else { return nil }
        let duration = duration ?? imageSource.animationDuration ?? (Double(imageSource.count) * ImageSource.defaultFrameDuration)
        let loopCount = loopCount ?? imageSource.properties()?.loopCount ?? 0
        return animatedImage(with: images, duration: duration, loopCount: loopCount)
    }
    
    /**
     Creates and returns an animated image from the specified data of an animated image.

     - Parameters:
        - data: The data of the animated image.
        - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
        - loopCount: The number of times that an animated image should play before stopping, or `nil` to use the loop count of the image at the specified url. A value of `0` indicates that the animated image doesn't stop.
     */
    static func animatedImage(data: Data, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
        guard let imageSource = ImageSource(data: data) else { return nil }
        return animatedImage(imageSource: imageSource, duration: duration, loopCount: loopCount)
    }
        
    /**
     Creates and returns an animated image for the specified name.

     - Parameters:
        - name: The name of the image file.
        - bundle: The bundle containing the image file.
        - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
        - loopCount: The number of times that an animated image should play before stopping, or `nil` to use the loop count of the image at the specified url. A value of `0` indicates that the animated image doesn't stop.
     */
    static func animatedImage(named name: String, in bundle: Bundle = .main, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
        guard let url = bundle.url(forResource: name, withExtension: "gif") else { return nil }
        return animatedImage(url: url, duration: duration, loopCount: loopCount)
    }
        
    /**
     Creates and returns an animated image from the animated image at the specified url.

     - Parameters:
        - url: The url of the animated image.
        - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
        - loopCount: The number of times that an animated image should play before stopping, or `nil` to use the loop count of the image at the specified url. A value of `0` indicates that the animated image doesn't stop.
     */
    static func animatedImage(url: URL, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
        guard let imageSource = ImageSource(url: url) else { return nil }
        return animatedImage(imageSource: imageSource, duration: duration, loopCount: loopCount)
    }
    
    /**
     Creates `GIF` data from the specified images and duration

     - Parameters:
       - images: The images of the `GIF`.
        - duration: The duration of the `GIF`.
       - loopCount: The number of times the `GIF` should repeat. `0` means infinite looping.

     - Returns: A `Data` object containing `GIF` data, or `nil` if creation fails.
     */
    static func gifData(from images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) -> Data? {
        let frameDuration = duration / TimeInterval(images.count)
        return gifData(from: images, frameDuration: frameDuration, loopCount: loopCount)
    }

    private static func gifData(from images: [NSUIImage], frameDuration: TimeInterval, loopCount: Int = 0) -> Data? {
        guard !images.isEmpty else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeGIF, images.count, nil) else { return nil }
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]].cfDictionary
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDuration, kCGImagePropertyGIFUnclampedDelayTime as String: frameDuration]].cfDictionary
        CGImageDestinationSetProperties(destination, gifProperties)
        for image in images.compactMap({$0.cgImage}) {
            CGImageDestinationAddImage(destination, image, frameProperties)
        }
        CGImageDestinationFinalize(destination)
        return data as Data
    }
    
    /**
     Creates `GIF` data from an array of image-duration pairs.

     - Parameters:
       - images: The images of the `GIF` and their duration.
       - loopCount: The number of times the `GIF` should repeat. `0` means infinite looping.

     - Returns: A `Data` object containing `GIF` data, or `nil` if creation fails.
     */
    static func gifData(from images: [(image: NSUIImage, duration: TimeInterval)], loopCount: Int = 0) -> Data? {
        guard !images.isEmpty else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeGIF, images.count, nil) else { return nil }
        let gifProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]] as CFDictionary
        CGImageDestinationSetProperties(destination, gifProperties)
        for (img, duration) in images {
            guard let cgImage = img.cgImage else { continue }
            let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: duration, kCGImagePropertyGIFUnclampedDelayTime as String: duration]] as CFDictionary
            CGImageDestinationAddImage(destination, cgImage, frameProperties)
        }
        CGImageDestinationFinalize(destination)
        return data as Data
    }
}
#endif
