//
//  NSAnimationContext+.swift
//
//
//  Created by Florian Zand on 11.10.23.
//

#if os(macOS)
import AppKit

public extension NSAnimationContext {
    /// Runs the specified block non animated.
    class func runNonAnimated(_ changes: () -> Void) {
        self.runAnimationGroup({ context in
            context.duration = 0.0
            changes()
        })
    }
}
#endif
