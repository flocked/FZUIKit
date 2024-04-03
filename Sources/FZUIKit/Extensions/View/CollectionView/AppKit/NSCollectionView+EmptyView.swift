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
        get { _emptyContentView.configuration }
        set {
            swizzleNumberOfSectionsIfNeeded()
            updateEmptyView()
            _emptyContentView.configuration = newValue
        }
    }
    
    /// A handler that is called whenever the collection view is empty.
    public var emptyContentHandler: ((Bool)->())? {
        get { getAssociatedValue("emptyContentHandler", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "emptyContentHandler") }
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
        get { getAssociatedValue("isEmpty", initialValue: true) }
        set {
            guard newValue != isEmpty else { return }
            setAssociatedValue(newValue, key: "isEmpty")
            updateEmptyView()
        }
    }
    
    var datasourceObservation: KeyValueObservation? {
        get { getAssociatedValue("datasourceObservation", initialValue: nil) }
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
        let isMethodReplaced = dataSource.isMethodReplaced(#selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)))
        if shouldSwizzle, !isMethodReplaced {
            do {
                try dataSource.replaceMethod(
                    #selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSCollectionView, Int) -> (Int)).self,
                    hookSignature: (@convention(block)  (AnyObject, NSCollectionView, Int) -> (Int)).self) { store in {
                        object, collectionView, section in
                        let numberOfItems = store.original(object, #selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)), collectionView, section)
                        collectionView.isEmpty = numberOfItems <= 0
                        return numberOfItems
                    }
                    }
            } catch {
                debugPrint(error)
            }
        } else if !shouldSwizzle, isMethodReplaced {
            dataSource.resetMethod(#selector(NSCollectionViewDataSource.collectionView(_:numberOfItemsInSection:)))
        }
    }
    
    func swizzleNumberOfSections(_ shouldSwizzle: Bool = true) {
        guard let dataSource = self as? NSObject else { return }
        let isMethodReplaced = dataSource.isMethodReplaced(#selector(NSCollectionViewDataSource.numberOfSections(in:)))
        if shouldSwizzle, !isMethodReplaced {
            do {
                try dataSource.replaceMethod(
                    #selector(NSCollectionViewDataSource.numberOfSections(in:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, NSCollectionView) -> (Int)).self,
                    hookSignature: (@convention(block)  (AnyObject, NSCollectionView) -> (Int)).self) { store in {
                        object, collectionView in
                        let numberOfSections = store.original(object, #selector(NSCollectionViewDataSource.numberOfSections(in:)), collectionView)
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
                    }
                    }
            } catch {
                debugPrint(error)
            }
        } else if !shouldSwizzle, isMethodReplaced {
            dataSource.resetMethod(#selector(NSCollectionViewDataSource.numberOfSections(in:)))
        }
    }
}

#endif
