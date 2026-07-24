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
    /// The natural size of the asset's first video track after applying its preferred transform.
    var videoNaturalSize: CGSize? {
        tracks(withMediaType: .video).first?.transformedNaturalSize
    }
    
    /// The codecs used by the asset's audio tracks.
    var audioCodecs: [FZSwiftUtils.AudioCodec] {
        tracks.compactMap(\.audioCodec)
    }
    
    /// The codecs used by the asset's video tracks.
    var videoCodecs: [VideoCodec] {
        tracks.compactMap(\.videoCodec)
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
        !tracks(withMediaType: .audio).isEmpty
    }
    
    /// A Boolean value indicating whether the the asset has video.
    var hasVideo: Bool {
        !tracks(withMediaType: .video).isEmpty
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
