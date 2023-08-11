//
//  NSCursor+.swift
//
//
//  Created by Florian Zand on 14.11.22.
//

#if os(macOS)
import AppKit
import Foundation

public extension NSCursor {
    /// Returns the resize-diagonal system cursor (from north-west to south-east).
    static var resizeDiagonal: NSCursor? {
        if let image = NSImage(byReferencingFile: "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors/resizenorthwestsoutheast/cursor.pdf") {
            return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        }
        
        // let path = Bundle.module.path(forResource: "northWestSouthEastResizeCursor", ofType: "png")!
        // let image = NSImage(byReferencingFile: path)!
        // return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        return nil
    }

    /// Returns the resize-diagonal-alernative system cursor (from north-east to south-west).
    static var resizeDiagonalAlt: NSCursor? {
        if let image = NSImage(byReferencingFile: "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors/resizenortheastsouthwest/cursor.pdf") {
            return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        }
        // le t path = Bundle.module.path(forResource: "northEastSouthWestResizeCursor", ofType: "png")!
        // let image = NSImage(byReferencingFile: path)!
        // return NSCursor(image: image, hotSpot: NSPoint(x: 8, y: 8))
        return nil
    }
}
#endif
