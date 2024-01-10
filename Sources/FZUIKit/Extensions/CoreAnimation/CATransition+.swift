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
        convenience init(_ type: CATransitionType, duration: CGFloat) {
            self.init()
            self.type = type
            self.duration = duration
        }

        /// A fade transition with the specified duration.
        static func fade(duration: CGFloat = 0.1) -> CATransition {
            CATransition(.fade, duration: duration)
        }

        /// A move-in transition with the specified duration and direction.
        static func moveIn(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
            let transition = CATransition(.moveIn, duration: duration)
            transition.subtype = direction
            return transition
        }

        /// A push transition with the specified duration and direction.
        static func push(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
            let transition = CATransition(.push, duration: duration)
            transition.subtype = direction
            return transition
        }

        /// A reveal transition with the specified duration and direction.
        static func reveal(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
            let transition = CATransition(.reveal, duration: duration)
            transition.subtype = direction
            return transition
        }
    }
#endif
