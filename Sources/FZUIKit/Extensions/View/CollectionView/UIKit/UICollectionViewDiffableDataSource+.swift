//
//  UICollectionViewDiffableDataSource+.swift
//  DiffableDataSourceExtensions
//
//  Created by Florian Zand on 08.02.24.
//

#if os(iOS) || os(tvOS)
import UIKit
import FZSwiftUtils

extension UICollectionViewDiffableDataSource {
    
    /// The handlers for selecting rows.
    public var selectionHandlers: SelectionHandlers {
        get { getAssociatedValue(key: "selectionHandlers", object: self, initialValue: SelectionHandlers()) }
        set {
            set(associatedValue: newValue, key: "selectionHandlers", object: self)
            setupDelegate()
        }
    }
    
    /// The handlers for editing rows.
    public var editingHandlers: EditingHandlers {
        get { getAssociatedValue(key: "editingHandlers", object: self, initialValue: EditingHandlers()) }
        set {
            set(associatedValue: newValue, key: "editingHandlers", object: self)
            setupDelegate()
        }
    }
    
    /// The handlers for displaying rows.
    public var displayingHandlers: DisplayingHandlers {
        get { getAssociatedValue(key: "displayingHandlers", object: self, initialValue: DisplayingHandlers()) }
        set {
            set(associatedValue: newValue, key: "displayingHandlers", object: self)
            setupDelegate()
        }
    }
    
    /// The handlers for highlighting rows.
    public var highlightHandlers: HighlightHandlers {
        get { getAssociatedValue(key: "highlightHandlers", object: self, initialValue: HighlightHandlers()) }
        set {
            set(associatedValue: newValue, key: "highlightHandlers", object: self)
            setupDelegate()
        }
    }
    
    /// The handlers for focusing rows.
    public var focusHandlers: FocusingHandlers {
        get { getAssociatedValue(key: "focusHandlers", object: self, initialValue: FocusingHandlers()) }
        set {
            set(associatedValue: newValue, key: "focusHandlers", object: self)
            setupDelegate()
        }
    }
    
    #if os(iOS)
    /// The handlers for context menu.
    public var contextMenuHandlers: ContextMenuHandlers {
        get { getAssociatedValue(key: "contextMenuHandlers", object: self, initialValue: ContextMenuHandlers()) }
        set {
            set(associatedValue: newValue, key: "contextMenuHandlers", object: self)
            setupDelegate()
        }
    }
    #endif
    
    /// The view that is displayed when the datasource doesn't contain any items.
    public var emptyCollectionView: UIView? {
        get { getAssociatedValue(key: "emptyCollectionView", object: self, initialValue: nil) }
        set {
            guard emptyCollectionView != newValue else { return }
            set(associatedValue: newValue, key: "emptyCollectionView", object: self)
            updateEmptyCollectionView()
        }
    }
    
    func updateEmptyCollectionView() {
        let snapshot = snapshot()
        if !snapshot.itemIdentifiers.isEmpty && !snapshot.sectionIdentifiers.isEmpty {
            emptyCollectionView?.removeFromSuperview()
        } else if let emptyCollectionView = self.emptyCollectionView {
            collectionView?.addSubview(withConstraint: emptyCollectionView)
        }
    }
    
    var delegate: Delegate? {
        get { getAssociatedValue(key: "delegate", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "delegate", object: self) }
    }
    
    var collectionView: UICollectionView? {
        (value(forKeyPath: "_diffableDataSourceImpl") as? NSObject)?.value(forKeyPath: "_collectionView") as? UICollectionView
    }
    
    func setupDelegate() {
        var needsDelegate = selectionHandlers.needsDelegate ||  editingHandlers.needsDelegate || highlightHandlers.needsDelegate || displayingHandlers.needsDelegate || focusHandlers.needsDelegate
        #if os(iOS)
        needsDelegate = needsDelegate || contextMenuHandlers.needsDelegate
        #endif
        if needsDelegate {
            if delegate == nil {
                delegate = Delegate(self)
                collectionView?.delegate = delegate
            }
        } else {
            delegate = nil
        }
    }
    
