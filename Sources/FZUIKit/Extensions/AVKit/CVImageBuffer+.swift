//
//  CVImageBuffer+.swift
//  
//
//  Created by Florian Zand on 31.08.24.
//


#if os(macOS) || os(iOS) || os(tvOS)
import AVFoundation
import CoreImage
import FZSwiftUtils

extension CVImageBuffer {
    /// Creates a`CGImage` from the contents of the pixel buffer.
    public var cgImage: CGImage {
        ciImage.cgImage
    }
    
    /// Creates a`CIImage` from the contents of the pixel buffer.
    public var ciImage: CIImage {
        CIImage(cvPixelBuffer: self)
    }
}

extension CFType where Self == CGImage {
    /**
     Initializes an image object from the contents of a Core Video pixel buffer.
     
     - Parameter pixelBuffer: A `CVPixelBuffer` object.
     - Returns: The initialized image object.
     */
    public init(cvPixelBuffer pixelBuffer: CVImageBuffer) {
        self = pixelBuffer.cgImage
    }
}
#endif
