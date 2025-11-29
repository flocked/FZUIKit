//
//  NSUIImage+ContourPath.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Vision

@available(macOS 11.0, iOS 14.0, tvOS 14.0, *)
extension NSUIImage {
    /**
     The contour path of the image.

     - Parameters:
        - size: The size for the contour path, or `nil` to use the image size.
        - contrastAdjustment: The amount by which to adjust the image contrast. Contour detection works best with high-contrast images. The default value of this property is `2.0`, which doubles the image contrast to achieve the most accurate results. This property supports a value range from `0.0` to `3.0`.
        - maximumImageDimension: Contour detection is computationally intensive. To improve performance, this property scales the input image down, while maintaining its aspect ratio, such that its maximum dimension is the value of this property.
     */
    public func contourPath(size: CGSize? = nil, contrastAdjustment: Float = 2, maximumImageDimension: Int? = nil) throws -> NSUIBezierPath {
        guard let cgImage = cgImage else { throw ContourError.noCGImage }
        return NSUIBezierPath(cgPath: try cgImage.contourPath(size: size, contrastAdjustment: contrastAdjustment, maximumImageDimension: maximumImageDimension))
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, *)
extension CGImage {
    /**
     The contour path of the image.

     - Parameters:
        - size: The size for the contour path, or `nil` to use the image size.
        - contrastAdjustment: The amount by which to adjust the image contrast. Contour detection works best with high-contrast images. The default value of this property is `2.0`, which doubles the image contrast to achieve the most accurate results. This property supports a value range from `0.0` to `3.0`.
        - maximumImageDimension: Contour detection is computationally intensive. To improve performance, this property scales the input image down, while maintaining its aspect ratio, such that its maximum dimension is the value of this property.
     */
    public func contourPath(size: CGSize? = nil, contrastAdjustment: Float = 2, maximumImageDimension: Int? = nil) throws -> CGPath {
        let size = size ?? CGSize(width: width, height: height)
        let contourRequest = VNDetectContoursRequest()
        contourRequest.maximumImageDimension = maximumImageDimension ?? Int(max(size.width, size.height))
        contourRequest.contrastAdjustment = contrastAdjustment
        let requestHandler = VNImageRequestHandler(cgImage: self, options: [:])
        try requestHandler.perform([contourRequest])
        var transform = CGAffineTransform(translationX: 0, y: CGFloat(size.height))
            .scaledBy(x: CGFloat(size.width), y: -CGFloat(size.height))
        guard let path = contourRequest.results?.first?.normalizedPath.mutableCopy(using: &transform) else {
            throw ContourError.noContour
        }
        return path
    }
}

enum ContourError: LocalizedError {
    case noContour
    case noCGImage

    var errorDescription: String? {
        switch self {
        case .noContour: return "No contour detected."
        case .noCGImage: return "Unable to create CGImage representation of image."
        }
    }
}

#endif
