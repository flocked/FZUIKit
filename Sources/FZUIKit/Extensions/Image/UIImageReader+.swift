//
//  UIImageReader+.swift
//  
//
//  Created by Florian Zand on 02.04.26.
//

#if canImport(UIKit)
import UIKit

@available(iOS 17.0, tvOS 17.0, watchOS 1.0, *)
public extension UIImageReader {
    /**
     Creates a image reader with the specified parameters.
     
     - Parameters:
        - pixelsPerInch: The integral scale that the image reader applies to the image.
        - preparesImagesForDisplay: A Boolean value that indicates whether the image reader prepares the image for display.
        - preferredThumbnailSize: The thumbnail size in pixels that the image reader makes the image.
     */
    init(pixelsPerInch: CGFloat = 0.0, preparesImagesForDisplay: Bool = false, preferredThumbnailSize: CGSize = .zero) {
        var configuration = Configuration()
        configuration.pixelsPerInch = pixelsPerInch
        configuration.preferredThumbnailSize = preferredThumbnailSize
        configuration.preparesImagesForDisplay = preparesImagesForDisplay
        self.init(configuration: configuration)
    }
    
    /**
     Creates a image reader with the specified parameters.
     
     - Parameters:
        - pixelsPerInch: The integral scale that the image reader applies to the image.
        - preparesImagesForDisplay: A Boolean value that indicates whether the image reader prepares the image for display.
        - prefersHighDynamicRange: A Boolean value that indicates whether the image reader should decode the image as HDR when the type is capable of decoding in either SDR or HDR.
        - preferredThumbnailSize: The thumbnail size in pixels that the image reader makes the image.
     */
    init(pixelsPerInch: CGFloat = 0.0, preparesImagesForDisplay: Bool = false, prefersHighDynamicRange: Bool, preferredThumbnailSize: CGSize = .zero) {
        var configuration = Configuration()
        configuration.pixelsPerInch = pixelsPerInch
        configuration.preferredThumbnailSize = preferredThumbnailSize
        configuration.preparesImagesForDisplay = preparesImagesForDisplay
        configuration.prefersHighDynamicRange = prefersHighDynamicRange
        self.init(configuration: configuration)
    }
}
#endif
