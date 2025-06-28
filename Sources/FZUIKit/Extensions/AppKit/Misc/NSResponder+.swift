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
        
        /**
         The first responder in the responder chain that matches the specificed predicate.
         
         - Parameter predicate: The closure to match.
         - Returns: The first responder that is matching the predicate, or `nil` if no responder is matching.
         */
        func firstResponder(where predicate: (NSResponder)->(Bool)) -> NSResponder? {
            if predicate(self) {
                return self
            }
            var current = self
            while let nextResponder = current.nextResponder {
                if predicate(nextResponder) {
                    return nextResponder
                }
                current = nextResponder
            }
            return nil
        }
        
        /**
         The first responder in the responder chain that matches the specificed responder type.

         - Parameter type: The responder type to match.
         - Returns: The first responder that matches the responder type, or `nil` if no responder is matching.
         */
        func firstResponder<R: NSResponder>(type _: R.Type) -> R? {
            firstResponder(where: { $0 is R}) as? R
        }
        
        /**
         The responders in the responder chain that matches the specificed predicate.
         
         - Parameter predicate: The closure to match.
         - Returns: The responders that matches the predicate.
         */
        func responders(where predicate: (NSResponder)->(Bool)) -> [NSResponder] {
            responderChain().filter(predicate)
        }
        
        /**
         The responders in the responder chain that matches the specificed responder type.

         - Parameter type: The responder type to match.
         - Returns: The responders that matches the responder type.
         */
        func responders<R: NSResponder>(type _: R.Type) -> [R] {
            responderChain().compactMap({$0 as? R})
        }
        
    }
#endif
