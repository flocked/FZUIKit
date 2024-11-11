//
//  NSCollectionViewItem++SelfSizing.swift
//  
//
//  Created by Florian Zand on 11.11.24.
//

#if os(macOS)

import AppKit

extension NSCollectionViewItem {
    /// Instantiates a view for the item.
    override open func loadView() {
        view = NSView()
    }
    
    public func preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
        guard let attributes = layoutAttributes as? SelfSizinCollectionViewLayoutAttributes else { return layoutAttributes }
        Swift.print("item preferredLayoutAttributesFitting")
        if attributes.shouldVerticallySelfSize && attributes.shouldHorizontallySelfSize {
            layoutAttributes.size = view.systemLayoutSizeFitting(layoutAttributes.size, withHorizontalFittingPriority: .fittingSizeCompression, verticalFittingPriority: .fittingSizeCompression)
        } else if attributes.shouldVerticallySelfSize {
            layoutAttributes.size = view.systemLayoutSizeFitting(layoutAttributes.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeCompression)
        } else if attributes.shouldHorizontallySelfSize {
            layoutAttributes.size = view.systemLayoutSizeFitting(layoutAttributes.size, withHorizontalFittingPriority: .fittingSizeCompression, verticalFittingPriority: .required)
        }
        
        return attributes
    }
}

/// An object that contains layout-related attributes including self sizing for an element in a collection view.
public class SelfSizinCollectionViewLayoutAttributes: NSCollectionViewLayoutAttributes {
    /// A Boolean value that indicates whether the iitem should be self sized vertically.
    public var shouldVerticallySelfSize: Bool = false
    
    /// A Boolean value that indicates whether the iitem should be self sized horizontally.
    public var shouldHorizontallySelfSize: Bool = false
    
    override public func copy(with zone: NSZone? = nil) -> Any {
      let copy = super.copy(with: zone) as! SelfSizinCollectionViewLayoutAttributes
      copy.shouldVerticallySelfSize = shouldVerticallySelfSize
    copy.shouldHorizontallySelfSize = shouldHorizontallySelfSize

      return copy
    }

    override public func isEqual(_ object: Any?) -> Bool {
      return super.isEqual(object) &&
        shouldVerticallySelfSize == (object as? SelfSizinCollectionViewLayoutAttributes)?.shouldVerticallySelfSize &&
        shouldHorizontallySelfSize == (object as? SelfSizinCollectionViewLayoutAttributes)?.shouldHorizontallySelfSize
    }
}

#endif

