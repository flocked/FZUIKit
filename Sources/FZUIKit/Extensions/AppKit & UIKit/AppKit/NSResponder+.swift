//
//  NSResponder+.swift
//
//
//  Created by Florian Zand on 14.11.22.
//

#if os(macOS)
import AppKit

public extension NSResponder {
    /// Returns the respnder chain including itself.
    func responderChain() -> [NSResponder] {
        var current = self
        var chain: [NSResponder] = [self]
        while let nextResponder = current.nextResponder {
            chain.append(nextResponder)
            current = nextResponder
        }
        return chain
    }
    
    internal static var deleteSelectors: [Selector] {
        [#selector(NSResponder.deleteBackward(_:)),
         #selector(NSResponder.deleteForward(_:)),
         #selector(NSResponder.deleteWordBackward(_:)),
         #selector(NSResponder.deleteWordForward(_:)),
        ]
    }
}
#endif
