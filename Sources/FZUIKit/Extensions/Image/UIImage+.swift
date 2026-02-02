//
//  UIImage+.swift
//
//
//  Created by Florian Zand on 29.06.25.
//


#if canImport(UIKit)
import UIKit

extension UIImage {
    /**
     Returns an image with the specified flipped (mirrored) state.

     If the image already matches the desired flipped state, it is returned as-is, otherwise, a new flipped image is returned.

     - Parameter shouldFlip: A Boolean value indicating whether the returned image should be flipped.
     - Returns: The original image if it already matches `is`, or a new mirrored/unmirrored image otherwise.
     */
    public func withFlipped(_ shouldFlip: Bool) -> UIImage {
        guard imageOrientation.isMirrored != shouldFlip, let cgImage = cgImage else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation.flipped)
    }
}

extension UIImage.Orientation {
    /// A Boolean value indicating whether the image orientation is mirrored.
    public var isMirrored: Bool {
        switch self {
        case .upMirrored, .downMirrored, .leftMirrored, .rightMirrored: return true
        default: return false
        }
    }
    
    /// The flipped image orientation.
    public var flipped: Self {
        switch self {
        case .up: return .upMirrored
        case .upMirrored: return .up
        case .down: return .downMirrored
        case .downMirrored: return .down
        case .left: return .leftMirrored
        case .leftMirrored: return .left
        case .right: return .rightMirrored
        case .rightMirrored: return .right
        @unknown default: return .up
        }
    }
}

#endif
