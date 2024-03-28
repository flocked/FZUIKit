//
//  UICollectionView+.swift
//
//
//  Created by Florian Zand on 26.11.23.
//

#if os(iOS) || os(tvOS)
    import FZSwiftUtils
    import UIKit

    extension UICollectionView {
        /// Returns the index paths of the currently displayed cells. Unlike `indexPathsForVisibleItems()`  it only returns the cells with visible frame.
        public func displayingIndexPaths() -> [IndexPath] {
            (displayingCells().compactMap { self.indexPath(for: $0) }).sorted()
        }

        /// Returns an array of all displayed cells. Unlike `visibleCells()` it only returns the items with visible frame.
        public func displayingCells() -> [UICollectionViewCell] {
            let visibleCells = visibleCells
            let visibleRect = frame.intersection(superview?.bounds ?? frame)
            return visibleCells.filter { $0.frame.intersects(visibleRect) }
        }
        
        var centerIndexPath: IndexPath? {
            let centerPoint = frame.intersection(superview?.bounds ?? frame).center
            if let cell = visibleCells.first(where: { $0.frame.contains(centerPoint) }) {
                return indexPath(for: cell)
            }
            let displayingIndexPath = displayingIndexPaths()
            guard !displayingIndexPath.isEmpty else { return nil }
            let index = Int((Double(displayingIndexPath.count) / 2.0).rounded(.toPlaces(0)))
            return displayingIndexPath[safe: index]
        }
        
        func scrollToItems(at indexPaths: Set<IndexPath>, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool = false) {
            let indexPaths = indexPaths.compactMap({ if let frame = layoutAttributesForItem(at: $0)?.frame { return (indexPath: $0, frame: frame) } else { return nil }})
            guard !indexPaths.isEmpty else { return }
            let frames = indexPaths.compactMap({$0.frame})
            if let index = frames.indexOfCenteredRect(), let indexPath = indexPaths[safe: index]?.indexPath {
                scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
            } else {
                scrollRectToVisible(frames.union(), animated: animated)
            }
        }

        /**
         The handlers for the displaying cells.

         The handlers get called whenever the collection view is displaying new cells (e.g. when the enclosing scrollview gets scrolled to new cells).
         */
        public var displayingCellsHandlers: DisplayingItemsHandlers {
            get { getAssociatedValue("displayingItemsHandlers", initialValue: DisplayingItemsHandlers()) }
            set {
                setAssociatedValue(newValue, key: "displayingItemsHandlers")
                setupDisplayingItemsTracking()
            }
        }

        /**
         Handlers for the displaying cells.

         The handlers get called whenever the collection view is displaying new cells.
         */
        public struct DisplayingItemsHandlers {
            /// Handler that gets called whenever cells start getting displayed.
            var isDisplaying: (([IndexPath]) -> Void)?
            /// Handler that gets called whenever cells end getting displayed.
            var didEndDisplaying: (([IndexPath]) -> Void)?
        }

        var previousDisplayingIndexPaths: [IndexPath] {
            get { getAssociatedValue("previousDisplayingIndexPaths", initialValue: []) }
            set {
                setAssociatedValue(newValue, key: "previousDisplayingIndexPaths")
            }
        }

        var contentOffsetObserver: KeyValueObservation? {
            get { getAssociatedValue("contentOffsetObserver", initialValue: nil) }
            set { setAssociatedValue(newValue, key: "contentOffsetObserver") }
        }

        @objc func didScroll() {
            let isDisplaying = displayingCellsHandlers.isDisplaying
            let didEndDisplaying = displayingCellsHandlers.didEndDisplaying
            guard isDisplaying != nil || didEndDisplaying != nil else { return }

            let displayingIndexPaths = displayingIndexPaths()
            let previousDisplayingIndexPaths = previousDisplayingIndexPaths
            guard displayingIndexPaths != previousDisplayingIndexPaths else { return }
            self.previousDisplayingIndexPaths = displayingIndexPaths

            if let isDisplaying = isDisplaying {
                let indexPaths = displayingIndexPaths.filter { previousDisplayingIndexPaths.contains($0) == false }
                if indexPaths.isEmpty == false {
                    isDisplaying(indexPaths)
                }
            }

            if let didEndDisplaying = didEndDisplaying {
                let indexPaths = previousDisplayingIndexPaths.filter { displayingIndexPaths.contains($0) == false }
                if indexPaths.isEmpty == false {
                    didEndDisplaying(indexPaths)
                }
            }
        }

        func setupDisplayingItemsTracking() {
            if displayingCellsHandlers.isDisplaying != nil || displayingCellsHandlers.didEndDisplaying != nil {
                if contentOffsetObserver == nil {
                    contentOffsetObserver = observeChanges(for: \.contentOffset, handler: { [weak self] old, new in
                        guard let self = self, old != new else { return }
                        self.didScroll()
                    })
                }
            } else {
                contentOffsetObserver = nil
            }
        }
    }

fileprivate extension CGRect {
    func contains(any points: [CGPoint]) -> Bool {
        for point in points {
            if contains(point) {
                return true
            }
        }
        return false
    }
}

#endif
