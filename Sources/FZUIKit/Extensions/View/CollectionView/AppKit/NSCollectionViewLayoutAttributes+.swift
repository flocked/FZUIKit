//
//  NSCollectionViewLayoutAttributes+Transform.swift
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
        get {
            NSCollectionViewItem.swizzleTransform()
            return getAssociatedValue("transform") ?? .identity
        }
        set {
            setAssociatedValue(newValue, key: "transform")
            setAssociatedValue(CATransform3DMakeAffineTransform(newValue), key: "transform3D")
            NSCollectionViewItem.swizzleTransform()
        }
    }
    
    /**
     The 3D transform of the item.
     
     Assigning a value to this property replaces the value in the ``transform`` property with an affine version of the 3D transform you specify.
     */
    public var transform3D: CATransform3D {
        get {
            NSCollectionViewItem.swizzleTransform()
            return getAssociatedValue("transform3D") ?? .identity
        }
        set {
            setAssociatedValue(newValue, key: "transform3D")
            setAssociatedValue(CATransform3DGetAffineTransform(newValue), key: "transform")
            NSCollectionViewItem.swizzleTransform()
        }
    }
}

extension NSCollectionLayoutVisibleItem where Self: NSObject {
    /// The transform applied to the item, relative to the center of its bounds.
    public var transform: CGAffineTransform {
        get {
            NSCollectionViewItem.swizzleTransform()
            return getAssociatedValue("transform") ?? .identity
        }
        set {
            setAssociatedValue(newValue, key: "transform")
            setAssociatedValue(CATransform3DMakeAffineTransform(newValue), key: "transform3D")
            NSCollectionViewItem.swizzleTransform()
        }
    }
    
    /// The 3D transform applied to the item.
    public var transform3D: CATransform3D {
        get {
            NSCollectionViewItem.swizzleTransform()
            return getAssociatedValue("transform3D") ?? .identity
        }
        set {
            setAssociatedValue(newValue, key: "transform3D")
            setAssociatedValue(CATransform3DGetAffineTransform(newValue), key: "transform")
            NSCollectionViewItem.swizzleTransform()
        }
    }
}

extension NSCollectionViewItem {
    static func swizzleTransform() {
        guard !isMethodReplaced(#selector(apply)) else { return }
        do {
            try NSCollectionViewItem.replaceMethod(
                #selector(apply),
                methodSignature: (@convention(c)  (AnyObject, Selector, NSCollectionViewLayoutAttributes) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, NSCollectionViewLayoutAttributes) -> ()).self) { store in {
                    object, attributes in
                    store.original(object, #selector(apply), attributes)
                    guard let view = (object as? NSCollectionViewItem)?.view else { return }
                    if attributes.transform != view.transform {
                        view.transform = attributes.transform
                    }
                    if attributes.transform3D != view.transform3D {
                        view.transform3D = attributes.transform3D
                    }
                }
                }
            try NSCollectionViewItem.replaceMethod(
                #selector(preferredLayoutAttributesFitting(_:)),
                methodSignature: (@convention(c)  (AnyObject, Selector, NSCollectionViewLayoutAttributes) -> (NSCollectionViewLayoutAttributes)).self,
                hookSignature: (@convention(block)  (AnyObject, NSCollectionViewLayoutAttributes) -> (NSCollectionViewLayoutAttributes)).self) { store in {
                    object, attributes in
                    if let view = (object as? NSCollectionViewItem)?.view {
                        attributes.transform = view.transform
                        attributes.transform3D = view.transform3D
                    }
                    return store.original(object, #selector(preferredLayoutAttributesFitting(_:)), attributes)
                }
                }
        } catch {
            Swift.print(error)
        }
    }
}
#endif
