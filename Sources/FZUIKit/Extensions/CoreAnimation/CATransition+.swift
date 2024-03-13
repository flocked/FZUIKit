//
//  CATransition+.swift
//
//
//  Created by Florian Zand on 22.08.22.
//

#if canImport(QuartzCore)

    import QuartzCore

    public extension CATransition {
        /// Creates a transition with the specified type and duration.
        convenience init(_ type: CATransitionType, subtype: CATransitionSubtype? = nil, duration: CGFloat) {
            self.init()
            self.type = type
            self.subtype = subtype ?? self.subtype
            self.duration = duration
        }

        /// A fade transition with the specified duration.
        static func fade(duration: CGFloat = 0.1) -> CATransition {
            CATransition(.fade, duration: duration)
        }

        /// A move-in transition with the specified duration and direction.
        static func moveIn(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
            return CATransition(.moveIn, subtype: direction, duration: duration)
        }

        /// A push transition with the specified duration and direction.
        static func push(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
            return CATransition(.push, subtype: direction, duration: duration)
        }

        /// A reveal transition with the specified duration and direction.
        static func reveal(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
            return CATransition(.reveal, subtype: direction, duration: duration)
        }
    }
#endif
