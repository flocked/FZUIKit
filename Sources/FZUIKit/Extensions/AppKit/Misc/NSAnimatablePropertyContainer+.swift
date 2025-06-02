//
//  NSAnimatablePropertyContainer+.swift
//
//
//  Created by Florian Zand on 21.09.23.
//

#if os(macOS)
    import AppKit

    public extension NSAnimatablePropertyContainer {
        /**
         Returns either the animation proxy object for the receiver or the receiver itself.

         - Parameter animated: A Boolean value that indicates whether to return the animator proxy object or the receiver.
         */
        func animator(_ animate: Bool) -> Self {
            animate ? animator() : self
        }
        
        /// Returns either the animation proxy object for the receiver or the receiver itself, depending if called within an active `NSAnimationContext` group with a positive duration.
        func animatorIfNeeded() -> Self {
            NSAnimationContext.hasActiveGrouping && NSAnimationContext.current.duration > 0.0  ? animator() : self
        }
    }

#endif
