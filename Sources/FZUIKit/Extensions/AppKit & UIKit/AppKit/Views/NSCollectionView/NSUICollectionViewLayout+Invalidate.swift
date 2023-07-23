//
//  NSCollectionViewLayout+Invalidate.swift
//
//
//  Created by Florian Zand on 23.08.22.
//

import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUICollectionViewLayout {
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
            CATransaction.perform(animated: true, duration: CGFloat(duration), animations: {
                collectionView.performBatchUpdates({})
            }, completinonHandler: nil)

        })
#endif
    }
}
