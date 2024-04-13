//
//  NSCollectionView+.swift
//
//
//  Created by Florian Zand on 06.06.22.
//

#if os(macOS)

    import AppKit
    import Foundation
    import FZSwiftUtils

    public extension NSCollectionView {
        /**
         The frame of the item at the specified index path.
         - Parameter indexPath: The index path of the item.
         - Returns: The frame of the item or `nil` if no item exists at the specified path.
         */
        func frameForItem(at indexPath: IndexPath) -> CGRect? {
            layoutAttributesForItem(at: indexPath)?.frame
        }

        /**
         The item item at the specified location.
         - Parameter location: The location of the item.
         - Returns: The item or `nil` if no item exists at the specified location.
         */
        func item(at location: CGPoint) -> NSCollectionViewItem? {
            if let indexPath = indexPathForItem(at: location) {
                return item(at: indexPath)
            }
            return nil
        }

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
        
        internal var indexPaths: [IndexPath] {
            (0..<numberOfSections).flatMap({indexPaths(for: $0)})
        }
        
        internal var itemFrames: [CGRect] {
            indexPaths.compactMap({frameForItem(at: $0)})
        }
        
        /**
         The index paths in the specified rectangle.
         
         - Parameter rect: The rectangle.
         */
        func indexPaths(in rect: CGRect) -> [IndexPath] {
            var itemI = indexPaths.compactMap({($0, frameForItem(at: $0)) })
            itemI = itemI.filter({$0.1?.intersects(rect) == true})
            return itemI.compactMap({$0.0})
        }

        /// Scrolls the collection view to the top.
        func scrollToTop(animationDuration: TimeInterval? = nil) {
            enclosingScrollView?.scrollToTop(animationDuration: animationDuration)
        }

        /// Scrolls the collection view to the bottom.
        func scrollToBottom(animationDuration: TimeInterval? = nil) {
            enclosingScrollView?.scrollToBottom(animationDuration: animationDuration)
        }
        
        /// Scrolls the collection view to the left.
        func scrollToLeft(animationDuration: TimeInterval? = nil) {
            enclosingScrollView?.scrollToLeft(animationDuration: animationDuration)
        }
        
        /// Scrolls the collection view to the right.
        func scrollToRight(animationDuration: TimeInterval? = nil) {
            enclosingScrollView?.scrollToRight(animationDuration: animationDuration)
        }
        
        /**
         Changes the collection view layout.
         
         - Parameters:
            - layout: The new layout object for the collection view.
            - animated: A Boolean value indicating whether the collection view should animate changes from the current layout to the new layout.
            - completion: The completion handler that gets called when the layout transition finishes
         */
        func setCollectionViewLayout(_ layout: NSCollectionViewLayout, animated: Bool, completion: (() -> Void)? = nil) {
            setCollectionViewLayout(layout, animationDuration: animated ? 0.2 : 0.0, completion: completion)
        }

        /**
         Changes the collection view layout animated.
         
         - Parameters:
            - layout: The new layout object for the collection view.
            - animationDuration: The duration for the collection view animating changes from the current layout to the new layout. Specify a value of `0.0` to make the change without animations.
            - completion: The completion handler that gets called when the layout transition finishes
         */
        func setCollectionViewLayout(_ layout: NSCollectionViewLayout, animationDuration: CGFloat, completion: (() -> Void)? = nil) {
            if animationDuration > 0.0 {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = animationDuration
                    self.animator().collectionViewLayout = layout
                }, completionHandler: { completion?() })
            } else {
                collectionViewLayout = layout
                completion?()
            }
        }

        /**
         The point at which the origin of the document view is offset from the origin of the scroll view.

         The value can be animated via `animator()`.
         */
        @objc var contentOffset: CGPoint {
            get { enclosingScrollView?.contentOffset ?? .zero }
            set { enclosingScrollView?.contentOffset = newValue }
        }
        
        /**
         The fractional content offset on a range between `0.0` and `1.0`.
         
         - A value of `CGPoint(x:0, y:0)` indicates the document view is at the bottom left.
         - A value of `CGPoint(x:1, y:1)` indicates the document view is at the top right.

         The value can be animated via `animator()`.
         */
        @objc var contentOffsetFractional: CGPoint {
            get { enclosingScrollView?.contentOffsetFractional ?? .zero }
            set { enclosingScrollView?.contentOffsetFractional = newValue }
        }

        /**
         The size of the document view, or `nil` if there isn't a document view.

         The value can be animated via `animator()`.
         */
        @objc var documentSize: CGSize {
            get { enclosingScrollView?.documentSize ?? .zero }
            set { enclosingScrollView?.documentSize = newValue }
        }
        
        var visibleDocumentSize: CGSize {
            get { enclosingScrollView?.visibleDocumentSize ?? .zero }
            set { enclosingScrollView?.visibleDocumentSize = newValue }
        }
        
        /// A saved scroll position.
        struct SavedScrollPosition {
            let indexPaths: [IndexPath]
            let position: ScrollPosition
        }

        /**
         Returns a value representing the current scroll position.
         
         To restore the saved scroll position, use ``restoreScrollPosition(_:)``.
         
         - Returns: The saved scroll position.
         */
        func saveScrollPosition() -> SavedScrollPosition {
            let indexPaths = displayingIndexPaths()
            if contentOffset.y <= 0.0, indexPaths.contains(IndexPath(item: 0, section: 0)) {
                return SavedScrollPosition(indexPaths: indexPaths, position: .nearestHorizontalEdge)
            }
            return SavedScrollPosition(indexPaths: indexPaths, position: (frame.height >= superview?.frame.height ?? frame.height) ? .centeredVertically : .centeredHorizontally)
        }

        /**
         Restores the specified saved scroll position.
         
         To save a scroll position, use ``saveScrollPosition()``.

         - Parameter scrollPosition: The scroll position to restore.
         */
        func restoreScrollPosition(_ scrollPosition: SavedScrollPosition) {
            if scrollPosition.position == .nearestHorizontalEdge {
                scrollToItems(at: .init(scrollPosition.indexPaths), scrollPosition: .nearestHorizontalEdge)
            } else {
                scrollToItems(at: .init(scrollPosition.indexPaths), scrollPosition: (frame.height >= superview?.frame.height ?? frame.height) ? .centeredVertically : .centeredHorizontally)
            }
        }
    }

#endif
