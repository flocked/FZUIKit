//
//  AVAssetTrack+.swift
//  
//
//  Created by Florian Zand on 24.07.26.
//

import AVFoundation
import Foundation
import FZSwiftUtils

public extension AVAssetTrack {
    /// The natural size after applying the track's preferred transform.
    var transformedNaturalSize: CGSize {
        return CGRect(origin: .zero, size: naturalSize).applying(preferredTransform).standardized.size
    }
    
    /// Creates an object that reads media data from the asset track.
    var reader: AVAssetReaderTrackOutput {
        reader(outputSettings: nil)
    }
    
    /// The media subtypes of the track's format descriptions.
    var mediaSubTypes: Set<CMFormatDescription.MediaSubType> {
        Set(formatDescriptions.map({ ($0 as! CMFormatDescription).mediaSubType }))
    }
    
    /**
     Creates an object that reads media data from the asset track.
     
     - Parameter outputSettings: A dictionary of settings to use for sample output, or `nil` to receive samples in their storage format.
     
        You use keys and values from [Audio settings](https://developer.apple.com/documentation/avfoundation/audio-settings), [Video settings](https://developer.apple.com/documentation/avfoundation/video-settings), or [CVPixelBuffer](https://developer.apple.com/documentation/corevideo/cvpixelbuffer), depending on the media type and the output format you require.
     */
    func reader(outputSettings: [String : Any]?) -> AVAssetReaderTrackOutput {
        .init(track: self, outputSettings: outputSettings)
    }

    /// The codec used by the video track.
    var videoCodec: VideoCodec? {
        formatDescriptions.lazy.compactMap({ ($0 as! CMFormatDescription).videoCodec }).first
    }
    
    /// The codec used by the audio track.
    var audioCodec: FZSwiftUtils.AudioCodec? {        
        formatDescriptions.lazy.compactMap({ ($0 as! CMFormatDescription).audio?.codec }).first
    }
    
    /// The sample rate of the audio track.
    var audioSampleRate: Float64? {
        formatDescriptions.lazy.compactMap({ ($0 as! CMFormatDescription).audio?.sampleRate }).first
    }

    /// The number of channels in each frame of the audio track.
    var audioChannels: Int? {
        formatDescriptions.lazy.compactMap({ if let channel = ($0 as! CMFormatDescription).audio?.channelsPerFrame, channel > 0 { return channel } else { return nil } }).first
    }
}

public extension CMFormatDescription {
    /// The audio format information for the format description.
    var audio: AudioFormatDescription? {
        audioStreamBasicDescription.map({ .init($0) })
    }
    
    /// The video codec.
    var videoCodec:  VideoCodec? {
        mediaType == .video ? .init(mediaSubType.rawValue) : nil
    }
    
    /// Audio format information for a format description.
    struct AudioFormatDescription {
        /**
         The number of frames per second of the data in the stream, when playing the stream at normal speed.
         
         For compressed formats, this field indicates the number of frames per second of equivalent decompressed data.
         */
        let sampleRate: Float64
        
        /// The number of channels in each frame of audio data.
        let channelsPerFrame: Int
        
        /// The number of bits for one audio sample.
        let bitsPerChannel: UInt32
        
        /// The number of bytes from the start of one frame to the start of the next frame in an audio buffer.
        let bytesPerFrame: UInt32
        
        /// Audio format-specific flags to specify details of the format.
        let formatFlags: AudioFormatOptions
        
        /// The codec.
        let codec: FZSwiftUtils.AudioCodec
        
        /// The amount to pad the structure to force an even 8-byte alignment.
        let reserved: UInt32
        
        fileprivate init(_ description: AudioStreamBasicDescription) {
            sampleRate = description.mSampleRate
            channelsPerFrame = Int(description.mChannelsPerFrame)
            bitsPerChannel = description.mBitsPerChannel
            bytesPerFrame = description.mBytesPerFrame
            formatFlags = .init(description.mFormatFlags)
            codec = .init(description.mFormatID)
            reserved = description.mReserved
        }
    }
}
