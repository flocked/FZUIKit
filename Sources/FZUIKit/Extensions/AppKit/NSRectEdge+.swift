//
//  NSRectEdge+.swift
//  
//
//  Created by Florian Zand on 15.12.23.
//

#if os(macOS)
import Foundation

extension NSRectEdge {
    /// The bottom edge of the rectangle.
    static var bottom: NSRectEdge {
        return .minY
    }
        
    /// The right edge of the rectangle.
    static var right: NSRectEdge {
        return .maxX
    }
    
    /// The top edge of the rectangle.
    static var top: NSRectEdge {
        return .maxY
    }
    
    /// The left edge of the rectangle.
    static var left: NSRectEdge {
        return .minX
    }
}

#endif
