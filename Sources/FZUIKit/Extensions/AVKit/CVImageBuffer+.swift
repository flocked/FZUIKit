//
//  CVImageBuffer+.swift
//  
//
//  Created by Florian Zand on 31.08.24.
//


#if os(macOS) || os(iOS) || os(tvOS)
import AVFoundation
import CoreImage

extension CVImageBuffer {
    public var cgImage: CGImage {
        CIImage(cvPixelBuffer: self).cgImage
    }
}
#endif
