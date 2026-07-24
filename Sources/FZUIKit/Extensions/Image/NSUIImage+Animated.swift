//
//  NSUIImage+Animated.swift
//
//
//  Created by Florian Zand on 24.03.23.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import MobileCoreServices
import UIKit
#endif
import FZSwiftUtils
import UniformTypeIdentifiers

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
     Creates and returns an animated image from the specified image data.

     - Parameters:
        - data: The image data.
        - duration: The total duration of the animation. If `nil`, the frame durations from the image data are used.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely. If `nil`, the loop count from the image data is used.
     - Returns: An animated image, or `nil` if the image data couldn't be loaded or doesn't contain multiple frames.
     */
    static func animatedImage(data: Data, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
        guard let imageSource = ImageSource(data: data) else { return nil }
        return animatedImage(for: imageSource, duration: duration, loopCount: loopCount)
    }
        
    /**
     Creates and returns an animated image with the specified resource name.

     - Parameters:
        - name: The name of the image resource.
        - bundle: The bundle containing the image resource.
        - duration: The total duration of the animation. If `nil`, the frame durations from the image resource are used.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely. If `nil`, the loop count from the image resource is used.
     - Returns: An animated image, or `nil` if the image resource couldn't be loaded or doesn't contain multiple frames.
     */
    static func animatedImage(named name: String, in bundle: Bundle = .main, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
        guard let url = bundle.url(forResource: name, withExtension: nil) ?? ["gif", "png", "heic", "heics", "webp"].lazy.compactMap({ bundle.url(forResource: name, withExtension: $0) }).first else { return nil }
        return animatedImage(at: url, duration: duration, loopCount: loopCount)
    }
        
    /**
     Creates and returns an animated image from the image at the specified URL.

     - Parameters:
        - url: The URL of the image.
        - duration: The total duration of the animation. If `nil`, the frame durations from the image are used.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely. If `nil`, the loop count from the image is used.
     - Returns: An animated image, or `nil` if the image couldn't be loaded or doesn't contain multiple frames.
     */
    static func animatedImage(at url: URL, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
        guard let imageSource = ImageSource(url: url) else { return nil }
        return animatedImage(for: imageSource, duration: duration, loopCount: loopCount)
    }
    
    private static func animatedImage(for imageSource: ImageSource, duration: TimeInterval?, loopCount: Int?) -> NSUIImage? {
        guard imageSource.count > 1 else { return nil }
        if let duration = duration {
            guard let images = try? imageSource.images().collect(), images.count > 1 else { return nil }
            guard let data = CGImage.gifData(from: images, frameDuration: duration/CGFloat(images.count), loopCount: imageSource.properties()?.loopCount ?? 0) else { return nil }
            return NSUIImage(data: data)
        } else {
            guard let frames = try? imageSource.imageFrames().collect(), frames.count > 1 else { return nil }
            guard let data = CGImage.gifData(from: frames, loopCount: imageSource.properties()?.loopCount ?? 0) else { return nil }
            return NSUIImage(data: data)
        }
    }
    
    /**
     Creates GIF data from the specified images.

     - Parameters:
        - images: The images to include in the GIF.
        - frameDuration: The duration of each frame.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely.
     - Returns: The GIF data, or `nil` if the GIF couldn't be created.
     */
    static func gifData(from images: [NSUIImage], frameDuration: TimeInterval, loopCount: Int = 0) -> Data? {
        CGImage.gifData(from: images.compactMap(\.cgImage), frameDuration: frameDuration, loopCount: loopCount)
    }
    
    /**
     Creates GIF data from the specified images.

     The total animation duration is distributed evenly across all frames.

     - Parameters:
        - images: The images to include in the GIF.
        - duration: The total duration of the animation.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely.
     - Returns: The GIF data, or `nil` if the GIF couldn't be created.
     */
    static func gifData(from images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) -> Data? {
        CGImage.gifData(from: images.compactMap(\.cgImage), duration: duration, loopCount: loopCount)
    }
    
    /**
     Creates GIF data from the specified image frames.

     Each frame's timing is taken from its `duration` and `unclampedDuration` properties. If a frame doesn't specify a duration, the previous frame's duration is used; otherwise, `defaultFrameDuration` is used.

     - Parameters:
        - frames: The frames to include in the GIF.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely.
        - defaultFrameDuration: The duration to use for any frame that doesn't specify a duration.
     - Returns: The GIF data, or `nil` if the GIF couldn't be created.
     */
    static func gifData(from frames: [NSUIImageFrame], loopCount: Int = 0, defaultFrameDuration: TimeInterval = 0.1) -> Data? {
        CGImage.gifData(from: frames.compactMap(\.cgFrame), loopCount: loopCount, defaultFrameDuration: defaultFrameDuration)
    }
}

