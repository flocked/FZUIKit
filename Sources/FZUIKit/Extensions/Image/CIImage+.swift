//
//  CIImage+.swift
//
//
//  Created by Florian Zand on 31.08.24.
//

import CoreImage
#if os(macOS)
import AppKit
extension CIImage {
    public var nsImage: NSImage {
        cgImage.nsImage
    }
}
#elseif canImport(UIKit)
import UIKit
extension CIImage {
    public var uiImage: UIImage {
        cgImage.uiImage
    }
}
#endif

extension CIImage {
    public var cgImage: CGImage {
        CIContext(options: nil).createCGImage(self, from: self.extent)!
    }
    
    var nsUIImage: NSUIImage {
        cgImage.nsUIImage
    }
}
