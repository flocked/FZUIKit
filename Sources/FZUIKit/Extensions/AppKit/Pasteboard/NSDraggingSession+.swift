//
//  NSDraggingSession+.swift
//
//
//  Created by Florian Zand on 01.02.25.
//

#if os(macOS)
import AppKit

extension NSDraggingSession {
    /// The source of the drag.
    public var draggingSource: NSDraggingSource {
        value(forKey: "_source") as! NSDraggingSource
    }
}
#endif