public extension CGImage {
    /**
     Creates GIF data from the specified images.

     - Parameters:
        - images: The images to include in the GIF.
        - frameDuration: The duration of each frame.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely.
     - Returns: The GIF data, or `nil` if the GIF couldn't be created.
     */
    static func gifData(from images: [CGImage], frameDuration: TimeInterval, loopCount: Int = 0) -> Data? {
        gifData(from: images.map({ CGImageFrame(image: $0, duration: frameDuration) }), defaultFrameDuration: frameDuration)
    }
    
    /**
     Creates GIF data from the specified images.

     The total animation duration is distributed evenly across all frames.

     - Parameters:
        - images: The images to include in the GIF.
        - duration: The total duration of the animation.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely.
     - Returns: The GIF data, or `nil` if the GIF couldn't be created.
     */
    static func gifData(from images: [CGImage], duration: TimeInterval, loopCount: Int = 0) -> Data? {
        guard !images.isEmpty else { return nil }
        return gifData(from: images, frameDuration: duration / TimeInterval(images.count), loopCount: loopCount)
    }
    
    /**
     Creates GIF data from the specified image frames.

     Each frame's timing is taken from its `duration` and `unclampedDuration` properties. If a frame doesn't specify a duration, the previous frame's duration is used; otherwise, `defaultFrameDuration` is used.

     - Parameters:
        - frames: The frames to include in the GIF.
        - loopCount: The number of times the animation repeats. Specify `0` to loop indefinitely.
        - defaultFrameDuration: The duration to use for any frame that doesn't specify a duration.
     - Returns: The GIF data, or `nil` if the GIF couldn't be created.
     */
    static func gifData(from frames: [CGImageFrame], loopCount: Int = 0, defaultFrameDuration: TimeInterval = 0.1) -> Data? {
        guard !frames.isEmpty else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, UTType.gif.identifier as CFString, frames.count, nil) else { return nil }
        let gifProperties = [kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: loopCount,
                kCGImagePropertyGIFHasGlobalColorMap: false]]
        CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
        var duration = max(defaultFrameDuration, 0.1)
        var unclampedDuration = max(defaultFrameDuration, 0.0)
        var frameProperties = [kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: duration,
                kCGImagePropertyGIFUnclampedDelayTime: unclampedDuration]]
        for frame in frames {
            if let newDuration = frame.duration, let newUnclampedDuration = frame.unclampedDuration, newDuration != duration || newUnclampedDuration != unclampedDuration {
                duration = newDuration
                unclampedDuration = newUnclampedDuration
                frameProperties = [kCGImagePropertyGIFDictionary: [
                    kCGImagePropertyGIFDelayTime: duration,
                    kCGImagePropertyGIFUnclampedDelayTime: unclampedDuration]]
            }
            CGImageDestinationAddImage(destination, frame.image, frameProperties as CFDictionary)
        }
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return data as Data
    }
}

extension NSUIImageFrame {
    var cgFrame: CGImageFrame? {
        guard let cgImage = image.cgImage else { return nil }
        return .init(image: cgImage, duration: duration)
    }
}
#endif
