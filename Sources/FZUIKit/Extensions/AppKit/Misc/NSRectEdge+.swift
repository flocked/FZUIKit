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
            .minY
        }

        /// The right edge of the rectangle.
        static var right: NSRectEdge {
            .maxX
        }

        /// The top edge of the rectangle.
        static var top: NSRectEdge {
            .maxY
        }

        /// The left edge of the rectangle.
        static var left: NSRectEdge {
            .minX
        }
    }

#endif
