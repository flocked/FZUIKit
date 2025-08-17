//
//  NSUITableViewDiffableDataSource+.swift
//
//
//  Created by Florian Zand on 09.11.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(macOS 11.0, iOS 13.0, tvOS 13.0, *)
extension NSUITableViewDiffableDataSource {
    /// Returns an empty snapshot.
    public func emptySnapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        .init()
    }
}

#endif
