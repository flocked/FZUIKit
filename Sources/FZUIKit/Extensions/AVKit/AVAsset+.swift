//
//  AVAsset+.swift
//
//
//  Created by Florian Zand on 07.08.22.
//

import AVFoundation
import Foundation
import CoreImage

public extension AVAsset {
    /// The natural dimensions of a video asset.
    var videoNaturalSize: CGSize? {
        guard let track = tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }

    /// The orientation of a video asset.
    var videoOrientation: VideoOrientation? {
        guard let aspectRatio = videoNaturalSize?.aspectRatio else { return nil }
        if aspectRatio == 1.0 {
            return .square
        } else if aspectRatio < 1.0 {
            return .horizontal
        } else {
            return .vertical
        }
    }

    /// The codec of a video asset.
    var videoCodec: AVAssetTrack.VideoCodec? {
        tracks.compactMap(\.videoCodec).first
    }

    /// The codec string of a video asset.
    var videoCodecString: String? {
        tracks.compactMap(\.videoCodecString).first
    }

    /// The sample rate of a asset with an audio track.
    var audioSampleRate: Float64? {
        tracks.compactMap(\.audioSampleRate).first
    }

    /// The number of audio channels.
    var audioChannels: Int? {
        tracks.compactMap(\.audioChannels).max()
    }

    /// The video orientation.
    enum VideoOrientation: String {
        /// Vertical orientation.
        case vertical
        /// Horizontal orientation.
        case horizontal
        /// Square orientation.
        case square
    }
    
    /**
     Returns the video frames as an array of `CGImage`.
     
     If the asset doesn't contain a video track, it returns an empty array.
     
     - Parameter unique: A 
     
     */
    func videoFrames(unique: Bool = false) -> [CGImage] {
        videoImageBuffers.reduce(into: [CGImage]()) { frames, sample in
            let image = sample.cgImage
            if unique, let last = frames.last, !last.isEqual(to: image) {
                frames.append(image)
            } else if !unique {
                frames.append(image)
            }
        }
    }
    
    internal var videoImageBuffers: [CVImageBuffer] {
        guard let reader = try? AVAssetReader(asset: self), let videoTrack = tracks(withMediaType: .video).first else { return [] }
        let trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
        reader.add(trackReaderOutput)
        reader.startReading()
        return trackReaderOutput.imageBuffers()
    }
}

extension AVAssetReaderOutput {
    func sampleBuffers() -> [CMSampleBuffer] {
        var sampleBuffers: [CMSampleBuffer] = []
        while let sampleBuffer = copyNextSampleBuffer() {
            sampleBuffers.append(sampleBuffer)
        }
        return sampleBuffers
    }
    
    func imageBuffers() -> [CVImageBuffer] {
        sampleBuffers().compactMap({ CMSampleBufferGetImageBuffer($0) })
    }
}

extension Collection where Element == CGImage {
    func uniqueImages() -> [Element] {
        reduce(into: [CGImage]()) { images, image in
            if let last = images.last, !last.isEqual(to: image) {
                images.append(image)
            }
        }
    }
}

extension Collection where Element == NSUIImage {
    func uniqueImages() -> [Element] {
        reduce(into: [NSUIImage]()) { images, image in
            if let last = images.last, !last.isEqual(to: image) {
                images.append(image)
            }
        }
    }
}

extension CVImageBuffer {
    public var cgImage: CGImage {
        CIImage(cvPixelBuffer: self).cgImage
    }
}

public extension AVAssetTrack {
    /// The codec of a video track.
    enum VideoCodec: String {
        /// avc1 codec.
        case avc1
        /// hvc1 codec.
        case hvc1
        /// mp4v codec.
        case mp4v
    }

    /// The codec of a video track.
    var videoCodec: VideoCodec? {
        switch videoCodecString {
        case "avc1":
            return .avc1
        case "hvc1":
            return .hvc1
        case "mp4v":
            return .mp4v
        default:
            return nil
        }
    }

    /// The codec of a video track.
    var videoCodecString: String? {
        let formatDescriptions = formatDescriptions
        let mediaSubtypes = formatDescriptions
            .filter { CMFormatDescriptionGetMediaType($0 as! CMFormatDescription) == kCMMediaType_Video }
            .map { CMFormatDescriptionGetMediaSubType($0 as! CMFormatDescription).string }
        return mediaSubtypes.first
    }

    /// The sample rate of an audio track.
    var audioSampleRate: Float64? {
        for item in (formatDescriptions as? [CMAudioFormatDescription]) ?? [] {
            let basic = CMAudioFormatDescriptionGetStreamBasicDescription(item)
            if let sampleRate = basic?.pointee.mSampleRate {
                return sampleRate
            }
        }
        return nil
    }

    /// The number of channels of an audio track.
    var audioChannels: Int? {
        for item in (formatDescriptions as? [CMAudioFormatDescription]) ?? [] {
            let basic = CMAudioFormatDescriptionGetStreamBasicDescription(item)
            if let channelsCount = basic?.pointee.mChannelsPerFrame, channelsCount != 0 {
                return Int(channelsCount)
            }
        }
        return nil
    }
}

public extension FourCharCode {
    var string: String {
        let n = Int(self)
        var s = String(UnicodeScalar((n >> 24) & 255)!)
        s += String(UnicodeScalar((n >> 16) & 255)!)
        s += String(UnicodeScalar((n >> 8) & 255)!)
        s += String(UnicodeScalar(n & 255)!)
        return s.trimmingCharacters(in: .whitespaces)
    }
}
