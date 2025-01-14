//
//  NSCollectionView+ItemDropTargetGapIndicator.swift
//
//
//  Created by Florian Zand on 20.12.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSCollectionView {
    /**
     The color of the drop target gap indicator.
     
     The indicator is displayed, whenever the user drags an item to a supported. target index path.
     
     The default value is `nil` and uses the default color.
     */
    public var dropTargetGapIndicatorColor: NSColor? {
        get { dragIndicatorView.dropIndicatorColor }
        set {
            guard newValue != dropTargetGapIndicatorColor else { return }
            dragIndicatorView.dropIndicatorColor = newValue
            dragIndicatorView.updateImage = true
            swizzleDropIndicatorView()
        }
    }
    
    /**
     A Boolean value that indicates whether the drop target gap indicator is centered.
     
     The indicator is displayed, whenever the user drags an item to a supported. target index path.
     
     The default value is `true`.
     */
    public var centeredDropTargetGapIndicator: Bool {
        get { getAssociatedValue("centeredDropTargetGapIndicator") ?? true }
        set {
            setAssociatedValue(newValue, key: "centeredDropTargetGapIndicator")
            swizzleDropIndicatorView()
        }
    }
    
    func swizzleDropIndicatorView() {
        if dropTargetGapIndicatorColor != nil || !centeredDropTargetGapIndicator {
            guard !isMethodReplaced(#selector(NSCollectionView.draggingUpdated(_:))) else { return }
            do {
               try replaceMethod(#selector(NSCollectionView.draggingUpdated(_:)),
               methodSignature: (@convention(c)  (AnyObject, Selector, any NSDraggingInfo) -> (NSDragOperation)).self,
               hookSignature: (@convention(block)  (AnyObject, any NSDraggingInfo) -> (NSDragOperation)).self) { store in {
                   object, info in
                   if let collectionView = object as? NSCollectionView {
                       if let dropView = collectionView._dropTargetGapIndicatorView {
                           if collectionView.dragIndicatorView.superview == nil {
                               collectionView.addSubview(collectionView.dragIndicatorView, positioned: .above, relativeTo: dropView)
                           }
                           if collectionView.dragIndicatorView.bounds.size != dropView.bounds.size || collectionView.dragIndicatorView.updateImage {
                               collectionView.dragIndicatorView.updateImage = false
                               collectionView.dragIndicatorView.frame.size = dropView.bounds.size
                               var image = dropView.renderedImage
                               if collectionView.dropTargetGapIndicatorColor != nil {
                                   image = image.grayscaled() ?? image
                               }
                               collectionView.dragIndicatorView.image = image
                           }
                           collectionView.dragIndicatorView.frame = dropView.frame
                           if !collectionView.centeredDropTargetGapIndicator {
                               collectionView.dragIndicatorView.frame.x -= dropView.bounds.width / 2.0
                           }
                           dropView.isHidden = true
                       } else {
                           collectionView.dragIndicatorView.removeFromSuperview()
                       }
                   }
                   return store.original(object, #selector(NSCollectionView.draggingUpdated(_:)), info)
                   }
               }
                try replaceMethod(#selector(NSCollectionView.draggingEnded(_:)),
                methodSignature: (@convention(c)  (AnyObject, Selector, any NSDraggingInfo) -> ()).self,
                hookSignature: (@convention(block)  (AnyObject, any NSDraggingInfo) -> ()).self) { store in {
                    object, info in
                    store.original(object, #selector(NSCollectionView.draggingEnded(_:)), info)
                    (object as? NSCollectionView)?.dragIndicatorView.removeFromSuperview()
                    }
                }
            } catch {
               debugPrint(error)
            }
        } else if isMethodReplaced(#selector(NSCollectionView.draggingUpdated(_:))) {
            resetMethod(#selector(NSCollectionView.draggingUpdated(_:)))
            resetMethod(#selector(NSCollectionView.draggingEnded(_:)))
            _dropTargetGapIndicatorView?.isHidden = false
            dragIndicatorView.removeFromSuperview()
        }
    }
    
    var dragIndicatorView: DragIndicatorView {
        getAssociatedValue("dragIndicatorView", initialValue: { DragIndicatorView() })
    }
    
    class DragIndicatorView: NSView {
        let imageView = NSImageView()
        var updateImage = false
        
        var dropIndicatorColor: NSColor? {
            get { imageView.contentTintColor }
            set { imageView.contentTintColor = newValue }
        }
        
        var image: NSImage? {
            get { imageView.image }
            set { imageView.image = newValue }
        }
        
        var customView: NSView? {
            didSet {
                guard oldValue != customView else { return }
                oldValue?.removeFromSuperview()
                imageView.isHidden = customView != nil
                if let customView = customView {
                    addSubview(customView)
                    customView.frame.size = bounds.size
                }
            }
        }
        
        init() {
            super.init(frame: .zero)
            imageView.imageScaling = .scaleNone
            addSubview(imageView)
        }
        
        override func layout() {
            super.layout()
            imageView.frame.size = bounds.size
            customView?.frame.size = bounds.size
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var _dropTargetGapIndicatorView: NSView? {
        subviews.first(where: {$0.className == "NSCollectionViewDropTargetGapIndicator"})
    }
    
    /*
    /**
     A custom drop target gap indicator view that is displayed, whenever the user drags a collection view item.
     
     If you provide a custom drop target gap indicator view,  it's size is automatically updated to the target item size.
     
     */
    var dropTargetGapIndicatorView: NSView? {
        get { dragIndicatorView.customView }
        set {
            guard newValue != dropTargetGapIndicatorView else { return }
            dragIndicatorView.customView = newValue
            _dropTargetGapIndicatorView?.isHidden = newValue != nil
            if let newValue = newValue, let dropView = _dropTargetGapIndicatorView {
                dragIndicatorView.frame = dropView.frame
                addSubview(dragIndicatorView, positioned: .above, relativeTo: dropView)
            } else {
                dragIndicatorView.removeFromSuperview()
            }
        }
    }
    */
}

/*
extension NSCollectionViewLayout {
    /**
     A Boolean value that indicates whether the drop target gap indicator is centered.
     
     The indicator is displayed, whenever the user drags an item to a supported. target index path.
     
     The default value is `true`.
     */
    public var centeredInterItemDropTargetGapIndicator: Bool {
        get { getAssociatedValue("centeredDropTargetGapIndicator") ?? true }
        set {
            guard newValue != centeredInterItemDropTargetGapIndicator else { return }
            setAssociatedValue(newValue, key: "centeredDropTargetGapIndicator")
            swizzleInterItemGap()
        }
    }
    
    public var interItemDropTargetGapIndicatorColor: NSColor? {
        get { getAssociatedValue("interItemDropTargetGapIndicatorColor") }
        set {
            guard newValue != interItemDropTargetGapIndicatorColor else { return }
            setAssociatedValue(newValue, key: "interItemDropTargetGapIndicatorColor")
            swizzleInterItemGap()
        }
    }
    
    func swizzleInterItemGap() {
        let isReplaced = isMethodReplaced(#selector(NSCollectionViewLayout.layoutAttributesForInterItemGap(before:)))
        if !centeredInterItemDropTargetGapIndicator || interItemDropTargetGapIndicatorColor != nil {
            guard !isReplaced else { return }
            do {
                try replaceMethod(
                    #selector(NSCollectionViewLayout.layoutAttributesForInterItemGap(before:)),
                    methodSignature: (@convention(c)  (AnyObject, Selector, IndexPath) -> (NSCollectionViewLayoutAttributes?)).self,
                    hookSignature: (@convention(block)  (AnyObject, IndexPath) -> (NSCollectionViewLayoutAttributes?)).self) { store in {
                        object, indexPath in
                        var attributes = store.original(object, #selector(NSCollectionViewLayout.layoutAttributesForInterItemGap(before:)), indexPath)
                        let itemAttributes = (object as? NSCollectionViewLayout)?.layoutAttributesForItem(at: indexPath)
                        if attributes == nil {
                            attributes = NSCollectionViewLayoutAttributes(forInterItemGapBefore: indexPath)
                            attributes?.zIndex = itemAttributes?.zIndex ?? 0
                            attributes?.frame = itemAttributes?.frame ?? .zero
                            
                            if let frame = itemAttributes?.frame {
                                attributes?.frame = frame
                                attributes?.frame.origin.x -= frame.width / 2.0
                                //   attributes?.frame.origin.x -= 5
                            }
                        }
                        return attributes
                    }
                    }
            } catch {
                debugPrint(error)
            }
        } else if isReplaced {
            resetMethod(#selector(NSCollectionViewLayout.layoutAttributesForInterItemGap(before:)))
        }
    }
}
 */
#endif
