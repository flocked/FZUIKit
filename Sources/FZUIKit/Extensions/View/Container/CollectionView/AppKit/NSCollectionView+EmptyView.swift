//
//  NSCollectionView+EmptyView.swift
//
//
//  Created by Florian Zand on 03.04.24.
//

#if os(macOS)
import FZSwiftUtils
import AppKit

extension NSCollectionView {
    /**
     A view that is displayed whenever the collection view is empty.
     
     Applying this property, will set ``AppKit/NSCollectionView/emptyContentConfiguration`` to `nil`.
     */
    public var emptyContentView: NSView? {
        get { getAssociatedValue("emptyContentView") }
        set {
            guard newValue != emptyContentView else { return }
            setAssociatedValue(newValue, key: "emptyContentView")
            if let newValue = newValue {
                emptyContentConfiguration = nil
                if emptyView == nil {
                    emptyView = .init(frame: .zero)
                }
                emptyView?.emptyView = newValue
            } else if let emptyView = emptyView, emptyView.contentConfiguration == nil {
                self.emptyView = nil
            }
            swizzleNumberOfSectionsIfNeeded()
            updateEmptyView()
        }
    }
    
    /**
     A content configuration that is displayed whenever the collection view is empty.
     
     Applying this property, will set ``AppKit/NSCollectionView/emptyContentView`` to `nil`.
     */
    public var emptyContentConfiguration: NSContentConfiguration? {
        get { getAssociatedValue("emptyContentConfiguration") }
        set {
            setAssociatedValue(newValue, key: "emptyContentConfiguration")
            if let newValue = newValue {
                emptyContentView = nil
                if emptyView == nil {
                    emptyView = .init(frame: .zero)
                }
                emptyView?.contentConfiguration = newValue
            } else if let emptyView = emptyView, emptyView.contentConfiguration != nil {
                self.emptyView = nil
            }
            swizzleNumberOfSectionsIfNeeded()
            updateEmptyView()
        }
    }
    
    /**
     A handler that is called whenever the collection view is empty.
     
     - Parameter isEmpty: A Boolean value indicating whether the collection view is empty.
     */
    public var emptyContentHandler: ((_ isEmpty: Bool)->())? {
        get { getAssociatedValue("emptyContentHandler") }
        set { 
            setAssociatedValue(newValue, key: "emptyContentHandler")
            guard newValue != nil else { return }
            swizzleNumberOfSectionsIfNeeded()
        }
    }
    
    fileprivate var emptyView: EmptyCollectionTableView? {
        get { getAssociatedValue("emptyView") }
        set {
            guard newValue !== emptyView else { return }
            emptyView?.removeFromSuperview()
            setAssociatedValue(newValue, key: "emptyView")
        }
    }
    
    fileprivate func updateEmptyView() {
        guard let emptyView = emptyView else { return }
        if isEmpty == false {
            emptyView.removeFromSuperview()
        } else if emptyView.superview == nil {
            addSubview(withConstraint: emptyView)
        }
    }
    
    fileprivate func swizzleNumberOfSectionsIfNeeded() {
        if emptyContentHandler != nil || emptyContentHandler != nil || emptyContentView != nil {
            guard datasourceObservation == nil else { return }
            updateIsEmpty()
            datasourceObservation = observeChanges(for: \.dataSource) { [weak self] old, new in
                guard let self = self else { return }
                old?.swizzleIsEmpty(false)
                new?.swizzleIsEmpty()
                self.updateIsEmpty()
            }
            dataSource?.swizzleIsEmpty()
        } else {
            datasourceObservation = nil
            dataSource?.swizzleIsEmpty(false)
        }
    }
    
    fileprivate func updateIsEmpty() {
        isEmpty = dataSource?.isEmpty(in: self) ?? ((0..<numberOfSections).compactMap({ numberOfItems(inSection: $0) }).sum() == 0)
    }
    
    fileprivate var isEmpty: Bool {
        get { getAssociatedValue("isEmpty") ?? false }
        set {
            guard newValue != isEmpty else { return }
            setAssociatedValue(newValue, key: "isEmpty")
            updateEmptyView()
            emptyContentHandler?(newValue)
        }
    }
    
    fileprivate var datasourceObservation: KeyValueObservation? {
        get { getAssociatedValue("datasourceObservation") }
        set { setAssociatedValue(newValue, key: "datasourceObservation") }
    }
}

