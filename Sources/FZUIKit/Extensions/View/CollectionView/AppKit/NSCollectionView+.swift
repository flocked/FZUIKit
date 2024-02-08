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
        func scrollToTop() {
            enclosingScrollView?.scrollToBeginningOfDocument(nil)
        }

        /// Scrolls the collection view to the bottom.
        func scrollToBottom() {
            enclosingScrollView?.scrollToEndOfDocument(nil)
        }

        /**
         Changes the collection view layout animated.
         - Parameters:
            - layout: The new collection view layout.
            - animationDuration: The animation duration.
            - completion: The completion handler that gets called when the animation is completed.
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

         The default value is `zero`. The value can be animated via `animator()`.
         */
        @objc var contentOffset: CGPoint {
            get { enclosingScrollView?.contentOffset ?? .zero }
            set {
                NSView.swizzleAnimationForKey()
                enclosingScrollView?.contentOffset = newValue
            }
        }

        /**
         The size of the document view, or `nil` if there isn't a document view.

         The value can be animated via `animator()`.
         */
        @objc var documentSize: CGSize {
            get { enclosingScrollView?.documentView?.frame.size ?? NSSize.zero }
            set {
                NSView.swizzleAnimationForKey()
                enclosingScrollView?.documentView?.setFrameSize(newValue)
            }
        }
    }

    public extension NSCollectionView {
        /// A saved scroll position.
        struct SavedScrollPosition {
            let displayingIndexPaths: [IndexPath]
        }

        /// Saves the current scroll position.
        func saveScrollPosition() -> SavedScrollPosition {
            SavedScrollPosition(displayingIndexPaths: displayingIndexPaths())
        }

        /**
         Restores the specified saved scroll position.

         - Parameter scrollPosition: The scroll position to restore.
         */
        func restoreScrollPosition(_ scrollPosition: SavedScrollPosition) {
            scrollToItems(at: .init(scrollPosition.displayingIndexPaths), scrollPosition: [])
        }
    }

#endif
