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
        
        fileprivate init(_ description: AudioStreamBasicDescription) {
            sampleRate = description.mSampleRate
            channelsPerFrame = Int(description.mChannelsPerFrame)
            bitsPerChannel = description.mBitsPerChannel
            bytesPerFrame = description.mBytesPerFrame
            formatFlags = .init(description.mFormatFlags)
            codec = .init(description.mFormatID)
        }
    }
}

public struct FormatDescriptionExtensionInfo {
    public typealias Value = CMFormatDescription.Extensions.Value
    /// The mode that describes how the alpha channel is represented.
    public let alphaChannelMode: Value.AlphaChannelMode?
    /// The alternative transfer characteristics value.
    public let alternativeTransferCharacteristics: Value.TransferFunction?
    /// The ambient viewing environment information.
    public let ambientViewingEnvironment: Value?
    /// The auxiliary type information.
    public let auxiliaryTypeInfo: Value?
    /// The background color information.
    public let backgroundColor: Value?
    /// The number of bits in each image component.
    public let bitsPerComponent: Int?
    /// The number of bytes in each image row.
    public let bytesPerRow: Int?
    /// The chroma location for the bottom field.
    public let chromaLocationBottomField: Value.ChromaLocation?
    /// The chroma location for the top field.
    public let chromaLocationTopField: Value.ChromaLocation?
    /// The clean aperture dimensions and offsets.
    public let cleanAperture: Value?
    /// The color primaries used by the format.
    public let colorPrimaries: Value.ColorPrimaries?
    /// The MPEG-2 video profile to which the format conforms.
    public let conformsToMPEG2VideoProfile: Value.MPEG2VideoProfile?
    /// A Boolean value indicating whether the format contains an alpha channel.
    public let containsAlphaChannel: Bool?
    /// The content light level information.
    public let contentLightLevelInfo: Value?
    /// The default font name.
    public let defaultFontName: String?
    /// The default text style information.
    public let defaultStyle: Value?
    /// The default text display rectangle.
    public let defaultTextBox: Value?
    /// The pixel depth of the format.
    public let depth: Int?
    /// The text display flags.
    public let displayFlags: Value?
    /// The number of interlaced or progressive fields.
    public let fieldCount: Int?
    /// The field arrangement details.
    public let fieldDetail: Value.FieldDetail?
    /// The table that maps local font identifiers to font names.
    public let fontTable: [Int: String]?
    /// The human-readable format name.
    public let formatName: String?
    /// A Boolean value indicating whether the video uses the full component range.
    public let fullRangeVideo: Bool?
    /// The gamma level used by the format.
    public let gammaLevel: CGFloat?
    /// The horizontal text justification.
    public let horizontalJustification: Value.TextJustification?
    /// The ICC color profile data.
    public let iccProfile: CFData?
    /// The mastering display color volume information.
    public let masteringDisplayColorVolume: Value?
    /// The metadata key table.
    public let metadataKeyTable: Value?
    /// The original compression settings.
    public let originalCompressionSettings: Value?
    /// The horizontal and vertical pixel aspect ratio spacing.
    public let pixelAspectRatio: CGSize?
    /// The revision level of the format.
    public let revisionLevel: Int?
    /// The sample-description extension atoms.
    public let sampleDescriptionExtensionAtoms: Value?
    /// The source reference name and language code.
    public let sourceReferenceName: Value?
    /// The spatial quality value.
    public let spatialQuality: Int?
    /// The temporal quality value.
    public let temporalQuality: Int?
    /// The text justification.
    public let textJustification: Value.TextJustification?
    /// The transfer function used by the format.
    public let transferFunction: Value.TransferFunction?
    /// The vendor that created the format.
    public let vendor: Value.Vendor?
    /// The verbatim ISO sample-entry data.
    public let verbatimISOSampleEntry: CFData?
    /// The verbatim sample-description data.
    public let verbatimSampleDescription: CFData?
    /// The format version.
    public let version: Int?
    /// The vertical text justification.
    public let verticalJustification: Value.TextJustification?
    /// The YCbCr conversion matrix used by the format.
    public let yCbCrMatrix: Value.YCbCrMatrix?
    
    
    /// Creates extension information from the specified format-description extensions.
    public init(_ extensions: CMFormatDescription.Extensions) {
        alphaChannelMode = extensions[.alphaChannelMode]
        alternativeTransferCharacteristics = extensions[.alternativeTransferCharacteristics]
        ambientViewingEnvironment = extensions[.ambientViewingEnvironment]
        auxiliaryTypeInfo = extensions[.auxiliaryTypeInfo]
        backgroundColor = extensions[.backgroundColor]
        bitsPerComponent = extensions[.bitsPerComponent]
        bytesPerRow = extensions[.bytesPerRow]
        chromaLocationBottomField = extensions[.chromaLocationBottomField]
        chromaLocationTopField = extensions[.chromaLocationTopField]
        cleanAperture = extensions[.cleanAperture]
        colorPrimaries = extensions[.colorPrimaries]
        conformsToMPEG2VideoProfile = extensions[.conformsToMPEG2VideoProfile]
        containsAlphaChannel = extensions[.containsAlphaChannel]
        contentLightLevelInfo = extensions[.contentLightLevelInfo]
        defaultFontName = extensions[.defaultFontName]
        defaultStyle = extensions[.defaultStyle]
        defaultTextBox = extensions[.defaultTextBox]
        depth = extensions[.depth]
        displayFlags = extensions[.displayFlags]
        fieldCount = extensions[.fieldCount]
        fieldDetail = extensions[.fieldDetail]
        fontTable = extensions[.fontTable]
        formatName = extensions[.formatName]
        fullRangeVideo = extensions[.fullRangeVideo]
        gammaLevel = extensions[.gammaLevel]
        horizontalJustification = extensions[.horizontalJustification]
        iccProfile = extensions[.iccProfile]
        masteringDisplayColorVolume = extensions[.masteringDisplayColorVolume]
        metadataKeyTable = extensions[.metadataKeyTable]
        originalCompressionSettings = extensions[.originalCompressionSettings]
        if let dic: [String: CGFloat] = extensions[.pixelAspectRatio], let horizontal = dic["HorizontalSpacing"], let vertical = dic["VerticalSpacing"] {
            pixelAspectRatio = CGSize(horizontal, vertical)
        } else {
            pixelAspectRatio = nil
        }
        revisionLevel = extensions[.revisionLevel]
        sampleDescriptionExtensionAtoms = extensions[.sampleDescriptionExtensionAtoms]
        sourceReferenceName = extensions[.sourceReferenceName]
        spatialQuality = extensions[.spatialQuality]
        temporalQuality = extensions[.temporalQuality]
        textJustification = extensions[.textJustification]
        transferFunction = extensions[.transferFunction]
        vendor = extensions[.vendor]
        verbatimISOSampleEntry = extensions[.verbatimISOSampleEntry]
        verbatimSampleDescription = extensions[.verbatimSampleDescription]
        version = extensions[.version]
        verticalJustification = extensions[.verticalJustification]
        yCbCrMatrix = extensions[.yCbCrMatrix]
    }
}

public extension CMFormatDescription.Extensions {
    subscript<T>(_ key: Key) -> T? {
        self[key] as? T
    }
    
    subscript<T: RawRepresentable>(_ key: Key) -> T? {
        guard let rawValue = self[key]?.propertyListRepresentation as? T.RawValue else { return nil }
        return T(rawValue: rawValue)
    }
}
