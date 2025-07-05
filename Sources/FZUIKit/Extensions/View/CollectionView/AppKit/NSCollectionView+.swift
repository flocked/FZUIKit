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
            get { _contentOffset }
            set {
                NSView.swizzleAnimationForKey()
                _contentOffset = newValue
            }
        }
        
        @objc internal var _contentOffset: CGPoint {
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
        var documentSize: CGSize {
            get { _documentSize }
            set {
                NSView.swizzleAnimationForKey()
                _documentSize = newValue
            }
        }
        
        @objc internal var _documentSize: CGSize {
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
         A Boolean value indicating whether the selection of an item is toggled when the user clicks it.
         
         The default value is `false` where clicking an item selects it exclusively unless the `Command` key is held, in which case it toggles selection.
         */
        var togglesSelection: Bool {
            get { toggleSelectionGestureRecognizer != nil }
            set {
                guard newValue != togglesSelection else { return }
                if !newValue {
                    toggleSelectionGestureRecognizer?.removeFromView()
                    toggleSelectionGestureRecognizer = nil
                } else if toggleSelectionGestureRecognizer == nil {
                    toggleSelectionGestureRecognizer = .init()
                    addGestureRecognizer(toggleSelectionGestureRecognizer!)
                    doubleClickGesture?.moveToBack()
                }
            }
        }
        
        /**
         A Boolean value indicating whether items are selected while the user drags the mouse.
         
         The default value is `false`, which selects the items after the mouse drag finishes.
         */
        var selectsWhileDragging: Bool {
            get { dragSelectionGestureRecognizer != nil }
            set {
                guard newValue != selectsWhileDragging else { return }
                if !newValue {
                    dragSelectionGestureRecognizer?.removeFromView()
                    dragSelectionGestureRecognizer = nil
                } else if dragSelectionGestureRecognizer == nil {
                    dragSelectionGestureRecognizer = .init()
                    addGestureRecognizer(dragSelectionGestureRecognizer!)
                    doubleClickGesture?.moveToBack()
                }
            }
        }
        
        internal var toggleSelectionGestureRecognizer: ToggleSelectionGestureRecognizer? {
            get { getAssociatedValue("toggleSelectionGestureRecognizer") }
            set { setAssociatedValue(newValue, key: "toggleSelectionGestureRecognizer") }
        }
        
        internal var dragSelectionGestureRecognizer: DragSelectionGestureRecognizer? {
            get { getAssociatedValue("dragSelectionGestureRecognizer") }
            set { setAssociatedValue(newValue, key: "dragSelectionGestureRecognizer") }
        }
        
        internal class ToggleSelectionGestureRecognizer: NSGestureRecognizer {
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
                if let collectionView = view as? NSUICollectionView, collectionView.isSelectable, let indexPath = collectionView.indexPathForItem(at: event.location(in: collectionView)) {
                    if collectionView.selectionIndexPaths.contains(indexPath) {
                        collectionView.deselectItemsUsingDelegate(Set([indexPath]))
                    } else {
                        collectionView.selectItemsUsingDelegate(Set([indexPath]))
                    }
                    state = .ended
                } else {
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

        internal class DragSelectionGestureRecognizer: NSGestureRecognizer {
            var mouseDownLocation: CGPoint = .zero
            var selectionIndexPaths: Set<IndexPath> = []
            
            init() {
                super.init(target: nil, action: nil)
                reattachesAutomatically = true
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func mouseDown(with event: NSEvent) {
                guard let collectionView = view as? NSUICollectionView, collectionView.isSelectable, collectionView.allowsMultipleSelection, collectionView.allowsEmptySelection else { return }
                mouseDownLocation = event.location(in: collectionView)
                selectionIndexPaths = collectionView.selectionIndexPaths
            }
                
            override func mouseDragged(with event: NSEvent) {
                guard let collectionView = view as? NSUICollectionView, collectionView.isSelectable, collectionView.allowsMultipleSelection, collectionView.allowsEmptySelection else { return }
                let rect = CGRect(point1: mouseDownLocation, point2: event.location(in: collectionView))
                var indexPaths = Set(collectionView.displayingIndexPaths(in: rect))
                if event.modifierFlags.contains(.shift) {
                    indexPaths = selectionIndexPaths.filter({ !indexPaths.contains($0) }) + indexPaths.filter({!selectionIndexPaths.contains($0)})
                }
                let diff = collectionView.selectionIndexPaths.difference(to: indexPaths)
                if !diff.removed.isEmpty {
                    collectionView.deselectItemsUsingDelegate(Set(diff.removed))
                }
                if !diff.added.isEmpty {
                    collectionView.selectItemsUsingDelegate(Set(diff.added))
                }
            }
        }
        
        internal func selectItemsUsingDelegate(_ indexPaths: Set<IndexPath>) {
            var indexPaths = indexPaths
            if let shouldSelect = delegate?.collectionView(_:shouldSelectItemsAt:) {
                indexPaths = shouldSelect(self, indexPaths)
            }
            guard !indexPaths.isEmpty else { return }
            selectItems(at: indexPaths, scrollPosition: [])
            delegate?.collectionView?(self, didSelectItemsAt: indexPaths)
        }
        
        internal func deselectItemsUsingDelegate(_ indexPaths: Set<IndexPath>) {
            var indexPaths = indexPaths
            if let shouldDeselect = delegate?.collectionView(_:shouldDeselectItemsAt:) {
                indexPaths = shouldDeselect(self, indexPaths)
            }
            guard !indexPaths.isEmpty else { return }
            deselectItems(at: indexPaths)
            delegate?.collectionView?(self, didDeselectItemsAt: indexPaths)
        }
    }

extension NSCollectionView {
    /// The handler that gets called when the collection view is double clicked.
    public var doubleClickHandler: ((_ indexPath: IndexPath?)->())? {
        get { getAssociatedValue("doubleClickHandler") }
        set {
            setAssociatedValue(newValue, key: "doubleClickHandler")
            doubleClickGesture?.removeFromView()
            doubleClickGesture = nil
            if let newValue = newValue {
                doubleClickGesture = .init { [weak self] gesture in
                    guard let self = self else { return }
                    newValue(self.indexPathForItem(at: gesture.location(in: self)))
                }
                addGestureRecognizer(doubleClickGesture!)
            }
        }
    }
    
    @objc func didDoubleClick(_ gesture: NSClickGestureRecognizer) {
        doubleClickHandler?(indexPathForItem(at: gesture.location(in: self)))
    }
    
    var doubleClickGesture: DoubleClickGestureRecognizer? {
        get { getAssociatedValue("doubleClickGesture") }
        set { setAssociatedValue(newValue, key: "doubleClickGesture") }
    }
}

#endif
