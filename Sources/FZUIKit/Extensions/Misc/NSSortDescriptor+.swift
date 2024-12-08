//
//  NSSortDescriptor+.swift
//
//
//  Created by Florian Zand on 08.12.24.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSSortDescriptor {
    /// Returns the sort descriptor with reversed sorting order.
    public var reversed: Self {
        return reversedSortDescriptor as? Self ?? self
    }
}
#endif
