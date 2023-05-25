//
//  File.swift
//
//
//  Created by Florian Zand on 05.05.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension CGImage {
    #if os(macOS)
        var nsImage: NSImage {
            return NSImage(cgImage: self)
        }

    #elseif canImport(UIKit)
        var uiImage: UIImage {
            return UIImage(cgImage: self)
        }
    #endif

    var size: CGSize {
        return CGSize(width: width, height: height)
    }
}
