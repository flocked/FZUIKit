//
//  NSVisualEffectView+.swift
//
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSVisualEffectView {
        /**
         Applies a mask image with the specified corner radius.

         - Parameters: The corner radius to apply.
         */
        func roundCorners(withRadius cornerRadius: CGFloat) {
            maskImage = (cornerRadius != 0.0) ? .maskImage(cornerRadius: cornerRadius) : nil
        }
    }

#endif
