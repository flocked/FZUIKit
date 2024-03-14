//
//  NSClipView+.swift
//  
//
//  Created by Florian Zand on 14.03.24.
//

#if os(macOS)
import AppKit
import FZSwiftUtils


extension NSClipView {
    /**
     Changes the origin of the clip view’s bounds rectangle animted to newOrigin.

     - Parameters:
        - newOrigin: The point in the view to scroll to.
        - animationDuration: The animation duration of the scolling.
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
            scroll(to: newOrigin)
        }
    }
}

#endif
