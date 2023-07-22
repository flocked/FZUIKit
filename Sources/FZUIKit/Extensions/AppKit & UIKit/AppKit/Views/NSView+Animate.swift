//
//  NSView+Animate.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public extension NSView {
    func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction = .default, animations: @escaping (Self) -> Void, completion: (() -> Void)? = nil) {
        Self.animate(duration: duration, timingFunction: timingFunction, animations: {
            animations(self.animator() as! Self)
        }, completion: completion)
    }

    static func animate(duration: TimeInterval = 0.25, timingFunction: CAMediaTimingFunction = .default, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup {
            context in
            context.duration = duration
            context.timingFunction = timingFunction
            context.allowsImplicitAnimation = true
            context.completionHandler = completion
            animations()
        }
    }

    func animateLayout(changes: (NSAnimationContext) -> Void) {
        layoutSubtreeIfNeeded()
        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            changes(context)
            self.layoutSubtreeIfNeeded()
        }
    }
}

#endif
