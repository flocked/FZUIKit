//
//  AVURLAsset+.swift
//
//
//  Created by Florian Zand on 07.08.22.
//

import Foundation 
import AVFoundation
import UniformTypeIdentifiers

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension AVURLAsset {
    /// A Boolean value indicating whether `AVURLAsset` supports files with the specified path extension.
    public static func supports(filenameExtension: String) -> Bool {
        guard let contentType = UTType(filenameExtension: filenameExtension) else { return false }
        return supports(contentType)
    }
    
    /// A Boolean value indicating whether `AVURLAsset` supports the specified content type.
    public static func supports(_ contentType: UTType) -> Bool {
        audiovisualContentTypes().contains(where: { contentType.conforms(to: $0) })
    }
    
    /// Returns an array of the content types the asset supports.
    public static func audiovisualContentTypes() -> [UTType] {
        AVURLAsset.audiovisualTypes().compactMap { UTType($0.rawValue) }
    }
    
    /// Returns an array of the audio content types the asset supports.
    public static func audioContentTypes()-> [UTType] {
        audiovisualContentTypes().filter({ $0.conforms(to: .audio) && !$0.conforms(to: .movie) })
    }
    
    /// Returns an array of the video content types the asset supports.
    public static func videoContentTypes()-> [UTType] {
        audiovisualContentTypes().filter({ !$0.conforms(to: .audio) && $0.conforms(to: .movie) })
    }
}
