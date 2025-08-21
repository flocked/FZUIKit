//
//  NSCollectionViewItem++SelfSizing.swift
//  
//
//  Created by Florian Zand on 11.11.24.
//

#if os(macOS)

import AppKit

/// A collection view item that can auto size it's view in collection view layouts that support self sizing.
public class SelfSizingCollectionViewItem: NSCollectionViewItem {
    public override func preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        guard let attributes = layoutAttributes as? SelfSizingCollectionViewLayoutAttributes else { return layoutAttributes }
        if attributes.shouldVerticallySelfSize && attributes.shouldHorizontallySelfSize {
            attributes.frame.size = view.systemLayoutSizeFitting(NSView.layoutFittingCompressedSize)
        } else if attributes.shouldVerticallySelfSize {
            attributes.frame.size = view.systemLayoutSizeFitting(CGSize(attributes.frame.width, 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeCompression)
        } else if attributes.shouldHorizontallySelfSize {
            attributes.frame.size = view.systemLayoutSizeFitting(CGSize(0, attributes.frame.height), withHorizontalFittingPriority: .fittingSizeCompression, verticalFittingPriority: .required)
        }
        return attributes
    }
}

/// A view that can be used as supplementary view of a collection view and that that can auto size in collection view layouts that support self sizing.
public class CollectionViewSupplementaryView: NSView, NSCollectionViewElement {
    public func preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        guard let attributes = layoutAttributes as? SelfSizingCollectionViewLayoutAttributes else { return layoutAttributes }
        if attributes.shouldVerticallySelfSize && attributes.shouldHorizontallySelfSize {
            attributes.frame.size = systemLayoutSizeFitting(NSView.layoutFittingCompressedSize)
        } else if attributes.shouldVerticallySelfSize {
            attributes.frame.size = systemLayoutSizeFitting(CGSize(attributes.frame.width, 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeCompression)
        } else if attributes.shouldHorizontallySelfSize {
            attributes.frame.size = systemLayoutSizeFitting(CGSize(0, attributes.frame.height), withHorizontalFittingPriority: .fittingSizeCompression, verticalFittingPriority: .required)
        }
        return attributes
    }
}

/// An object that contains layout-related attributes including self sizing for an element in a collection view.
public class SelfSizingCollectionViewLayoutAttributes: NSCollectionViewLayoutAttributes {
    /// A Boolean value indicating whether the iitem should be self sized vertically.
    public var shouldVerticallySelfSize: Bool = false
    
    /// A Boolean value indicating whether the iitem should be self sized horizontally.
    public var shouldHorizontallySelfSize: Bool = false
    
    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SelfSizingCollectionViewLayoutAttributes
        copy.shouldVerticallySelfSize = shouldVerticallySelfSize
        copy.shouldHorizontallySelfSize = shouldHorizontallySelfSize
        return copy
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let _object = object as? SelfSizingCollectionViewLayoutAttributes else { return super.isEqual(object) }
        return super.isEqual(object) && shouldVerticallySelfSize == _object.shouldVerticallySelfSize && shouldHorizontallySelfSize == _object.shouldHorizontallySelfSize
    }
}

extension NSCollectionViewFlowLayout {
    class var automaticSize: CGSize {
        NSCollectionViewItem.swizzlePreferredLayoutAttributesFitting()
        return CGSize(NSView.noIntrinsicMetric)
    }
}

extension NSCollectionViewItem {
    static func swizzlePreferredLayoutAttributesFitting() {
        guard !isMethodHooked(#selector(Self.preferredLayoutAttributesFitting(_:))) else { return }
        do {
            try hook(#selector(Self.preferredLayoutAttributesFitting(_:)), closure: { original, item, sel, attributes in
                let preferred = original(item, sel, attributes)
                if preferred.frame.size == NSCollectionViewFlowLayout.automaticSize {
                    
                }
                guard attributes.size != preferred.size, let attributes = attributes as? SelfSizingCollectionViewLayoutAttributes else { return preferred }
                
                if attributes.shouldVerticallySelfSize && attributes.shouldHorizontallySelfSize {
                    preferred.size = item.view.systemLayoutSizeFitting(attributes.size, withHorizontalFittingPriority: .fittingSizeCompression, verticalFittingPriority: .fittingSizeCompression)
                } else if attributes.shouldVerticallySelfSize {
                    preferred.size = item.view.systemLayoutSizeFitting(attributes.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeCompression)
                } else if attributes.shouldHorizontallySelfSize {
                    preferred.size = item.view.systemLayoutSizeFitting(attributes.size, withHorizontalFittingPriority: .fittingSizeCompression, verticalFittingPriority: .required)
                }
                return preferred
            } as @convention(block) ((Self, Selector, NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes, Self, Selector, NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes)
        } catch {
           // handle error
           debugPrint(error)
        }
    }
}


#endif

