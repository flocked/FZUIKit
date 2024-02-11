//
//  UICollectionViewDiffableDataSource+Delegate.swift
//  DiffableDataSourceExtensions
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension UICollectionViewDiffableDataSource {
    class Delegate: NSObject, UICollectionViewDelegate {
        let dataSource: UICollectionViewDiffableDataSource
            
        func collectionView(_ collectionVIew: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
            guard let shouldSelect = dataSource.selectionHandlers.shouldSelect else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return shouldSelect(item)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let didSelect = dataSource.selectionHandlers.didSelect else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didSelect(item)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
            guard let shouldDeselect = dataSource.selectionHandlers.shouldDeselect else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return shouldDeselect(item)
        }
        
        #if os(iOS)
        func collectionView(_ collectionVIew: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
            guard let shouldBeginMultiple = dataSource.selectionHandlers.shouldBeginMultipleSelection else { return false }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
            return shouldBeginMultiple(item)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
            guard let didBeginMultiple = dataSource.selectionHandlers.didBeginMultipleSelection else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didBeginMultiple(item)
        }
        
        func collectionViewDidEndMultipleSelectionInteraction(_ collectionVIew: UICollectionView) {
            guard let didEndMultiple = dataSource.selectionHandlers.didEndMultipleSelection else { return }
            didEndMultiple()
        }
        
        func collectionView(_ collectionVIew: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool {
            guard let selectionFollowsFocus = dataSource.focusHandlers.selectionFollowsFocus else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return selectionFollowsFocus(item)
        }
        
        func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
            guard let previewForDismissing = dataSource.contextMenuHandlers.previewForDismissing else { return nil }
            return previewForDismissing(configuration)
        }
        
        func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
            guard let previewForHighlighting = dataSource.contextMenuHandlers.previewForHighlighting else { return nil }
            return previewForHighlighting(configuration)
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            guard let willDisplay = dataSource.contextMenuHandlers.willDisplay else { return }
            willDisplay(configuration, animator)
        }
        
        func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
            guard let configuration = dataSource.contextMenuHandlers.configuration else { return nil }
            let items = indexPaths.compactMap({dataSource.itemIdentifier(for:$0)})
            return configuration(items, point)
        }

        func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            guard let willPerform = dataSource.contextMenuHandlers.willPerformPreviewAction else { return }
            willPerform(configuration, animator)
        }
        
        func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            guard let willEnd = dataSource.contextMenuHandlers.willEndDisplay else { return }
            willEnd(configuration, animator)
        }
#endif
        
        func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
            guard let canEdit = dataSource.editingHandlers.canEdit else { return false }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
            return canEdit(item)
        }
        

        func collectionView(_ collectionVIew: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
            guard let shouldHighlight = dataSource.highlightHandlers.shouldHighlight else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return shouldHighlight(item)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
            guard let didHighlight = dataSource.highlightHandlers.didHighlight else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didHighlight(item)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
            guard let didUnhighlight = dataSource.highlightHandlers.didUnhighlight else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didUnhighlight(item)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
            guard let canFocus = dataSource.focusHandlers.canFocus else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return canFocus(item)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
            guard let shouldUpdate = dataSource.focusHandlers.shouldUpdateFocus else { return true }
            return shouldUpdate(context)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
            guard let didUpdate = dataSource.focusHandlers.didUpdateFocus else { return }
            didUpdate(context, coordinator)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let willDisplay = dataSource.displayingHandlers.willDisplay else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            willDisplay(item, cell)
        }
        
        func collectionView(_ collectionVIew: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let didEndDisplay = dataSource.displayingHandlers.didEndDisplay else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didEndDisplay(item, cell)
        }
        
        init(_ dataSource: UICollectionViewDiffableDataSource!) {
            self.dataSource = dataSource
        }
    }
}
#endif
