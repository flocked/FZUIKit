//
//  AVAsynchronousKeyValueLoading+Values.swift
//
//
//  Created by Florian Zand on 20.06.24.
//

import Foundation
import AVFoundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AVAsynchronousKeyValueLoading where Self: AVAsset {
    /// The values of the asset (loaded synchronously).
    var values: AVKeyValues<Self> {
        AVKeyValues(self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AVAsynchronousKeyValueLoading where Self: AVMetadataItem {
    /// The values of the metadata item (loaded synchronously).
    var values: AVKeyValues<Self> {
        AVKeyValues(self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
/// The values of an AVAsset or AVMetadataItem (loaded synchronously).
public class AVKeyValues<T: AVAsynchronousKeyValueLoading> {
    private weak var object: T?
    internal init(_ object: T) {
        self.object = object
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AVKeyValues where T: AVAsset {
    
    // MARK: - Loading Duration and Timing
    
    /// A time value that represents the duration of the asset.
    var duration: CMTime? {
        try? object?.load(.duration)
    }
        
    /// A Boolean value that indicates whether the asset provides precise duration and timing.
    var providesPreciseDurationAndTiming: Bool? {
        try? object?.load(.providesPreciseDurationAndTiming)
    }
    
    /// A time value that indicates how closely playback follows the latest live stream content.
    var minimumTimeOffsetFromLive: CMTime? {
        try? object?.load(.minimumTimeOffsetFromLive)
    }
    
    // MARK: - Loading Tracks
    
    /// The tracks of media that an asset contains.
    var tracks: [AVAssetTrack]? {
        try? object?.load(.tracks)
    }
    
    // MARK: - Loading Track Groups
    
    /// The track groups an asset contains.
    var trackGroups: [AVAssetTrackGroup]? {
        try? object?.load(.trackGroups)
    }
    
    // MARK: - Loading Metadata
    
    /// The metadata items that an asset contains for common metadata identifiers.
    var metadata: [AVMetadataItem]? {
        try? object?.load(.metadata)
    }
    
    /// The formats of metadata that an asset contains.
    var availableMetadataFormats: [AVMetadataFormat]? {
        try? object?.load(.availableMetadataFormats)
    }
    
    /// A metadata item that indicates the creation date of an asset.
    var creationDate: AVMetadataItem? {
        try? object?.load(.creationDate)
    }
    
    /// The lyrics of the asset in a language suitable for the current locale.
    var lyrics: String? {
        try? object?.load(.lyrics)
    }
    
    // MARK: - Loading Suitability
    
    /// A Boolean value that indicates whether an asset contains playable content.
    var isPlayable: Bool? {
        try? object?.load(.isPlayable)
    }
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// A Boolean value that indicates whether you can export an asset using an export session.
    var isExportable: Bool? {
        try? object?.load(.isExportable)
    }
    
    /// A Boolean value that indicates whether you can extract the asset’s media data using an asset reader.
    var isReadable: Bool? {
        try? object?.load(.isReadable)
    }
    #endif
    
    /// A Boolean value that indicates whether you can use the asset in a media composition.
    var isComposable: Bool? {
        try? object?.load(.isComposable)
    }
    
    #if os(iOS) || os(tvOS)
    /// A Boolean value that indicates whether the asset provides precise duration and timing.
    var isCompatibleWithSavedPhotosAlbum: Bool? {
        try? object?.load(.isCompatibleWithSavedPhotosAlbum)
    }
    #endif
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// A Boolean value that indicates whether the asset is compatible with AirPlay Video.
    var isCompatibleWithAirPlayVideo: Bool? {
        try? object?.load(.isCompatibleWithAirPlayVideo)
    }
    #endif
    
    // MARK: - Loading Asset Preferences
    
    /// The asset’s rate preference for playing its media.
    var preferredRate: Float? {
        try? object?.load(.preferredRate)
    }
    
    /// The asset’s transform preference to apply to its visual content during presentation or processing.
    var preferredTransform: CGAffineTransform? {
        try? object?.load(.preferredTransform)
    }
    
    /// The asset’s volume preference for playing its audible media.
    var preferredVolume: Float? {
        try? object?.load(.preferredVolume)
    }
    
    #if os(tvOS)
    /// The asset’s display mode preference for optimal playback of its content.
    var preferredDisplayCriteria: AVDisplayCriteria? {
        try? object?.load(.preferredDisplayCriteria)
    }
    #endif
    
    // MARK: - Loading Media Selections
    
    /// The available media selections for an asset.
    var allMediaSelections: [AVMediaSelection]? {
        try? object?.load(.allMediaSelections)
    }
    
    /// The default media selections for the media selection groups of an asset.
    var preferredMediaSelection: AVMediaSelection? {
        try? object?.load(.preferredMediaSelection)
    }
    
    /// The media characteristics that provide media selection options.
    var availableMediaCharacteristicsWithMediaSelectionOptions: [AVMediaCharacteristic]? {
        try? object?.load(.availableMediaCharacteristicsWithMediaSelectionOptions)
    }
    
    // MARK: - Loading Chapter Metadata
    
    /// The locales of an asset’s chapter metadata.
    var availableChapterLocales: [Locale]? {
        try? object?.load(.availableChapterLocales)
    }
    
    // MARK: - Content Protections
    
    #if os(macOS) || os(iOS) || os(tvOS)
    /// A Boolean value that indicates whether the asset contains protected content.
    var hasProtectedContent: Bool? {
        try? object?.load(.hasProtectedContent)
    }
    
    // MARK: - Fragment Support
    
    /// A Boolean value that indicates whether you can extend the asset by fragments.
    var canContainFragments: Bool? {
        try? object?.load(.canContainFragments)
    }
    
    /// A Boolean value that indicates whether at least one movie fragment extends the asset.
    var containsFragments: Bool? {
        try? object?.load(.containsFragments)
    }
    #endif
    
    /// A hint to the total duration of fragments that currently exist or may exist in the future.
    var overallDurationHint: CMTime? {
        try? object?.load(.overallDurationHint)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AVKeyValues where T: AVURLAsset {
    
    // MARK: - Loading Variants

    /// An array of variants that an asset contains.
    var variants: [AVAssetVariant]? {
        try? object?.load(.variants)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AVKeyValues where T: AVMetadataItem {
    
    // MARK: - Loading Values
    
    /// The value of the metadata item.
    var value: (NSCopying & NSObjectProtocol)? {
        try? object?.load(.value)
    }
    
    /// A dictionary of additional attributes for the item.
    var extraAttributes: [AVMetadataExtraAttributeKey : Any]? {
        try? object?.load(.extraAttributes)
    }
    
    /// The value of the metadata item as a string.
    var stringValue: String? {
        try? object?.load(.stringValue)
    }
    
    /// The value of the metadata item as a number.
    var numberValue: NSNumber? {
        try? object?.load(.numberValue)
    }
    
    /// The value of the metadata item as a data.
    var dataValue: Data? {
        try? object?.load(.dataValue)
    }
    
    /// The value of the metadata item as a date.
    var dateValue: Date? {
        try? object?.load(.dateValue)
    }
}