    /// Returns an empty snapshot.
    public func emptySnapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
    }
    
    /// All current items in the collection view.
    public var items: [ItemIdentifierType] { snapshot().itemIdentifiers }
    
    /// The selected items.
    public var selectedItems: [ItemIdentifierType] {
        collectionView?.indexPathsForSelectedItems?.compactMap { itemIdentifier(for: $0)} ?? []
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
        if let indexPath = collectionView?.indexPathForItem(at: point), let item = itemIdentifier(for: indexPath) {
            return item
        }
        return nil
    }
    
    /// Selects all specified items.
    public func selectItems(_ items: [ItemIdentifierType], animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
        guard let collectionView = collectionView else { return }
        items.compactMap({indexPath(for: $0)}).forEach({ collectionView.selectItem(at: $0, animated: animated, scrollPosition: scrollPosition) })
    }
    
    /// Deselects all specified items.
    public func deselectItems(_ items: [ItemIdentifierType], animated: Bool) {
        guard let collectionView = collectionView else { return }
        items.compactMap({indexPath(for: $0)}).forEach({ collectionView.deselectItem(at: $0, animated: animated) })
    }
    
    /// Selects all items in the specified sections.
    public func selectItems(in sections: [SectionIdentifierType], animated: Bool, scrollPosition: UICollectionView.ScrollPosition) {
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
    
    /// Scrolls the collection view to the specified item.
    public func scrollToItem(_ item: ItemIdentifierType, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard let indexPath = indexPath(for: item) else { return }
        collectionView?.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    /// Reloads the collection view cells for the specified items.
    public func reloadItems(_ items: [ItemIdentifierType], _ option: NSDiffableDataSourceSnapshotApplyOption = .animated) {
        var snapshot = snapshot()
        snapshot.reloadItems(items)
        apply(snapshot, option)
    }
    
    /// Updates the data for the specified items, preserving the existing collection view cells for the items.
    @available(iOS 15.0, tvOS 15.0, *)
    public func reconfigureItems(_ items: [ItemIdentifierType], _ option: NSDiffableDataSourceSnapshotApplyOption = .animated) {
        var snapshot = snapshot()
        snapshot.reconfigureItems(items)
        apply(snapshot, option)
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
            didEndMultipleSelection != nil
            #else
            shouldSelect != nil ||
            didSelect != nil ||
            shouldDeselect != nil ||
            didDeselect != nil
            #endif
        }
    }
    
    /// Handlers for editing rows.
    public struct EditingHandlers {
        public var canEdit: ((ItemIdentifierType)->(Bool))?
       
        var needsDelegate: Bool {
            canEdit != nil
        }
    }
    
    /// Handlers for displaying items.
    public struct DisplayingHandlers {
        /// The handler that gets called whenever a cell is about to draw for an item.
        public var willDisplay: ((ItemIdentifierType, UICollectionViewCell)->())?
        /// The handler that gets called whenever a cell was removed.
        public var didEndDisplay: ((ItemIdentifierType, UICollectionViewCell)->())?
    
        var needsDelegate: Bool {
            willDisplay != nil ||
            didEndDisplay != nil
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
        public var shouldUpdateFocus: ((UICollectionViewFocusUpdateContext)->(Bool))?
        /// The handler that gets called whenever a focus update specified by the context has just occurred.
        public var didUpdateFocus: ((_ context: UICollectionViewFocusUpdateContext, _ coordinator: UIFocusAnimationCoordinator)->())?
        #if os(iOS)
        /// The handler that determines whether to relate selection and focus behavior for the item.
        public var selectionFollowsFocus: ((ItemIdentifierType)->(Bool))?
        #endif
        
        var needsDelegate: Bool {
            #if os(iOS)
            canFocus != nil ||
            shouldUpdateFocus != nil ||
            didUpdateFocus != nil ||
            selectionFollowsFocus != nil
            #else
            canFocus != nil ||
            didUpdateFocus != nil ||
            shouldUpdateFocus != nil
            #endif
        }
    }
    
    #if os(iOS)
    /// Handlers for the context menu.
    public struct ContextMenuHandlers {
        /// The handler that provides the context menu configuration for an item.
        public var configuration: (([ItemIdentifierType], CGPoint)->(UIContextMenuConfiguration?))?
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
}
#endif
