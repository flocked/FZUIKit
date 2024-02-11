//
//  UITableViewDiffableDataSource+.swift
//  
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit

/// A diffable table view datasource with additional handlers and methods.
class TableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType> : UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType> where SectionIdentifierType: Hashable & Sendable, ItemIdentifierType: Hashable & Sendable {
    
    weak var tableView: UITableView?
    var delegate: Delegate?
        
    /// A closure that creates and returns each of the section header views for the table view from the data the diffable data source provides.
    public var headerViewProvider: SectionViewProvider?
    
    /// A closure that creates and returns each of the section footer views for the table view from the data the diffable data source provides.
    public var footerViewProvider: SectionViewProvider?
    
    /// A closure that configures and returns a section header or footer view for a table view from its diffable data source.
    public typealias SectionViewProvider = (_ tableView: UITableView, _ sectionIdentifier: SectionIdentifierType) -> UIView
    
    /// Configurates the section header view provider with the specified registration.
    public func applyHeaderViewRegistration<HeaderView: UIView>(_ registration: UITableView.SectionViewRegistration<HeaderView, SectionIdentifierType>) {
        headerViewProvider = { tableView, section in
            tableView.dequeueConfiguredReusableSectionView(using: registration, section: section)
        }
    }
    
    /// Configurates the section footer view provider with the specified registration.
    public func applyFooterViewRegistration<FooterView: UIView>(_ registration: UITableView.SectionViewRegistration<FooterView, SectionIdentifierType>) {
        footerViewProvider = { tableView, section in
            tableView.dequeueConfiguredReusableSectionView(using: registration, section: section)
        }
    }
    
    /// The view that is displayed when the datasource doesn't contain any items.
    open var emptyCollectionView: UIView? = nil {
        didSet {
            guard oldValue != emptyCollectionView else { return }
            updateEmptyCollectionView()
        }
    }
    
