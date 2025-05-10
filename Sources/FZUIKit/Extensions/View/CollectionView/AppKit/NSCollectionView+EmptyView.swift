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
    
    /// A view that is displayed whenever the collection view is empty.
    public var emptyContentView: NSView {
        swizzleNumberOfSectionsIfNeeded()
        updateEmptyView()
        return _emptyContentView
    }
    
    /// A content configuration that is displayed whenever the collection view is empty.
    public var emptyContentConfiguration: NSContentConfiguration? {
        get { _emptyContentView.contentConfiguration }
        set {
            swizzleNumberOfSectionsIfNeeded()
            updateEmptyView()
            _emptyContentView.contentConfiguration = newValue
        }
    }
    
    /// A handler that is called whenever the collection view is empty.
    public var emptyContentHandler: ((_ isEmpty: Bool)->())? {
        get { getAssociatedValue("emptyContentHandler") }
        set { 
            setAssociatedValue(newValue, key: "emptyContentHandler")
            if newValue != nil {
                swizzleNumberOfSectionsIfNeeded()
            }
        }
    }
    
    func updateEmptyView() {
        if isEmpty == false {
            _emptyContentView.removeFromSuperview()
        } else if _emptyContentView.superview == nil {
            addSubview(withConstraint: _emptyContentView)
        }
    }
    
    var _emptyContentView: ContentConfigurationView {
        getAssociatedValue("_emptyContentView", initialValue: ContentConfigurationView())
    }
    
    func swizzleNumberOfSectionsIfNeeded() {
        if datasourceObservation == nil {
            isEmpty = dataSource?.isEmpty(in: self) ?? true
            datasourceObservation = observeChanges(for: \.dataSource) { [weak self] old, new in
                guard let self = self else { return }
                old?.swizzleIsEmpty(false)
                new?.swizzleIsEmpty()
                self.isEmpty = new?.isEmpty(in: self) ?? true
            }
            dataSource?.swizzleNumberOfSections()
        }
    }
    
    var isEmpty: Bool {
        get { getAssociatedValue("isEmpty", initialValue: (0..<numberOfSections).compactMap({ numberOfItems(inSection: $0) }).sum() == 0) }
        set {
            guard newValue != isEmpty else { return }
            setAssociatedValue(newValue, key: "isEmpty")
            updateEmptyView()
            emptyContentHandler?(newValue)
        }
    }
    
    var datasourceObservation: KeyValueObservation? {
        get { getAssociatedValue("datasourceObservation") }
        set { setAssociatedValue(newValue, key: "datasourceObservation") }
    }
}

extension NSCollectionViewDataSource {
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
        let isMethodHooked = dataSource.isMethodHooked(#selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)))
        if shouldSwizzle, !isMethodHooked {
            do {
                try dataSource.hook(#selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)), closure: { original, object, sel, collectionView, section in
                    let numberOfItems = original(object, sel, collectionView, section)
                    collectionView.isEmpty = numberOfItems <= 0
                    return numberOfItems
                } as @convention(block) (
                    (AnyObject, Selector, NSCollectionView, Int) -> Int,
                    AnyObject, Selector, NSCollectionView, Int) -> Int)
            } catch {
                debugPrint(error)
            }
        } else if !shouldSwizzle, isMethodHooked {
            dataSource.revertHooks(for: #selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)))
        }
    }
    
    func swizzleNumberOfSections(_ shouldSwizzle: Bool = true) {
        guard let dataSource = self as? NSObject else { return }
        let isMethodHooked = dataSource.isMethodHooked(#selector(NSCollectionViewDataSource.numberOfSections(in:)))
        if shouldSwizzle, !isMethodHooked {
            do {
                try dataSource.hook(#selector(NSCollectionViewDataSource.numberOfSections(in:)), closure: { original, object, sel, collectionView in
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
                } as @convention(block) (
                    (AnyObject, Selector, NSCollectionView) -> Int,
                    AnyObject, Selector, NSCollectionView) -> Int)
            } catch {
                debugPrint(error)
            }
        } else if !shouldSwizzle, isMethodHooked {
            dataSource.revertHooks(for: #selector(NSCollectionViewDataSource.numberOfSections(in:)))
        }
    }
}

#endif
