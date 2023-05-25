//
//  NSCollectionView+QLPreviewable.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

#if os(macOS)
import AppKit

public extension NSCollectionView {
    func quicklookItems(at indexPaths: [IndexPath], currentIndexPath: IndexPath? = nil) {
        guard let dataSource = dataSource else { return }
        var currentItem: NSCollectionViewItem?
        let items = indexPaths.compactMap { dataSource.collectionView(self, itemForRepresentedObjectAt: $0) }
        if let currentIndexPath = currentIndexPath {
            currentItem = dataSource.collectionView(self, itemForRepresentedObjectAt: currentIndexPath)
        }
        quicklookItems(items, currentItem: currentItem)
    }

    func qlPreviewable(for item: NSCollectionViewItem) -> QLPreviewable? {
        guard let indexPath = indexPath(for: item) else { return nil }
        if let qlItem = (dataSource as? PreviewableDataSource)?.qlPreviewable(for: indexPath) {
            return qlItem
        }
        return item as? QLPreviewable
    }

    func quicklookItems(_ items: [NSCollectionViewItem], currentItem: NSCollectionViewItem? = nil) {
        var index = 0
        var previewItems: [QLPreviewable] = []
        for item in items {
            if let qlPreviewable = qlPreviewable(for: item) {
                previewItems.append(qlPreviewable)
                if item == currentItem {
                    index = previewItems.count - 1
                }
            }
        }
        /*
         let items = items.filter({($0 as? QLPreviewable) != nil})
         let  quicklookItems = items.compactMap({ $0 as? QLPreviewable})
         guard quicklookItems.isEmpty == false else { return }
         var index: Int = 0
         if let currentItem = currentItem {
             index =  items.firstIndex(of: currentItem) ?? 0
         }
         */
        // let transitionImage = previewItems[index].previewItemTransitionImage ?? items[index].view.renderedImage
        QuicklookPanel.shared.keyDownResponder = self
        QuicklookPanel.shared.present(previewItems, currentItemIndex: index)
    }

    func quicklookSelectedItems(currentItem: NSCollectionViewItem? = nil) {
        let selectedItems = selectionIndexPaths.compactMap { self.item(at: $0) }
        quicklookItems(selectedItems, currentItem: currentItem)
    }
}

internal protocol PreviewableDataSource {
    func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable?
}

internal extension PreviewableDataSource {
    func qlPreviewable(for indexPaths: [IndexPath]) -> [QLPreviewable] {
        indexPaths.compactMap { self.qlPreviewable(for: $0) }
    }
}

extension NSCollectionViewDiffableDataSource: PreviewableDataSource where ItemIdentifierType: QLPreviewable {
    func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable? {
        itemIdentifier(for: indexPath)
    }
}

@available(macOS 11.0, *)
extension NSTableViewDiffableDataSource: PreviewableDataSource where ItemIdentifierType: QLPreviewable {
    func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable? {
        itemIdentifier(forRow: indexPath.item)
    }
}

#endif
