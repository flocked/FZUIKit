//
//  NSView+Extensions.swift
//  SelectableArray
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSVisualEffectView {
        func roundCorners(withRadius cornerRadius: CGFloat) {
            maskImage = .maskImage(cornerRadius: cornerRadius)
        }
    }

#endif
