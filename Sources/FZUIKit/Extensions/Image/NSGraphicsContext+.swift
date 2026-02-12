//
//  NSGraphicsContext+.swift
//
//
//  Created by Florian Zand on 12.02.26.
//

#if os(macOS)
import AppKit

extension NSGraphicsContext {
    /// Executes the specified block while preserving graphics state.
    public func withSavedGState(_ block: ()->()) {
        saveGraphicsState()
        block()
        restoreGraphicsState()
    }
}
#endif
