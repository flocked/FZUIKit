//
//  NSDraggingImageComponent+.swift
//
//
//  Created by Florian Zand on 11.02.24.
//

#if os(macOS)
import AppKit

extension NSDragOperation {
    /// A constant that indicates the drag cancelled.
    public static var none = NSDragOperation(rawValue: 0)
}

#endif
