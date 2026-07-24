//
//  AVAsset+.swift
//
//
//  Created by Florian Zand on 07.08.22.
//

import AVFoundation
import Foundation
import FZSwiftUtils
#if os(macOS)
import AppKit
#endif

public extension AVAsset {
    /// The natural dimensions of a video asset.
    var videoNaturalSize: CGSize? {
        guard let track = tracks(withMediaType: .video).first else { return nil }
        return CGRect(origin: .zero, size: track.naturalSize).applying(track.preferredTransform).standardized.size
    }

    /// The codec of a video asset.
    var videoCodec: AVAssetTrack.VideoCodec? {
        tracks.lazy.compactMap(\.videoCodec).first
    }

    /// The codec string of a video asset.
    var videoCodecString: String? {
        tracks.lazy.compactMap(\.videoCodecString).first
    }

    /// The sample rate of a asset with an audio track.
    var audioSampleRate: Float64? {
        tracks.lazy.compactMap(\.audioSampleRate).first
    }

    /// The number of audio channels.
    var audioChannels: Int {
        tracks.lazy.compactMap(\.audioChannels).max() ?? 0
    }
    
    /// The duration of the asset.
    var timeDuration: TimeDuration? {
        (try? load(.duration)).map({ .seconds($0.seconds) })
    }
    
    /// A Boolean value indicating whether the the asset has audio.
    var hasAudio: Bool {
        audioChannels > 0
    }
    
    /// A Boolean value indicating whether the the asset has video.
    var hasVideo: Bool {
        tracks.contains(where: { $0.mediaType == .video })
    }
    
    #if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
    /// Creates an object to read media data from the asset.
    func reader() throws -> AVAssetReader {
        try AVAssetReader(asset: self)
    }
    
    /**
     Returns the video frames as an array of `CGImage`.
     
     If the asset doesn't contain a video track, it returns an empty array.
     */
    var videoFrames: [CGImage] {
        videoImageBuffers.map({ CGImage(cvPixelBuffer: $0) })
    }
    
    private var videoImageBuffers: [CVImageBuffer] {
        guard let reader = try? reader(), let videoTrack = tracks(withMediaType: .video).first else { return [] }
        let trackReaderOutput = videoTrack.reader(outputSettings: [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
        reader.add(trackReaderOutput)
        reader.startReading()
        return trackReaderOutput.imageBuffers()
    }
    #endif
    
    #if os(macOS)
    /**
     Returns gif data for a video asset.
     
     - Parameters:
        - uniqueFrames: A Boolean value indicating whether the gif should only use unique video frames.
        - duration: The gif animation duration, or `nil` to use the video duration.
     */
    func gifData(uniqueFrames: Bool = true, duration: Double? = nil) -> Data? {
        NSUIImage.gifData(from: (uniqueFrames ? videoFrames.uniqueImages() : videoFrames).map({$0.nsUIImage}), duration: duration ?? timeDuration?.seconds ?? self.duration.seconds)
    }
    
    /**
     Returns an animated image for a video asset.
     
     - Parameters:
        - uniqueFrames: A Boolean value indicating whether the animated image should only use unique video frames.
        - duration: The image animation duration, or `nil` to use the video duration.
     */
    func animatedImage(uniqueFrames: Bool = true, duration: CGFloat? = nil) -> NSUIImage? {
        NSUIImage.animatedImage(with: (uniqueFrames ? videoFrames.uniqueImages() : videoFrames).map({$0.nsUIImage}), duration: duration ?? timeDuration?.seconds ?? self.duration.seconds)
    }
    #endif
}

public extension AVAssetTrack {
    /// Creates an object that reads media data from the asset track.
    var reader: AVAssetReaderTrackOutput {
        reader(outputSettings: nil)
    }
    
    /**
     Creates an object that reads media data from the asset track.
     
     - Parameter outputSettings: A dictionary of settings to use for sample output, or `nil` to receive samples in their storage format.
     
        You use keys and values from [Audio settings](https://developer.apple.com/documentation/avfoundation/audio-settings), [Video settings](https://developer.apple.com/documentation/avfoundation/video-settings), or [CVPixelBuffer](https://developer.apple.com/documentation/corevideo/cvpixelbuffer), depending on the media type and the output format you require.
     */
    func reader(outputSettings: [String : Any]?) -> AVAssetReaderTrackOutput {
        .init(track: self, outputSettings: outputSettings)
    }
    
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
