//
//  AVAsset+.swift
//
//
//  Created by Florian Zand on 07.08.22.
//

import AVFoundation
import Foundation

public extension AVAsset {
    var videoNaturalSize: CGSize? {
        guard let track = tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }

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

    var videoCodecString: String? {
        let formatDescriptions = tracks.flatMap { $0.formatDescriptions }
        let mediaSubtypes = formatDescriptions
            .filter { CMFormatDescriptionGetMediaType($0 as! CMFormatDescription) == kCMMediaType_Video }
            .map { CMFormatDescriptionGetMediaSubType($0 as! CMFormatDescription).string }
        return mediaSubtypes.first
    }

    var audioSampleRate: Float64? {
        return tracks.compactMap { $0.audioSampleRate }.first
    }

    var audioChannels: Int? {
        return tracks.compactMap { $0.audioChannels }.max()
    }

    enum VideoOrientation: String {
        case vertical
        case horizontal
        case square
    }

    enum VideoCodec: String {
        case avc1
        case hvc1
        case mp4v
    }
}

public extension AVAssetTrack {
    var audioSampleRate: Float64? {
        for item in (formatDescriptions as? [CMAudioFormatDescription]) ?? [] {
            let basic = CMAudioFormatDescriptionGetStreamBasicDescription(item)
            if let sampleRate = basic?.pointee.mSampleRate {
                return sampleRate
            }
        }
        return nil
    }

    var audioChannels: Int {
        for item in (formatDescriptions as? [CMAudioFormatDescription]) ?? [] {
            let basic = CMAudioFormatDescriptionGetStreamBasicDescription(item)
            if let channelsCount = basic?.pointee.mChannelsPerFrame, channelsCount != 0 {
                return Int(channelsCount)
            }
        }
        return 0
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
