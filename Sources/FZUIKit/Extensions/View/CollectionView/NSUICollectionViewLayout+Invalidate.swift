//
//  NSUICollectionViewLayout+Invalidate.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

#if os(macOS) || os(iOS) || os(tvOS)
    import FZSwiftUtils
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public extension NSUICollectionViewLayout {
        /**
         Invalidates all layout information animated and triggers a layout update.
         
         - Parameter duration: The animation duration.
         */
        func invalidateLayoutAnimated(duration: TimeInterval = 0.25) {
            if duration <= 0.0 {
                invalidateLayout()
            } else {
                #if os(macOS)
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = duration
                    collectionView?.animator().performBatchUpdates(nil, completionHandler: nil)
                }
                #elseif canImport(UIKit)
                collectionView?.performBatchUpdates({
                    CATransaction.perform(duration: CGFloat(duration)) {
                        collectionView?.performBatchUpdates({})
                    }
                })
                #endif
            }
        }
    }
#endif
