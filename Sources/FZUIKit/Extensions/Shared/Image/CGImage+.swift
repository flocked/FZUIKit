//
//  CGImage+.swift
//
//
//  Created by Florian Zand on 05.05.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import SwiftUI

public extension CGImage {
    #if os(macOS)
    /// A `NSImage` representation of the image.
    var nsImage: NSImage {
        return NSImage(cgImage: self)
    }

    #elseif canImport(UIKit)
    /// A `UIImage` representation of the image.
    var uiImage: UIImage {
        return UIImage(cgImage: self)
    }
    #endif
    
    /// A `Image` representation of the image.
    var swiftUI: Image {
    #if os(macOS)
        return Image(nsImage)
    #elseif canImport(UIKit)
        return Image(uiImage: uiImage)
    #endif
    }

    /// The size of the image.
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    internal var nsUIImage: NSUIImage {
        return UIImage(cgImage: self)
    }
}
