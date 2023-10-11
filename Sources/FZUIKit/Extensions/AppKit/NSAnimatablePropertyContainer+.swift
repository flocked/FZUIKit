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
     Returns either a proxy object for the receiver for animation or the receiver.
     
     - Parameters animated: A Boolean value that indicates whether to return the animator proxy object or the receiver.
     */
    func animator(_ animate: Bool) -> Self {
        animate ? animator() : self
    }
}

#endif
