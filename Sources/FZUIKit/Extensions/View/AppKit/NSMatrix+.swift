//
//  NSMatrix+.swift
//
//
//  Created by Florian Zand on 01.07.24.
//

#if os(macOS)
import AppKit

extension NSMatrix {
    /// Sets the Boolean value that indicates whether the matrix draws its background.
    @discardableResult
    public func drawsBackground(_ draws: Bool) -> Self {
        drawsBackground = draws
        return self
    }
    
    /// Sets the background color of the matrix.
    @discardableResult
    public func backgroundColor(_ color: NSColor?) -> Self {
        backgroundColor = color ?? .clear
        drawsBackground = color != nil
        return self
    }
}
#endif