    override func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        updateEmptyCollectionView()
    }
    
    @available(iOS 15.0, tvOS 15.0, *)
    override func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, completion: (() -> Void)? = nil) {
        super.applySnapshotUsingReloadData(snapshot, completion: completion)
        updateEmptyCollectionView()
    }
    
    func updateEmptyCollectionView() {
        let snapshot = snapshot()
        if !snapshot.itemIdentifiers.isEmpty && !snapshot.sectionIdentifiers.isEmpty {
            emptyCollectionView?.removeFromSuperview()
        } else if let emptyCollectionView = self.emptyCollectionView {
            tableView?.addSubview(withConstraint: emptyCollectionView)
        }
    }
    
    /// The handlers for selecting rows.
    public var selectionHandlers = SelectionHandlers() {
        didSet { setupDelegate() } }

    #if os(iOS)
    /// The handlers for swiping rows.
    public var swipeActionHandlers = SwipeActionHandlers() {
        didSet { setupDelegate() } }
    #endif
    
    /// The handlers for editing rows.
    public var editingHandlers = EditingHandlers() {
        didSet { setupDelegate() } }
    
    /// The handlers for displaying rows.
    public var displayingHandlers = DisplayingHandlers() {
        didSet { setupDelegate() } }
    
    /// The handlers for highlighting rows.
    public var highlightHandlers = HighlightHandlers() {
        didSet { setupDelegate() } }
    
    /// The handlers for focusing rows.
    public var focusHandlers = FocusingHandlers() {
        didSet { setupDelegate() } }
    
    #if os(iOS)
    /// The handlers for context menu.
    public var contextMenuHandlers = ContextMenuHandlers() {
        didSet { setupDelegate() } }
    #endif
    
    /**
     The handlers for reordering items.
     
     Provide ``ReorderingHandlers/canReorder`` to support the reordering of items in your table view.
     
     The system calls the ``ReorderingHandlers/didReorder`` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every item to be reordered
     dataSource.reorderingHandlers.canReorder = { elements in return true }
     
     // Option 1: Update the backing store from a CollectionDifference
     dataSource.reorderingHandlers.didDelete = { [weak self] items, transaction in
         guard let self = self else { return }
         
         if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
             self.backingStore = updatedBackingStore
         }
     }

     // Option 2: Update the backing store from the final items
     dataSource.reorderingHandlers.didReorder = { [weak self] items, transaction in
         guard let self = self else { return }
         
         self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    public var reorderingHandlers = ReorderingHandlers() {
        didSet { setupDelegate() } }
    
    /// Returns an empty snapshot.
    public func emptySnapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
    }
            
    /// All current items in the table view.
    public var items: [ItemIdentifierType] { snapshot().itemIdentifiers }
    
    /// The selected items.
    public var selectedItems: [ItemIdentifierType] {
        tableView?.indexPathsForSelectedRows?.compactMap { itemIdentifier(for: $0)} ?? []
    }
    
    func items(for section: SectionIdentifierType) -> [ItemIdentifierType] {
        snapshot().itemIdentifiers(inSection: section)
    }
    /**
     Returns the item of the specified index path.
     
     - Parameter indexPath: The indexPath
     - Returns: The item at the index path or nil if there isn't any item at the index path.
     */
    public func item(at point: CGPoint) -> ItemIdentifierType? {
        if let indexPath = tableView?.indexPathForRow(at: point), let item = itemIdentifier(for: indexPath) {
            return item
        }
        return nil
    }
    
    /// Selects all specified items.
    public func selectItems(_ items: [ItemIdentifierType], animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        guard let tableView = tableView else { return }
        items.compactMap({indexPath(for: $0)}).forEach({ tableView.selectRow(at: $0, animated: animated, scrollPosition: scrollPosition) })
    }
    
    /// Deselects all specified items.
    public func deselectItems(_ items: [ItemIdentifierType], animated: Bool) {
        guard let tableView = tableView else { return }
        items.compactMap({indexPath(for: $0)}).forEach({ tableView.deselectRow(at: $0, animated: animated) })
    }
    
    /// Selects all items in the specified sections.
    public func selectItems(in sections: [SectionIdentifierType], animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        let snapshot = snapshot()
        let items = sections.flatMap({snapshot.itemIdentifiers(inSection:$0)})
        selectItems(items, animated: animated, scrollPosition: scrollPosition)
    }
    
    /// Deselects all items in the specified sections.
    public func deselectItems(in sections: [SectionIdentifierType], animated: Bool) {
        let snapshot = snapshot()
        let items = sections.flatMap({snapshot.itemIdentifiers(inSection:$0)})
        deselectItems(items, animated: animated)
    }
    
    /// Scrolls the table view to the specified item.
    public func scrollToItem(_ item: ItemIdentifierType, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard let indexPath = indexPath(for: item) else { return }
        tableView?.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    /// Reloads the table view cells for the specified items.
    public func reloadItems(_ items: [ItemIdentifierType], _ option: NSDiffableDataSourceSnapshotApplyOption = .animated) {
        var snapshot = snapshot()
        snapshot.reloadItems(items)
        apply(snapshot, option)
    }
    
    /// Updates the data for the specified items, preserving the existing table view cells for the items.
    @available(iOS 15.0, tvOS 15.0, *)
    public func reconfigureItems(_ items: [ItemIdentifierType], _ option: NSDiffableDataSourceSnapshotApplyOption = .animated) {
        var snapshot = snapshot()
        snapshot.reconfigureItems(items)
        apply(snapshot, option)
    }
    
    /// All current sections in the table view.
    public var sections: [SectionIdentifierType] { snapshot().sectionIdentifiers }
    
    func _sectionIdentifier(for index: Int) -> SectionIdentifierType? {
        if #available(iOS 15.0, tvOS 15.0, *) {
            return sectionIdentifier(for: index)
        } else {
            return snapshot().sectionIdentifiers[safe: index]
        }
    }


    func setupDelegate() {
        var needsDelegate = headerViewProvider != nil || footerViewProvider != nil || selectionHandlers.needsDelegate || editingHandlers.needsDelegate || highlightHandlers.needsDelegate || displayingHandlers.needsDelegate || focusHandlers.needsDelegate
        #if os(iOS)
        needsDelegate = needsDelegate || contextMenuHandlers.needsDelegate || swipeActionHandlers.needsDelegate
        #endif
        if needsDelegate {
            if delegate == nil {
                delegate = Delegate(self)
                tableView?.delegate = delegate
            }
        } else {
            delegate = nil
        }
    }
    
    override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        self.tableView = tableView
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let canEdit = editingHandlers.canEdit else { return true }
        guard let item = itemIdentifier(for: indexPath) else { return true }
        return canEdit(item)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.reorderingHandlers.needsReordering, let canReorder = self.reorderingHandlers.canReorder, let item = self.itemIdentifier(for: indexPath) {
            return canReorder(item)
        }
        return false
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        guard reorderingHandlers.needsReordering else { return }
        guard let sourceId = itemIdentifier(for: sourceIndexPath), let destinationId =  itemIdentifier(for: destinationIndexPath) else { return }
        
        var snapshot = snapshot()
        if sourceIndexPath.section == destinationIndexPath.section {
            if sourceIndexPath.row > destinationIndexPath.row {
                snapshot.moveItem(sourceId, beforeItem: destinationId)
            } else {
                snapshot.moveItem(sourceId, afterItem: destinationId)
            }
        } else {
            snapshot.moveItem(sourceId, beforeItem: destinationId)
        }

        let transaction = DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>(initial: self.snapshot(), final: snapshot)
        reorderingHandlers.willReorder?(transaction, sourceId)
        apply(snapshot)
        reorderingHandlers.didReorder?(transaction, sourceId)
    }
    
    /// Handlers for selecting rows.
    public struct SelectionHandlers {
        /// The handler that determines whenever an item should be selected. The default value is `nil` which indicates that all items should get selected.
        public var shouldSelect: ((ItemIdentifierType)->(Bool))?
        /// The handler that gets called whenever an item is dedeselected.
        public var didSelect: ((ItemIdentifierType)->())?
        /// The handler that determines whenever an item should be deselected. The default value is `nil` which indicates that all items should get deselected.
        public var shouldDeselect: ((ItemIdentifierType)->(Bool))?
        /// The handler that gets called whenever an item is deselected.
        public var didDeselect: ((ItemIdentifierType)->())?
        /// The handler that gets called whenever the user tapped the detail button for an item.
        public var accessoryButtonTapped: ((ItemIdentifierType)->())?
        /// The handler that returns the level of indentation for a an item's row.
        public var indentationLevel: ((ItemIdentifierType)->(Int))?
        #if os(iOS)
        /// The handler that determines whether the user can use a two-finger pan gesture to select multiple items.
        public var shouldBeginMultipleSelection: ((ItemIdentifierType)->(Bool))?
        /// The handler that gets called whenever the user starts using a two-finger pan gesture to select multiple items.
        public var didBeginMultipleSelection: ((ItemIdentifierType)->())?
        /// The handler that gets called whenever the user stops using a two-finger pan gesture to select multiple items.
        public var didEndMultipleSelection: (()->())?
        #endif

        var needsDelegate: Bool {
            #if os(iOS)
            shouldSelect != nil ||
            didSelect != nil ||
            shouldDeselect != nil ||
            didDeselect != nil ||
            shouldBeginMultipleSelection != nil ||
            didBeginMultipleSelection != nil ||
            didEndMultipleSelection != nil ||
            accessoryButtonTapped != nil ||
            indentationLevel != nil
            #else
            shouldSelect != nil ||
            didSelect != nil ||
            shouldDeselect != nil ||
            didDeselect != nil ||
            accessoryButtonTapped != nil ||
            indentationLevel != nil
            #endif
        }
    }
    
    #if os(iOS)
    /// Handlers for swiping rows.
    public struct SwipeActionHandlers {
        /// The handler that provides the leading swipe actions configuration.
        public var leading: ((ItemIdentifierType)->(UISwipeActionsConfiguration?))?
        /// The handler that provides the trailing swipe actions configuration.
        public var trailing: ((ItemIdentifierType)->(UISwipeActionsConfiguration?))?
        
        var needsDelegate: Bool {
            leading != nil ||
            trailing != nil
        }
    }
    #endif
    
    /// Handlers for editing rows.
    public struct EditingHandlers {
        /// The handler that determines whether an item is editable. The default value is `nil` which indicates that all items are editable.
        public var canEdit: ((ItemIdentifierType)->(Bool))?
        /// The handler that determines the editing style of an item.
        public var editingStyle: ((ItemIdentifierType)->(UITableViewCell.EditingStyle))?
        /// The handler that determines whether the background of an item's row should be indented while the table view is in editing mode.
        public var shouldIndentWhileEditing: ((ItemIdentifierType)->(Bool))?
        #if os(iOS)
        /// The handler that changes the default title of the delete-confirmation button for an item.
        public var titleForDeleteConfirmationButton: ((ItemIdentifierType)->(String?))?
        /// The handler that gets called whenever an item is about to go into editing mode.
        public var willBegin: ((ItemIdentifierType)->())?
        /// The handler that gets called whenever the table view has left editing mode for an item.
        public var didEnd: ((ItemIdentifierType)->())?
        #endif

        var needsDelegate: Bool {
            #if os(iOS)
            canEdit != nil ||
            editingStyle != nil ||
            titleForDeleteConfirmationButton != nil ||
            shouldIndentWhileEditing != nil
            #else
            canEdit != nil ||
            editingStyle != nil ||
            shouldIndentWhileEditing != nil
            #endif
        }
    }
    
    /// Handlers for displaying items.
    public struct DisplayingHandlers {
        /// The handler that gets called whenever a cell is about to draw for an item.
        public var willDisplay: ((ItemIdentifierType, UITableViewCell)->())?
        /// The handler that gets called whenever a cell was removed.
        public var didEndDisplay: ((ItemIdentifierType, UITableViewCell)->())?
        /// The handler that gets called whenever a header view is about to draw for a section.
        public var willDisplayHeader: ((SectionIdentifierType, UIView)->())?
        /// The handler that gets called whenever a header view was removed.
        public var didEndDisplayHeader: ((SectionIdentifierType, UIView)->())?
        /// The handler that gets called whenever a footer view is about to draw for a section.
        public var willDisplayFooter: ((SectionIdentifierType, UIView)->())?
        /// The handler that gets called whenever a footer view was removed.
        public var didEndDisplayFooter: ((SectionIdentifierType, UIView)->())?
        
        var needsDelegate: Bool {
            willDisplay != nil ||
            didEndDisplay != nil ||
            willDisplayHeader != nil ||
            didEndDisplayHeader != nil ||
            willDisplayFooter != nil ||
            didEndDisplayFooter != nil
        }
    }
    
    /// Handlers for highlighting items.
    public struct HighlightHandlers {
        /// The handler that determines whether an item should be highlighted.
        public var shouldHighlight: ((ItemIdentifierType)->(Bool))?
        /// The handler that gets called whenever an item was highlighted.
        public var didHighlight: ((ItemIdentifierType)->())?
        /// The handler that gets called whenever an item was unhighlighted.
        public var didUnhighlight: ((ItemIdentifierType)->())?
        
        var needsDelegate: Bool {
            shouldHighlight != nil ||
            didHighlight != nil ||
            didUnhighlight != nil
        }
    }
    
    /// Handlers for focusing rows.
    public struct FocusingHandlers {
        /// The handler that determines whether an item is focusable.
        public var canFocus: ((ItemIdentifierType)->(Bool))?
        /// The handler that determines whether a focus update specified by the context is allowed to occur.
        public var shouldUpdateFocus: ((UITableViewFocusUpdateContext)->(Bool))?
        /// The handler that gets called whenever a focus update specified by the context has just occurred.
        public var didUpdateFocus: ((_ context: UITableViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator)->())?
        /// The handler that determines whether to relate selection and focus behavior for the item.
        public var selectionFollowsFocus: ((ItemIdentifierType)->(Bool))?
        
        var needsDelegate: Bool {
            canFocus != nil ||
            shouldUpdateFocus != nil ||
            didUpdateFocus != nil ||
            selectionFollowsFocus != nil
        }
    }
    
    #if os(iOS)
    /// Handlers for the context menu.
    public struct ContextMenuHandlers {
        /// The handler that provides the context menu configuration for an item.
        public var configuration: ((ItemIdentifierType, CGPoint)->(UIContextMenuConfiguration?))?
        /// The handler that gets called whenever a context menu will appear.
        public var willDisplay: ((_ configuration: UIContextMenuConfiguration, _ animator: UIContextMenuInteractionAnimating?)->())?
        /// The handler that gets called whenever a context menu will disappear.
        public var willEndDisplay: ((_ configuration: UIContextMenuConfiguration, _ animator: UIContextMenuInteractionAnimating?)->())?
        /// The handler that provides the destination view when dismissing a context menu.
        public var previewForDismissing: ((_ configuration: UIContextMenuConfiguration)->(UITargetedPreview?))?
        /// The handler that returns a view to override the default preview the collection view created.
        public var previewForHighlighting: ((_ configuration: UIContextMenuConfiguration)->(UITargetedPreview?))?
        /// The handler that gets called whenever a user triggers a commit by tapping the preview.
        public var willPerformPreviewAction: ((_ configuration: UIContextMenuConfiguration, _ animator: UIContextMenuInteractionCommitAnimating)->())?

        var needsDelegate: Bool {
            configuration != nil ||
            willDisplay != nil ||
            willEndDisplay != nil ||
            previewForDismissing != nil ||
            previewForHighlighting != nil ||
            willPerformPreviewAction != nil
        }
    }
    #endif
    /**
     Handlers for reordering items.
     
     Take a look at ``reorderingHandlers`` how to support reordering elements.
     */
    public struct ReorderingHandlers {
        /// The handler that determines whether the user can reorder a particular item.
        public var canReorder: ((ItemIdentifierType)->(Bool))?
        /// The handler that that gets called before reordering items.
        public var willReorder: ((DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>, ItemIdentifierType)->())?
        /**
         The handler that that gets called after reordering items.

         The system calls the `didReorder` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
         ```swift
         // Allow every item to be reordered
         dataSource.reorderingHandlers.canDelete = { elements in return true }

         // Option 1: Update the backing store from a CollectionDifference
         dataSource.reorderingHandlers.didDelete = { [weak self] items, transaction in
             guard let self = self else { return }
             
             if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
                 self.backingStore = updatedBackingStore
             }
         }

         // Option 2: Update the backing store from the final items
         dataSource.reorderingHandlers.didReorder = { [weak self] items, transaction in
             guard let self = self else { return }
             
             self.backingStore = transaction.finalSnapshot.itemIdentifiers
         }
         ```
         */
        public var didReorder: ((DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>, ItemIdentifierType)->())?
        
        var needsReordering: Bool {
            canReorder != nil && didReorder != nil
        }
    }
}
#endif
