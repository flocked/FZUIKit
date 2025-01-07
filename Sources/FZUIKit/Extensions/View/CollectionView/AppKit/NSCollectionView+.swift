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
        /// Creates a collection view with an enclosing scroll view.
        static func scrolling() -> NSCollectionView {
            let collectionView = NSCollectionView()
            collectionView.addEnclosingScrollView()
            return collectionView
        }
        
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
         - Returns: The item at the specified location or `nil` if no item is available.
         */
        func item(at location: CGPoint) -> NSCollectionViewItem? {
            guard let indexPath = indexPathForItem(at: location) else { return nil }
            return item(at: indexPath)
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
            setCollectionViewLayout(layout, animationDuration: animated ? 0.25 : 0.0, completion: completion)
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
         Selects the specified items and optionally scrolls the items into position.
         
         - Parameters:
            - indexPaths: The index paths of the items to select.
            - extend: `true` if the selection should be extended, `false` if the current selection should be changed.
            - scrollPosition: The options for scrolling the newly selected items into view.
         */
        func selectItems(at indexPaths: Set<IndexPath>, byExtendingSelection extend: Bool, scrollPosition: ScrollPosition = []) {
            let deselect = extend ? Set([]) : selectionIndexPaths.filter({ !indexPaths.contains($0) })
            selectItems(at: indexPaths, scrollPosition: scrollPosition)
            deselectItems(at: deselect)
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
            return SavedScrollPosition(indexPaths: indexPaths, position: contentOffset.y <= 0.0 && indexPaths.contains(IndexPath(item: 0, section: 0)) ? .nearestHorizontalEdge : frame.height >= superview?.frame.height ?? frame.height ? .centeredVertically : .centeredHorizontally)
        }

        /**
         Restores the specified saved scroll position.
         
         To save a scroll position, use ``saveScrollPosition()``.

         - Parameter scrollPosition: The scroll position to restore.
         */
        func restoreScrollPosition(_ scrollPosition: SavedScrollPosition) {
            scrollToItems(at: .init(scrollPosition.indexPaths), scrollPosition: scrollPosition.position == .nearestHorizontalEdge ?  .nearestHorizontalEdge : (frame.height >= superview?.frame.height ?? frame.height) ? .centeredVertically : .centeredHorizontally)
        }
        
        /**
         The index paths for a right event.
         
         - Parameter event: The right click event.
         
         The returned set contains:
         - if right-click on a **selected item**, all selected index paths,
         - else if right-click on a **non-selected item**, that index path,
         - else an empty set.
         */
        func rightClickIndexPaths(for event: NSEvent) -> Set<IndexPath> {
            rightClickIndexPaths(for: event.location(in: self))
        }
        
        /**
         The index paths for a point in the collection view.
         
         - Parameter location: The point in the collection view’s bound.
         
         The returned set contains:
         - if right-click on a **selected item**, all selected index paths,
         - else if right-click on a **non-selected item**, that index path,
         - else an empty set.
         */
        func rightClickIndexPaths(for point: CGPoint) -> Set<IndexPath> {
            if let indexPath = indexPathForItem(at: point) {
                let selectionIndexPaths = selectionIndexPaths
                return selectionIndexPaths.contains(indexPath) ? selectionIndexPaths : [indexPath]
            }
            return []
        }
        
        /**
         Scrolls the collection view contents until the specified items are visible.
         
         - Parameters:
            - indexPaths: The index paths of the items. The layout attributes of these items define the bounding box that needs to be scrolled onscreen.
            - scrollPosition: The options for scrolling the bounding box of the specified items into view. Specifying more than one option for either the vertical or horizontal directions raises an exception.
            - animated: Specify `true` to animate the scrolling behavior or `false` to adjust the scroll view’s visible content immediately.
         */
        func scrollToItems(at indexPaths: Set<IndexPath>, scrollPosition: ScrollPosition,  animated: Bool) {
            if animated {
                scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
            } else {
                NSAnimationContext.runAnimationGroup({ context in
                    self.animator().scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
                })
            }
        }
        
        /**
         A Boolean value indicating whether the selection of items is toggled when the user clicks an item.
         
         The default value is `false`.
         */
        var shouldToggleSelectionOnClick: Bool {
            get { getAssociatedValue("shouldToggleSelectionOnClick") ?? false }
            set {
                guard newValue != shouldToggleSelectionOnClick else { return }
                setAssociatedValue(newValue, key: "shouldToggleSelectionOnClick")
                setupToggleGestureRecognizer()
            }
        }
        
        /**
         A Boolean value indicating whether all items should be deselected when the user clicks on the backgrouhd of the collection view.
         
         The default value is `true`.
         */
        var shouldDeselectItemsOnEmptyClick: Bool {
            get { getAssociatedValue("shouldDeselectItemsOnEmptyClick") ?? true }
            set {
                guard newValue != shouldDeselectItemsOnEmptyClick else { return }
                setAssociatedValue(newValue, key: "shouldDeselectItemsOnEmptyClick")
                setupToggleGestureRecognizer()
            }
        }
        
        internal func setupToggleGestureRecognizer() {
            if !shouldToggleSelectionOnClick && shouldDeselectItemsOnEmptyClick {
                selectionGestureRecognizer?.removeFromView()
                selectionGestureRecognizer = nil
            } else if selectionGestureRecognizer == nil {
                selectionGestureRecognizer = SelectionGestureRecognizer()
                addGestureRecognizer(selectionGestureRecognizer!)
            }
        }
        
        internal var selectionGestureRecognizer: SelectionGestureRecognizer? {
            get { getAssociatedValue("selectionGestureRecognizer") }
            set { setAssociatedValue(newValue, key: "selectionGestureRecognizer") }
        }
        
        internal class SelectionGestureRecognizer: NSGestureRecognizer {
            init() {
                super.init(target: nil, action: nil)
                delaysPrimaryMouseButtonEvents = true
                reattachesAutomatically = true
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func mouseDown(with event: NSEvent) {
                state = .began
                var shouldFail = true
                if let collectionView = view as? NSUICollectionView, collectionView.isSelectable, collectionView.allowsEmptySelection, collectionView.shouldToggleSelectionOnClick || !collectionView.shouldDeselecttemsOnEmptyClick {
                    let indexPath = collectionView.indexPathForItem(at: event.location(in: collectionView))
                    if collectionView.shouldToggleSelectionOnClick, let indexPath = indexPath {
                        if collectionView.selectionIndexPaths.contains(indexPath) {
                            collectionView.deselectItems(at: [indexPath])
                            collectionView.delegate?.collectionView?(collectionView, didDeselectItemsAt: [indexPath])
                        } else {
                            collectionView.selectItems(at: [indexPath], scrollPosition: [])
                            collectionView.delegate?.collectionView?(collectionView, didSelectItemsAt: [indexPath])
                        }
                        shouldFail = false
                    } else if !collectionView.shouldDeselecttemsOnEmptyClick, indexPath == nil {
                        shouldFail = false
                    }
                }
                if shouldFail {
                    state = .failed
                }
            }
            
            override func mouseUp(with event: NSEvent) {
                state = .began
                state = .failed
            }
                        
            override func mouseDragged(with event: NSEvent) {
                state = .began
                state = .failed
            }
        }
    }

#endif