fileprivate extension NSCollectionViewDataSource {
    func isEmpty(in collectionView: NSCollectionView) -> Bool {
        if let numberOfSections = numberOfSections?(in: collectionView) {
            for section in 0..<numberOfSections {
                if self.collectionView(collectionView, numberOfItemsInSection: section) > 0 {
                    return false
                }
            }
            return true
        }
        return self.collectionView(collectionView, numberOfItemsInSection: 0) <= 0
    }
    
    func swizzleIsEmpty(_ shouldSwizzle: Bool = true) {
        if responds(to: #selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) {
            swizzleNumberOfSections(shouldSwizzle)
        } else {
            swizzleNumberOfItems(shouldSwizzle)
        }
    }
    
    func swizzleNumberOfItems(_ shouldSwizzle: Bool = true) {
        guard let dataSource = self as? NSObject else { return }
        if shouldSwizzle, numberOfItemsHook == nil {
            do {
                numberOfItemsHook = try dataSource.hook(#selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)), closure: { original, object, sel, collectionView, section in
                    let numberOfItems = original(object, sel, collectionView, section)
                    collectionView.isEmpty = numberOfItems <= 0
                    return numberOfItems
                } as @convention(block) ( (AnyObject, Selector, NSCollectionView, Int) -> Int, AnyObject, Selector, NSCollectionView, Int) -> Int)
            } catch {
                debugPrint(error)
            }
        } else if !shouldSwizzle {
            try? numberOfItemsHook?.revert()
            numberOfItemsHook = nil
        }
    }
    
    func swizzleNumberOfSections(_ shouldSwizzle: Bool = true) {
        guard let dataSource = self as? NSObject else { return }
        if shouldSwizzle, numberOfSectionsHook == nil {
            do {
                numberOfSectionsHook = try dataSource.hook(#selector(NSCollectionViewDataSource.numberOfSections(in:)), closure: { original, object, sel, collectionView in
                    let numberOfSections = original(object, sel, collectionView)
                    if numberOfSections <= 0 {
                        collectionView.isEmpty = true
                    } else if let dataSource = object as? NSCollectionViewDataSource {
                        var isEmpty = true
                        for section in 0..<numberOfSections {
                            if dataSource.collectionView(collectionView, numberOfItemsInSection: section) > 0 {
                                isEmpty = false
                                break
                            }
                        }
                        collectionView.isEmpty = isEmpty
                    }
                    return numberOfSections
                } as @convention(block) ( (AnyObject, Selector, NSCollectionView) -> Int, AnyObject, Selector, NSCollectionView) -> Int)
            } catch {
                debugPrint(error)
            }
        } else if !shouldSwizzle {
            try? numberOfSectionsHook?.revert()
            numberOfSectionsHook = nil
        }
    }
    
    var numberOfItemsHook: Hook? {
        get { FZSwiftUtils.getAssociatedValue("numberOfItemsHook", object: self) }
        set { FZSwiftUtils.setAssociatedValue(newValue, key: "numberOfItemsHook", object: self) }
    }
    
    var numberOfSectionsHook: Hook? {
        get { FZSwiftUtils.getAssociatedValue("numberOfSectionsHook", object: self) }
        set { FZSwiftUtils.setAssociatedValue(newValue, key: "numberOfSectionsHook", object: self) }
    }
}

fileprivate class EmptyCollectionTableView: NSView {
    fileprivate var boundsSize: CGSize = .zero
    
    var emptyView: NSView? {
        didSet {
            guard oldValue != emptyView else { return }
            emptyView?.removeFromSuperview()
            guard let emptyView = emptyView?.size(bounds.size) else { return }
            addSubview(emptyView)
        }
    }
    
    var contentConfiguration: NSContentConfiguration? {
        didSet {
            if let configuration = contentConfiguration {
                if let contentView = contentView, contentView.supports(configuration) {
                    contentView.configuration = configuration
                } else {
                    emptyView = configuration.makeContentView()
                }
            } else {
                emptyView = nil
            }
        }
    }
    
    fileprivate var contentView: (NSView & NSContentView)? {
        emptyView as? NSView & NSContentView
    }
    
    override func layout() {
        super.layout()
        guard bounds.size != boundsSize else { return }
        boundsSize = bounds.size
        emptyView?.frame.size = boundsSize
    }
}

/*
extension NSCollectionView {
    fileprivate var subviewHooks: [Hook] {
        get { getAssociatedValue("subviewHooks") ?? [] }
        set { setAssociatedValue(newValue, key: "subviewHooks") }
    }
    
    func swizzleIsEmpty(shouldSwizzle: Bool = true) {
        if shouldSwizzle {
            guard subviewHooks.isEmpty else { return }
            do {
                subviewHooks += try hook(#selector(NSView.didAddSubview(_:)), closure: {
                    original, view, selector, subview in
                    original(view, selector, subview)
                    view.isEmpty = view.subviews(where: { $0.parentController is NSCollectionViewItem }, depth: 1).isEmpty
                } as @convention(block) ( (NSCollectionView, Selector, NSView) -> Void, NSCollectionView, Selector, NSView) -> Void)
                subviewHooks += try hook(#selector(NSView.willRemoveSubview(_:)), closure: {
                    original, view, selector, subview in
                    original(view, selector, subview)
                    view.isEmpty = view.subviews(where: { $0 != subview && $0.parentController is NSCollectionViewItem }, depth: 1).isEmpty
                } as @convention(block) ( (NSCollectionView, Selector, NSView) -> Void, NSCollectionView, Selector, NSView) -> Void)
            } catch {
                Swift.print(error)
            }
        } else {
            subviewHooks.forEach({ try? $0.revert() })
            subviewHooks = []
        }
    }
}
*/

#endif
