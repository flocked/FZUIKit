//
//  NSScroller+.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

#if os(macOS)
import AppKit

public extension NSScroller {
    /// The thickness of the scroller.
    var thickness: CGFloat {
        Self.scrollerWidth(for: controlSize, scrollerStyle: scrollerStyle)
    }
}
#endif
