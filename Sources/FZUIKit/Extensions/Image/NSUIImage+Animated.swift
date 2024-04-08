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

         - Parameters:
            - images: The images to be used.
            - duration: The animation duration.
            - loopCount: The number of times that an animated image should play before stopping. A value of `0` indicates that the animated image doesn't stop.
         */
        static func animatedImage(images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) -> NSUIImage? {
            guard let gifData = NSUIImage.gifData(from: images, duration: duration, loopCount: loopCount) else { return nil }
            return NSUIImage(data: gifData)
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
        
        internal static func animatedImage(imageSource: ImageSource, duration: TimeInterval? = nil, loopCount: Int? = nil) -> NSUIImage? {
            guard let images = try? imageSource.images().collect().compactMap({$0.nsUIImage}), images.count > 1 else { return nil }
            let duration = duration ?? imageSource.animationDuration ?? (Double(imageSource.count) * ImageSource.defaultFrameDuration)
            let loopCount = loopCount ?? imageSource.properties()?.loopCount ?? 0
            return animatedImage(images: images, duration: duration, loopCount: loopCount)
        }
        
        /**
         Creates an animated image from the specified images.
         
         - Parameters:
            - images: The images to be used.
            - duration: The animation duration.
            - loopCount: The number of times that an animated image should play before stopping. A value of `0` indicates that the animated image doesn't stop.
         */
        convenience init?(animated images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) {
            guard let gifData = NSUIImage.gifData(from: images, duration: duration, loopCount: loopCount) else { return nil }
            self.init(data: gifData)
        }
        
        /**
         Creates an animated image from the specified name.
         
         - Parameters:
            - name: The name of the image file.
            - bundle: The bundle containing the image file.
            - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
            - loopCount: The number of times that an animated image should play before stopping, or `nil` to use the loop count of the image at the specified url. A value of `0` indicates that the animated image doesn't stop.
         */
        convenience init?(animated name: String, in bundle: Bundle = .main, duration: TimeInterval? = nil, loopCount: Int? = nil) {
            guard let url = bundle.url(forResource: name, withExtension: "gif") else { return nil }
            self.init(animated: url, duration: duration, loopCount: loopCount)
        }
        
        /**
         Creates an animated image from the specified data of an animated image.
         
         - Parameters:
            - data: The data to the animated image.
            - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
            - loopCount: The number of times that an animated image should play before stopping, or `nil` to use the loop count of the image at the specified url. A value of `0` indicates that the animated image doesn't stop.
         */
        convenience init?(animated data: Data, duration: TimeInterval? = nil, loopCount: Int? = nil) {
            guard let imageSource = ImageSource(data: data) else { return nil }
            self.init(animated: imageSource, duration: duration, loopCount: loopCount)
        }
                
        /**
         Creates an animated image from the specified url of an animated image.
         
         - Parameters:
            - url: The url of the animated image.
            - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
            - loopCount: The number of times that an animated image should play before stopping, or `nil` to use the loop count of the image at the specified url. A value of `0` indicates that the animated image doesn't stop.
         */
        convenience init?(animated url: URL, duration: TimeInterval? = nil, loopCount: Int? = nil) {
            guard let imageSource = ImageSource(url: url) else { return nil }
            self.init(animated: imageSource, duration: duration, loopCount: loopCount)
        }
        
        internal convenience init?(animated imageSource: ImageSource, duration: TimeInterval? = nil, loopCount: Int? = nil) {
            guard let images = try? imageSource.images().collect().compactMap({$0.nsUIImage}), images.count > 1 else { return nil }
            let duration = duration ?? imageSource.animationDuration ?? (Double(imageSource.count) * ImageSource.defaultFrameDuration)
            let loopCount = loopCount ?? imageSource.properties()?.loopCount ?? 0
            self.init(animated: images, duration: duration, loopCount: loopCount)
        }
        
        static func gifData(from images: [NSUIImage], duration: TimeInterval, loopCount: Int = 0) -> Data? {
            let frameDuration = duration / TimeInterval(images.count)
            return gifData(from: images, frameDuration: frameDuration, loopCount: loopCount)
        }

        internal static func gifData(from images: [NSUIImage], frameDuration: TimeInterval, loopCount: Int = 0) -> Data? {
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
        #else
        /**
         Creates and returns an animated image from the specified data of an animated image.

         - Parameters:
            - data: The data of the animated image.
            - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
         */
        static func animatedImage(data: Data, duration: TimeInterval? = nil) -> NSUIImage? {
            guard let imageSource = ImageSource(data: data) else { return nil }
            return animatedImage(imageSource: imageSource, duration: duration)
        }
        
        /**
         Creates and returns an animated image for the specified name.

         - Parameters:
            - name: The name of the image file.
            - bundle: The bundle containing the image file.
            - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
         */
        static func animatedImage(named name: String, in bundle: Bundle = .main, duration: TimeInterval? = nil) -> NSUIImage? {
            guard let url = bundle.url(forResource: name, withExtension: "gif") else { return nil }
            return animatedImage(url: url, duration: duration)
        }
        
        /**
         Creates and returns an animated image from the animated image at the specified url.

         - Parameters:
            - url: The url of the animated image.
            - duration: The animation duration, or `nil` to use the duration of the image at the specified url.
         */
        static func animatedImage(url: URL, duration: TimeInterval? = nil) -> NSUIImage? {
            guard let imageSource = ImageSource(url: url) else { return nil }
            return animatedImage(imageSource: imageSource, duration: duration)
        }
        
        internal static func animatedImage(imageSource: ImageSource, duration: TimeInterval? = nil) -> NSUIImage? {
            guard let images = try? imageSource.images().collect().compactMap({$0.nsUIImage}), images.count > 1 else { return nil }
            let duration = duration ?? imageSource.animationDuration ?? (Double(imageSource.count) * ImageSource.defaultFrameDuration)
            return animatedImage(with: images, duration: duration)
        }
        #endif
    }
#endif
