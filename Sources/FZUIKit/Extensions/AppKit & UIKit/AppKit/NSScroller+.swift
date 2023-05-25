//
//  File.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

#if os(macOS)
    import AppKit

    public extension NSScroller {
        var thickness: CGFloat {
            return Self.scrollerWidth(for: controlSize, scrollerStyle: scrollerStyle)
        }
    }
#endif
