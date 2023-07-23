//
//  CompositionalLayout+.swift
//  
//
//  Created by Florian Zand on 07.06.22.
//

import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUICollectionViewCompositionalLayout {
    enum SupplementaryKind: String {
        case topLine
        case bottomLine

        internal var alignment: NSRectAlignment {
            switch self {
            case .topLine: return .top
            case .bottomLine: return .bottom
            }
        }
    }

    static func seperatorLine(kind: SupplementaryKind) -> NSCollectionLayoutBoundarySupplementaryItem {
        let lineItemHeight: CGFloat = 1.0
        let lineItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(lineItemHeight))
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: kind.rawValue, alignment: kind.alignment)
        let supplementaryItemContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        item.contentInsets = supplementaryItemContentInsets
        return item
    }

    enum SupplementaryItemType {
        case normal(height: CGFloat)
        case pinToTop(height: CGFloat)

        fileprivate var pinToVisibleBounds: Bool {
            switch self {
            case .normal: return false
            case .pinToTop: return true
            }
        }

        fileprivate var height: CGFloat {
            switch self {
            case let .normal(height): return height
            case let .pinToTop(height): return height
            }
        }

        func item(elementKind: String) -> NSCollectionLayoutBoundarySupplementaryItem {
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(height))
            let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize, elementKind: elementKind, alignment: .top)
            item.pinToVisibleBounds = pinToVisibleBounds
            return item
        }
    }
}
