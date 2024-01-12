//
//  NSCollectionLayoutBoundarySupplementaryItem+.swift
//
//
//  Created by Florian Zand on 08.09.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public extension NSCollectionLayoutBoundarySupplementaryItem {
        static func sectionHeader(height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = false) -> NSCollectionLayoutBoundarySupplementaryItem {
            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: height)
            let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSize, elementKind: NSUICollectionView.elementKindSectionHeader, alignment: .top)

            item.zIndex = .max
            item.pinToVisibleBounds = floating
            return item
        }

        static func sectionFooter(height: NSCollectionLayoutDimension = .estimated(44), floating: Bool = false) -> NSCollectionLayoutBoundarySupplementaryItem {
            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
            let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSize, elementKind: NSUICollectionView.elementKindSectionFooter, alignment: .bottom)

            item.zIndex = .max
            item.pinToVisibleBounds = floating
            return item
        }

        static func sectionBackground() -> NSCollectionLayoutBoundarySupplementaryItem {
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), elementKind: NSUICollectionView.ElementKind.sectionBackground, containerAnchor: .init(edges: .all))
        }

        static func itemBackground() -> NSCollectionLayoutBoundarySupplementaryItem {
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), elementKind: NSUICollectionView.ElementKind.itemBackground, containerAnchor: .init(edges: .all))
        }
    }

    public extension NSCollectionLayoutBoundarySupplementaryItem {
        static var bottomSeperatorLine: NSCollectionLayoutBoundarySupplementaryItem {
            seperatorLine(kind: .topLine)
        }

        static var topSeperatorLine: NSCollectionLayoutBoundarySupplementaryItem {
            seperatorLine(kind: .topLine)
        }

        internal static func seperatorLine(kind: SupplementaryKind) -> NSCollectionLayoutBoundarySupplementaryItem {
            let lineItemHeight: CGFloat = 1.0
            let lineItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(lineItemHeight))
            let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: kind.rawValue, alignment: kind.alignment)
            let supplementaryItemContentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            item.contentInsets = supplementaryItemContentInsets
            return item
        }

        internal enum SupplementaryKind: String {
            case topLine
            case bottomLine

            var alignment: NSRectAlignment {
                switch self {
                case .topLine: return .top
                case .bottomLine: return .bottom
                }
            }
        }

        enum ItemType {
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
#endif
