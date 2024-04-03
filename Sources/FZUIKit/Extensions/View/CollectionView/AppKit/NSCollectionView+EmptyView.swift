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
            isEmpty = (dataSource?.numberOfItems(in: self) ?? 0) <= 0
            datasourceObservation = observeChanges(for: \.dataSource) { [weak self] old, new in
                guard let self = self else { return }
                old?.swizzleNumberOfSections(false)
                new?.swizzleNumberOfSections()
                self.isEmpty = (new?.numberOfItems(in: self) ?? 0) <= 0
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
    func numberOfItems(in collectionView: NSCollectionView) -> Int {
        guard let numberOfSections = numberOfSections?(in: collectionView), numberOfSections > 0 else { return 0 }
        return self.collectionView(collectionView, numberOfItemsInSection: 0)
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
                            collectionView.isEmpty = dataSource.collectionView(collectionView, numberOfItemsInSection: 0) <= 0
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
