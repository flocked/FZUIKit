//
//  NSDraggingInfo+.swift
//
//
//  Created by Florian Zand on 25.01.25.
//

#if os(macOS)
import AppKit

public extension NSDraggingInfo {
    /**
     The current location of the mouse pointer in the specified view.
     
     - Parameter view: The view for the location.
     */
    func location(in view: NSView) -> CGPoint {
        view.convert(draggingLocation, from: nil)
    }
}

#endif
