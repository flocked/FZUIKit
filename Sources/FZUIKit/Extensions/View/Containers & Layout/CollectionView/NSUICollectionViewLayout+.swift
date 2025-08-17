//
//  NSUICollectionViewLayout+.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUICollectionViewLayout {
    /**
     Invalidates all layout information animated and triggers a layout update.

     - Parameter duration: The animation duration.
     */
    @objc open func invalidateLayoutAnimated(duration: TimeInterval = 0.25) {
        if duration <= 0.0 {
            invalidateLayout()
        } else {
            NSUIView.animate(withDuration: duration) {
                #if os(macOS)
                self.collectionView?.animator().performBatchUpdates(nil)
                #else
                self.collectionView?.performBatchUpdates(nil)
                #endif
            }
        }
    }
}

/*
 class InvalidationLayout: NSUICollectionViewLayout {
     var allLayoutAttributes: [NSUICollectionViewLayoutAttributes] = []
     var itemAttributes: [NSUICollectionViewLayoutAttributes] = []
     var supplementaryViewAttributes: [NSUICollectionViewLayoutAttributes] = []
     var interItemGapAttributes: [NSUICollectionViewLayoutAttributes] = []
     var decorationViewAttributes: [NSUICollectionViewLayoutAttributes] = []


     init(for layout: NSUICollectionViewLayout) {
         super.init()
         guard let collectionView = layout.collectionView else { return }
         allLayoutAttributes = layout.layoutAttributesForElements(in: collectionView.bounds)
         for layoutAttribute in allLayoutAttributes {
             switch layoutAttribute.representedElementCategory {
             case .item:
                 itemAttributes.append(layoutAttribute)
             case .supplementaryView:
                 supplementaryViewAttributes.append(layoutAttribute)
             case .decorationView:
                 decorationViewAttributes.append(layoutAttribute)
             case .interItemGap:
                 interItemGapAttributes.append(layoutAttribute)
             @unknown default: break
             }
         }
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

     override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
         itemAttributes.first(where: {$0.indexPath == indexPath})
     }

     override func layoutAttributesForSupplementaryView(ofKind elementKind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
         supplementaryViewAttributes.first(where: { $0.representedElementKind == elementKind && $0.indexPath == indexPath })

     }

     override func layoutAttributesForDecorationView(ofKind elementKind: NSCollectionView.DecorationElementKind, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
         decorationViewAttributes.first(where: { $0.representedElementKind == elementKind && $0.indexPath == indexPath })
     }

     override func layoutAttributesForInterItemGap(before indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
         interItemGapAttributes.first(where: { $0.indexPath == indexPath })
     }
 }

 extension NSUICollectionViewLayout {
     func animate(withDuration duration: CGFloat = 0.2, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
         guard let collectionView = collectionView else { return }
         collectionView.collectionViewLayout = InvalidationLayout(for: self)
         animations()
         NSUIView.animate(withDuration: duration, animations: {
             collectionView.animator().collectionViewLayout = self
         }, completion: completion)
     }
 }
 */
#endif
