//
//  NSUICollectionViewDiffableDataSource+.swift
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

extension NSUICollectionViewDiffableDataSource {
    /// Returns an empty snapshot.
    public func emptySnapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        .init()
    }
}

#endif
