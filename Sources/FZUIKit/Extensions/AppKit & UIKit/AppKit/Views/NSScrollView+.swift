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

    internal var contentOffsetKVO: NotificationToken? {
        get { getAssociatedValue(key: "_contentOffsetKVO", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_contentOffsetKVO", object: self) }
    }

    override func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?) {
        super.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
        var previousValue = contentView.bounds
        if keyPath == "contentOffset" || keyPath == "contentSize", contentOffsetKVO == nil {
            postsBoundsChangedNotifications = true
            contentOffsetKVO = NotificationCenter.default.observe(name: NSView.boundsDidChangeNotification, object: contentView, queue: nil, using: { [weak self] _ in
                guard let self = self else { return }
                let newValue = self.contentView.bounds
                if newValue.origin != previousValue.origin {
                    willChangeValue(for: \.contentOffset)
                    didChangeValue(for: \.contentOffset)
                }
                if newValue.size != previousValue.size {
                    willChangeValue(for: \.contentSize)
                    didChangeValue(for: \.contentSize)
                }
                previousValue = newValue
            })
        }
    }

    override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        super.removeObserver(observer, forKeyPath: keyPath)
        if keyPath == "contentOffset", contentOffsetKVO != nil {
            contentOffsetKVO = nil
        }
    }

    func scroll(_ point: CGPoint, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                self.contentView.animator().setBoundsOrigin(point)
                self.reflectScrolledClipView(self.contentView)
            }
        } else {
            scroll(point)
        }
    }

    func scroll(_ rect: CGRect, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                self.scrollToVisible(rect)
            }
        } else {
            scrollToVisible(rect)
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
