//
//  NSCollectionViewLayoutAttributes+.swift
//
//
//  Created by Florian Zand on 07.12.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSCollectionViewLayoutAttributes {
    /**
     The center point of the item.
     
     The center point is specified in the coordinate system of the collection view. Setting the value of this property also updates the origin of the rectangle in the `frame` property.
     */
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    /**
     The affine transform of the item.
     
     Assigning a value to this property replaces the value in the ``transform3D`` property with a 3D version of the affine transform you specify.
     */
    public var transform: CGAffineTransform {
        get { transformable.getAssociatedValue("transform") ?? .identity }
        set { transformable.setAssociatedValue(newValue, key: "transform") }
    }
    
    /**
     The 3D transform of the item.
     
     Assigning a value to this property replaces the value in the ``transform`` property with an affine version of the 3D transform you specify.
     */
    public var transform3D: CATransform3D {
        get { transformable.getAssociatedValue("transform3D") ?? .identity }
        set { transformable.setAssociatedValue(newValue, key: "transform3D") }
    }
    
    var transformable: Self {
        NSCollectionViewItem.isTransformableByLayoutAttributes = true
        return self
    }
}

extension NSCollectionLayoutVisibleItem {
    /// The transform applied to the item, relative to the center of its bounds.
    public var transform: CGAffineTransform {
        get { layoutAttributes?.transform ?? .identity }
        set { 
            layoutAttributes?.transform = newValue
            (self as? NSObject)?.setValue(safely: newValue, forKey: "transform")
        }
    }
    
    /// The 3D transform applied to the item.
    public var transform3D: CATransform3D {
        get { layoutAttributes?.transform3D ?? .identity }
        set { 
            layoutAttributes?.transform3D = newValue
            (self as? NSObject)?.setValue(safely: newValue, forKey: "transform3D")
        }
    }
    
    var layoutAttributes: NSCollectionViewLayoutAttributes? {
        guard let self = self as? NSObject, self.responds(to: NSSelectorFromString("layoutAttributes")) else { return nil }
        return self.value(forKeySafely: "layoutAttributes") as? NSCollectionViewLayoutAttributes
    }
}

extension NSCollectionViewItem {
    /// A Boolean value that indicates whether the item view's transform can be changed via layout attributes.
    static var isTransformableByLayoutAttributes: Bool {
        get {NSCollectionViewItem.isMethodHooked(#selector(NSCollectionViewItem.apply)) }
        set {
            guard newValue != isTransformableByLayoutAttributes else { return }
            if newValue {
                do {
                    try NSCollectionViewItem.hook(#selector(NSCollectionViewItem.apply), closure: { original, item, sel, attributes in
                        original(item, sel, attributes)
                        if attributes.transform != item.view.transform {
                            item.view.transform = attributes.transform
                        }
                        if attributes.transform3D != item.view.transform3D {
                            item.view.transform3D = attributes.transform3D
                        }
                    } as @convention(block) ((NSCollectionViewItem, Selector, NSCollectionViewLayoutAttributes) -> Void, NSCollectionViewItem, Selector, NSCollectionViewLayoutAttributes) -> Void)
                    
                    try NSCollectionViewItem.hook(#selector(NSCollectionViewItem.preferredLayoutAttributesFitting(_:)), closure: { original, item, sel, attributes in
                        attributes.transform = item.view.transform
                        attributes.transform3D = item.view.transform3D
                        return original(item, sel, attributes)
                    } as @convention(block) ((NSCollectionViewItem, Selector, NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes, NSCollectionViewItem, Selector, NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes)
                } catch {
                    Swift.print(error)
                }
            } else {
                NSCollectionViewItem.revertHooks(for: #selector(NSCollectionViewItem.apply))
                NSCollectionViewItem.revertHooks(for: #selector(NSCollectionViewItem.preferredLayoutAttributesFitting(_:)))

            }
        }
    }
}
#endif
