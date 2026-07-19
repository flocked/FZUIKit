//
//  UIImage+.swift
//
//
//  Created by Florian Zand on 29.06.25.
//

#if canImport(UIKit)
import UIKit

public extension UIImage {
    /// Returns the image with the specified scale factor.
    func scale(_ scale: CGFloat) -> UIImage {
        guard self.scale != scale, let cgImage = cgImage else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
    
    /// Returns the image with the specified image orientation.
    func orientation(_ orientation: Orientation) -> UIImage {
        guard imageOrientation != orientation, let cgImage = cgImage else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
}
#endif
