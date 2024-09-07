//
//  AVAssetImageGenerator+.swift
//
//
//  Created by Florian Zand on 07.09.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Foundation
import AVFoundation
import FZSwiftUtils

public extension AVAsset {
    /// Returns an `AVAssetImageGenerator` instance.
    var imageGenerator: AVAssetImageGenerator {
        AVAssetImageGenerator(asset: self)
    }
}

public extension AVAssetImageGenerator {
    /**
     Generates images asynchronously for an array of requested times, and returns the results in a callback.
     
     - Parameters:
        - requestedTimes: An array of times in the video timeline for which to generate images.
        - handler: A callback that the image generator invokes for each requested image time.
     */
    func generateCGImagesAsynchronously(forTimes requestedTimes: [CMTime], completionHandler handler: @escaping AVAssetImageGeneratorCompletionHandler) {
        generateCGImagesAsynchronously(forTimes: requestedTimes.compactMap({ $0.nsValue }), completionHandler: handler)
    }
    
    /**
     Generates images asynchronously and returns the results in a callback.
     
     - Parameters:
        - amount: The amount of images to generate.
        - handler: A callback that the image generator invokes for each requested image time.
     */
    func generateCGImagesAsynchronously(amount: Int, completionHandler handler: @escaping CompletionHandler) {
        guard amount > 0 else { return }
        let times = times(amount: amount)
        generateCGImagesAsynchronously(forTimes: times) { requestedTime, image, actualTime, result, error in
            handler(times.firstIndex(of: requestedTime) ?? 0, image, actualTime, result, error)
        }
    }
    
    /**
     Generates images asynchronously for an array of requested percentages, and returns the results in a callback.
     
     - Parameters:
        - percentages: An array of percentages of time within the video timeline
        - handler: A callback that the image generator invokes for each requested image time.
     */
    func generateCGImagesAsynchronously(forPercentages percentages: [CGFloat], completionHandler handler: @escaping PercentagesCompletionHandler) {
        guard !percentages.isEmpty else { return }
        let times = times(percentages: percentages)
        generateCGImagesAsynchronously(forTimes: times) { requestedTime, image, actualTime, result, error in
            handler(percentages[times.firstIndex(of: requestedTime) ?? 0], image, actualTime, result, error)
        }
    }
    
    /**
     Generates images.
     
     - Parameter amount: The amount of images to generate.
     - Returns: An asynchronous sequence of images.
     */
    @available(macOS 13, iOS 16, tvOS 16, *)
    func images(amount: Int) -> AVAssetImageGenerator.Images {
        images(for: times(amount: amount))
    }
    
    /**
     Generates images for the specified percentages of time within the video timeline.
     
     - Parameter percentages: Percentages of the time within the video timeline.
     - Returns: An asynchronous sequence of images.
     */
    @available(macOS 13, iOS 16, tvOS 16, *)
    func images(forPercentages percentages: [CGFloat]) -> AVAssetImageGenerator.Images {
        images(for: times(percentages: percentages))
    }
    
    /**
     A type alias for a closure that provides the result of an image generation request.
     
     - Parameters:
        - percentage: The percentage of the time in the video timeline.
        - image: A generated image for the requested time.
        - time: The time in the video timeline at which it generated an image.
        - result: A value that indicates the result of the image generation request.
        - error: An optional error. If an error occurs the system provides an error object that provides the details of the failure.
     */
    typealias PercentagesCompletionHandler = (_ percentage: CGFloat, _ image: CGImage?, _ time: CMTime, _ result: AVAssetImageGenerator.Result, _ error: Error?) -> Void
    
    /**
     A type alias for a closure that provides the result of an image generation request.
     
     - Parameters:
        - index: The index of the result.
        - image: A generated image for the requested time.
        - time: The time in the video timeline at which it generated an image.
        - result: A value that indicates the result of the image generation request.
        - error: An optional error. If an error occurs the system provides an error object that provides the details of the failure.
     */
    typealias CompletionHandler = (_ index: Int, _ image: CGImage?, _ time: CMTime, _ result: AVAssetImageGenerator.Result, _ error: Error?) -> Void
    
    internal func times(percentages: [CGFloat]) -> [CMTime] {
        let duration = duration
        return percentages.compactMap({$0.clamped(to: 0...1.0 ) * duration.seconds }).compactMap({ CMTime(seconds: $0) })
    }
    
    internal func times(amount: Int) -> [CMTime] {
        let duration = duration
        let seconds = duration.seconds / CGFloat(amount + 1)
        var times: [CMTime] = []
        for i in 0..<amount {
            times.append(CMTime(seconds: CGFloat(i+1) * seconds))
        }
        return times
    }
    
    internal var duration: CMTime {
        if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
            return(try? asset.load(.duration)) ?? asset.duration
        } else {
            return asset.duration
        }
    }
}
#endif
