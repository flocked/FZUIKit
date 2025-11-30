//
//  CIImage+.swift
//
//
//  Created by Florian Zand on 31.08.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
extension CIImage {
    /// A `NSImage` representation of the image.
    public var nsImage: NSImage {
        cgImage.nsImage
    }
}
#elseif canImport(UIKit)
import UIKit
extension CIImage {
    /// An `UIImage` representation of the image.
    public var uiImage: UIImage {
        cgImage.uiImage
    }
}
#endif

extension CIImage {
    /// A `CGImage` representation of the image.
    public var cgImage: CGImage {
        CIContext(options: nil).createCGImage(self, from: extent)!
    }
}

#endif
