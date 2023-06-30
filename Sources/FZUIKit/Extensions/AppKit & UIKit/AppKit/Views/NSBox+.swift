//
//  NSBox+.swift
//  FZExtensions
//
//  Created by Florian Zand on 18.08.22.
//

#if os(macOS)

import AppKit
import Foundation

public extension NSBox {
    /**
     Returns a horizontal line with the specified width.
     - Parameters width: The width of the line.
     - Returns: A horizontal line.
     */
    static func horizontalLine(width: CGFloat) -> NSBox {
        let box = NSBox(frame: NSRect(origin: .zero, size: NSSize(width: width, height: 1)))
        box.boxType = .separator
        return box
    }

    /**
     Returns a vertical line with the specified height.
     - Parameters width: The height of the line.
     - Returns: A vertical line.
     */
    static func verticalLine(height: CGFloat) -> NSBox {
        let box = NSBox(frame: NSRect(origin: .zero, size: NSSize(width: 1, height: height)))
        box.boxType = .separator
        return box
    }
}

#endif
