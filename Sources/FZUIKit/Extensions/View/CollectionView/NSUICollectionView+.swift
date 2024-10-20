//
//  NSUICollectionView+.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

#if os(macOS)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif
import FZSwiftUtils

#if os(macOS) || os(iOS) || os(tvOS)
    public extension NSUICollectionView {
        internal var indexPaths: [IndexPath] {
            (0..<numberOfSections).flatMap({indexPaths(for: $0)})
        }
        
        /// Returns the index paths of the currently displayed items. Unlike `indexPathsForVisibleItems()`  it only returns the items with visible frame.
        func displayingIndexPaths(in rect: CGRect) -> [IndexPath] {
            return (displayingItems(in: rect).compactMap { self.indexPath(for: $0) }).sorted()
        }
        
        #if os(macOS)
        /// Returns an array of all displayed items. Unlike `visibleItems()` it only returns the items with visible frame.
        func displayingItems(in rect: CGRect) -> [NSUICollectionViewItem] {
            visibleItems().filter { $0.view.frame.intersects(rect) }
        }
        #else
        /// Returns an array of all displayed items. Unlike `visibleItems()` it only returns the items with visible frame.
        func displayingItems(in rect: CGRect) -> [UICollectionViewCell] {
            visibleCells.filter { $0.frame.intersects(rect) }
        }
        #endif
        
        /**
         The item index paths for the specified section.
         - Parameter section: The section of the items.
         - Returns: The item index paths.
         */
        func indexPaths(for section: Int) -> [IndexPath] {
            var indexPaths = [IndexPath]()
            if numberOfSections > section {
                let numberOfItems = numberOfItems(inSection: section)
                for item in 0 ..< numberOfItems {
                    indexPaths.append(IndexPath(item: item, section: section))
                }
            }
            return indexPaths
        }
        
        #if os(iOS) || os(tvOS)
        /**
         Selects items at the specified index paths, with an option to animate the selection.
         
         - Parameters:
            - indexPaths: The index paths of the items.
            - animated: `true` if you want to animate the selection, and `false` if the change should be immediate.
            - scrollPosition: A constant that identifies a relative position in the collection view (top, middle, bottom) for the items when scrolling concludes.
         */
        func selectItems<C: Sequence<IndexPath>>(at indexPaths: C, animated: Bool = false, scrollPosition: ScrollPosition) {
            indexPaths.forEach({ selectItem(at: $0, animated: animated, scrollPosition: scrollPosition) })
        }
        
        /**
         Deselects items at the specified index paths, with an option to animate the deselection.
         
         - Parameters:
            - indexPaths: The index paths of the rows.
            - animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
         */
        func deselectItems<C: Sequence<IndexPath>>(at indexPaths: C, animated: Bool = false) {
            indexPaths.forEach({ deselectItem(at: $0, animated: animated) })
        }
        
        /**
         Selects all items.
         
         - Parameters:
            - animated: `true` if you want to animate the selection, and `false` if the change should be immediate.
            - scrollPosition: An option that specifies where the items should be positioned when scrolling finishes.
         */
        func selectAll(animated: Bool = false, scrollPosition: ScrollPosition) {
            selectItems(at: indexPaths, animated: animated, scrollPosition: scrollPosition)
        }
        
        /**
         Deselects all items.
         
         - Parameter animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
         */
        func deselectAll(animated: Bool = false) {
            deselectItems(at: indexPathsForSelectedItems ?? [], animated: animated)
        }
        
        /**
         Returns the collection cell at the specified point.
         
         - Parameter point: A point in the local coordinate system of the collection view (the collection view’s bounds).
         - Returns: The cell object at the corresponding point. In versions of iOS earlier than iOS 15, this method returns `nil` if the cell isn’t visible. In iOS 15 and later, this method returns a non-`nil` cell if the collection view retains a prepared cell at the specified location, even if the cell isn’t currently visible.
         */
        func cell(at point: CGPoint) -> UICollectionViewCell? {
            guard let indexPath = indexPathForItem(at: point) else { return nil }
            return cellForItem(at: indexPath)
        }
        #endif
        
        /**
         Selects the item after the currently selected items.
         
         If no items are currently selected, the first item is selected.
         
         - Parameters:
            - extend: A Boolean value that indicates whether the selection should be extended.
            - scrollPosition: The options for scrolling the newly selected items into view. You may combine one vertical and one horizontal scrolling option when calling this method. Specifying more than one option for either the vertical or horizontal directions raises an exception.
         */
        func selectNextItem(byExtendingSelection extend: Bool = false, scrollPosition: ScrollPosition) {
            #if os(macOS)
            guard isSelectable else { return }
            #else
            let selectionIndexPaths = (indexPathsForSelectedItems ?? [])
            #endif
            let allIndexPaths = indexPaths
            var nextIndexPath: IndexPath? = nil
            if let indexPath = selectionIndexPaths.sorted().last, let index = allIndexPaths.firstIndex(of: indexPath), let next = allIndexPaths[safe: index + 1] {
                nextIndexPath = next
            } else if selectionIndexPaths.isEmpty, let next = allIndexPaths.first {
                nextIndexPath = next
            }
            guard let nextIndexPath = nextIndexPath else { return }
            var indexPaths: Set<IndexPath> = [nextIndexPath]
            if extend {
                indexPaths += selectionIndexPaths
            }
            selectItems(at: indexPaths, scrollPosition: scrollPosition)
        }
        
        /**
         Selects the item before the currently selected items.
         
         If no items are currently selected, the last item is selected.
         
         - Parameters:
            - extend: A Boolean value that indicates whether the selection should be extended.
            - scrollPosition: The options for scrolling the newly selected items into view. You may combine one vertical and one horizontal scrolling option when calling this method. Specifying more than one option for either the vertical or horizontal directions raises an exception.
         */
        func selectPreviousItem(byExtendingSelection extend: Bool = false, scrollPosition: ScrollPosition) {
            #if os(macOS)
            guard isSelectable else { return }
            #else
            let selectionIndexPaths = (indexPathsForSelectedItems ?? [])
            #endif
            let allIndexPaths = indexPaths
            var previousIndexPath: IndexPath? = nil
            if let indexPath = selectionIndexPaths.sorted().first, let index = allIndexPaths.firstIndex(of: indexPath), let previous = allIndexPaths[safe: index - 1] {
                previousIndexPath = previous
            } else if selectionIndexPaths.isEmpty, let previous = allIndexPaths.last {
                previousIndexPath = previous
            }
            guard let previousIndexPath = previousIndexPath else { return }
            var indexPaths: Set<IndexPath> = [previousIndexPath]
            if extend {
                indexPaths += selectionIndexPaths
            }
            selectItems(at: indexPaths, scrollPosition: scrollPosition)
        }
        
        /// Supplementary view kinds.
        enum ElementKind {
            /// A supplementary view that acts as a top seperator for a given item.
            public static let itemTopSeperator: String = "ElementKindItemTopSeperator"
            /// A supplementary view that acts as a bottom seperator for a given item.
            public static let itemBottomSeperator: String = "ElementKindBottomSeperator"
            /// A supplementary view that acts as a background for a given item.
            public static let itemBackground: String = "ElementKindItemBackground"
            /// A supplementary view that acts as a background for a given group.
            public static let groupBackground: String = "ElementKindGroumBackground"
            /// A supplementary view that acts as a background for a given section.
            public static let sectionBackground: String = "ElementKindSectionBackground"
            /// A supplementary view that acts as a header for a given section.
            public static var sectionHeader: String {
                NSUICollectionView.elementKindSectionHeader
            }

            /// A supplementary view that acts as a footer for a given section.
            public static var sectionFooter: String {
                NSUICollectionView.elementKindSectionFooter
            }
        }
    }
#endif
