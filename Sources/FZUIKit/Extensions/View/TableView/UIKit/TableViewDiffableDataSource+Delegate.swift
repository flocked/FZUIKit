//
//  TableViewDiffableDataSource+Delegate.swift
//  
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit

extension TableViewDiffableDataSource {
    class Delegate: NSObject, UITableViewDelegate {
        let dataSource: TableViewDiffableDataSource
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard let headerViewProvider = dataSource.headerViewProvider, let section = dataSource._sectionIdentifier(for: section) else { return nil }
            return headerViewProvider(tableView, section)
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
           // dataSource.snapshot().sectionIdentifiers[]
            guard let footerViewProvider = dataSource.footerViewProvider, let section = dataSource._sectionIdentifier(for: section) else { return nil }
            return footerViewProvider(tableView, section)
        }
        
        func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
            guard let shouldSelect = dataSource.selectionHandlers.shouldSelect else { return indexPath }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return indexPath }
            return shouldSelect(item) ? indexPath : nil
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let didSelect = dataSource.selectionHandlers.didSelect else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didSelect(item)
        }
        
        func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
            guard let shouldDeselect = dataSource.selectionHandlers.shouldDeselect else { return indexPath }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return indexPath }
            return shouldDeselect(item) ? indexPath : nil
        }
        
        #if os(iOS)
        func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
            guard let shouldBeginMultiple = dataSource.selectionHandlers.shouldBeginMultipleSelection else { return false }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
            return shouldBeginMultiple(item)
        }
        
        func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
            guard let didBeginMultiple = dataSource.selectionHandlers.didBeginMultipleSelection else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didBeginMultiple(item)
        }
        
        func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
            guard let didEndMultiple = dataSource.selectionHandlers.didEndMultipleSelection else { return }
            didEndMultiple()
        }
        
        func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
            guard let willBegin = dataSource.editingHandlers.willBegin else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            willBegin(item)
        }
        
        func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
            guard let didEnd = dataSource.editingHandlers.didEnd else { return }
            guard let indexPath = indexPath else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didEnd(item)
        }
        
        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let leading = dataSource.swipeActionHandlers.leading else { return nil }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
            return leading(item)
        }
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let trailing = dataSource.swipeActionHandlers.trailing else { return nil }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
            return trailing(item)
        }
        
        func tableView(_ tableView: UITableView, selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool {
            guard let selectionFollowsFocus = dataSource.focusHandlers.selectionFollowsFocus else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return selectionFollowsFocus(item)
        }
        
        func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
            guard let previewForDismissing = dataSource.contextMenuHandlers.previewForDismissing else { return nil }
            return previewForDismissing(configuration)
        }
        
        func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
            guard let previewForHighlighting = dataSource.contextMenuHandlers.previewForHighlighting else { return nil }
            return previewForHighlighting(configuration)
        }
        
        func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            guard let willPerform = dataSource.contextMenuHandlers.willPerformPreviewAction else { return }
            willPerform(configuration, animator)
        }
        
        func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            guard let willEnd = dataSource.contextMenuHandlers.willEndDisplay else { return }
            willEnd(configuration, animator)
        }
        
        func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            guard let configuration = dataSource.contextMenuHandlers.configuration else { return nil }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
            return configuration(item, point)
        }
        
        func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            guard let willDisplay = dataSource.contextMenuHandlers.willDisplay else { return }
            willDisplay(configuration, animator)
        }
        
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
            guard let titleForDeleteConfirmationButton = dataSource.editingHandlers.titleForDeleteConfirmationButton else { return nil }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
            return titleForDeleteConfirmationButton(item)
        }
    #endif

        func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            guard let accessoryButtonTapped = dataSource.selectionHandlers.accessoryButtonTapped else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            accessoryButtonTapped(item)
        }
        
        func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
            guard let indentationLevel = dataSource.selectionHandlers.indentationLevel else { return 0 }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return 0 }
            return indentationLevel(item)
        }
        
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            if let editingStyle = dataSource.editingHandlers.editingStyle, let item = dataSource.itemIdentifier(for: indexPath) {
                return editingStyle(item)
            }
            return .none
        }
                
        func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
            guard let shouldIndent = dataSource.editingHandlers.shouldIndentWhileEditing else { return false }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
            return shouldIndent(item)
        }
        
        func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
            guard let shouldHighlight = dataSource.highlightHandlers.shouldHighlight else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return shouldHighlight(item)
        }
        
        func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
            guard let didHighlight = dataSource.highlightHandlers.didHighlight else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didHighlight(item)
        }
        
        func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
            guard let didUnhighlight = dataSource.highlightHandlers.didUnhighlight else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didUnhighlight(item)
        }
        
        func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
            guard let canFocus = dataSource.focusHandlers.canFocus else { return true }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return true }
            return canFocus(item)
        }
        
        func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
            guard let shouldUpdate = dataSource.focusHandlers.shouldUpdateFocus else { return true }
            return shouldUpdate(context)
        }
        
        func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
            guard let didUpdate = dataSource.focusHandlers.didUpdateFocus else { return }
            didUpdate(context, coordinator)
        }
        
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            guard let willDisplayHeader = dataSource.displayingHandlers.willDisplayHeader else { return }
            guard let section = dataSource._sectionIdentifier(for: section) else { return }
            willDisplayHeader(section, view)
        }
        
        func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
            guard let willDisplayFooter = dataSource.displayingHandlers.willDisplayFooter else { return }
            guard let section = dataSource._sectionIdentifier(for: section) else { return }
            willDisplayFooter(section, view)
        }
        
        func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
            guard let didEndDisplayHeader = dataSource.displayingHandlers.didEndDisplayHeader else { return }
            guard let section = dataSource._sectionIdentifier(for: section) else { return }
            didEndDisplayHeader(section, view)
        }
        
        func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
            guard let didEndDisplayFooter = dataSource.displayingHandlers.didEndDisplayFooter else { return }
            guard let section = dataSource._sectionIdentifier(for: section) else { return }
            didEndDisplayFooter(section, view)
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let willDisplay = dataSource.displayingHandlers.willDisplay else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            willDisplay(item, cell)
        }
        
        func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let didEndDisplay = dataSource.displayingHandlers.didEndDisplay else { return }
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            didEndDisplay(item, cell)
        }
        
        init(_ dataSource: TableViewDiffableDataSource) {
            self.dataSource = dataSource
        }
    }
}
#endif
