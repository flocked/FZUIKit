//
//  NSResponder+.swift
//
//
//  Created by Florian Zand on 14.11.22.
//

#if os(macOS)
    import AppKit

    public extension NSResponder {
        /// Returns the responder chain including itself.
        func responderChain() -> [NSResponder] {
            var current = self
            var chain: [NSResponder] = [self]
            while let nextResponder = current.nextResponder {
                chain.append(nextResponder)
                current = nextResponder
            }
            return chain
        }
    }
#endif
