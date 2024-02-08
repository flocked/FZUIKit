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
        /// Invalidates all layout information animated and triggers a layout update.
        func invalidateLayout(animated duration: TimeInterval = 0.15) {
            #if os(macOS)
                guard duration != 0.0 else { invalidateLayout()
                    return
                }
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = duration
                NSAnimationContext.current.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
                collectionView?.animator().performBatchUpdates(nil, completionHandler: nil)
                NSAnimationContext.endGrouping()
            #elseif canImport(UIKit)
                guard let collectionView = collectionView, duration != 0.0 else { invalidateLayout()
                    return
                }
                collectionView.performBatchUpdates({
                    CATransaction.perform(duration: CGFloat(duration)) {
                        collectionView.performBatchUpdates({})
                    }
                })
            #endif
        }
    }
#endif
