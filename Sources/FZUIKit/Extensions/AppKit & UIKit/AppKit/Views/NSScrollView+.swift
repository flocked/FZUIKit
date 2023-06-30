//
//  NSScrollView+.swift
//  FZCollection
//
//  Created by Florian Zand on 22.05.22.
//

#if os(macOS)

import AppKit
import Foundation
import FZSwiftUtils

public extension NSScrollView {
    /**
     The point at which the origin of the content view is offset from the origin of the scroll view.

     The default value is CGPointZero.
     */
    @objc dynamic var contentOffset: CGPoint {
        get {
            return documentVisibleRect.origin
        }
        set {
            willChangeValue(for: \.contentOffset)
            documentView?.scroll(newValue)
            didChangeValue(for: \.contentOffset)
        }
    }

    func setMagnification(_ magnification: CGFloat, centeredAt: CGPoint? = nil, animationDuration: TimeInterval?) {
        if let animationDuration = animationDuration, animationDuration != 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                if let centeredAt = centeredAt {
                    self.scroll(centeredAt, animationDuration: animationDuration)
                }
                self.animator().magnification = magnification
            }
        } else {
            if let centeredAt = centeredAt {
                setMagnification(magnification, centeredAt: centeredAt)
            } else {
                self.magnification = magnification
            }
        }
    }
}

public extension NSClipView {
    /**
     Changes the origin of the clip view’s bounds rectangle animted to newOrigin.

     - Parameters newOrigin: The point in the view to scroll to.
     - Parameters animationDuration: The animation duration of the scolling.
     */
    func scroll(to newOrigin: CGPoint, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                    self.animator().setBoundsOrigin(newOrigin)
                self.enclosingScrollView?.reflectScrolledClipView(self)
            }
        } else {
            self.scroll(to: newOrigin)
        }
    }
}

public extension NSScrollView {
    struct SavedScrollPosition {
        internal let bounds: CGRect
        internal let visible: CGRect
    }

    func saveScrollPosition() -> SavedScrollPosition {
        return SavedScrollPosition(bounds: bounds, visible: visibleRect)
    }

    func restoreScrollPosition(_ saved: SavedScrollPosition) {
        let oldBounds = saved.bounds
        let oldVisible = saved.visible
        let oldY = oldVisible.midY
        let oldH = oldBounds.height
        guard oldH > 0.0 else { return }

        let fraction = (oldY - oldBounds.minY) / oldH
        let newBounds = bounds
        var newVisible = visibleRect
        let newY = newBounds.minY + fraction * newBounds.height
        newVisible.origin.y = newY - 0.5 * newVisible.height
        scroll(newVisible.origin)
    }
}

#endif
