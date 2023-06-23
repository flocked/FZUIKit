//
//  CATransition+.swift
//  
//
//  Created by Florian Zand on 22.08.22.
//

import QuartzCore

public extension CATransition {
    convenience init(_ type: CATransitionType, _ duration: CGFloat) {
        self.init()
        self.type = type
        self.duration = duration
    }

    static func fade(duration: CGFloat = 0.1) -> CATransition {
        return CATransition(.fade, duration)
    }

    static func moveIn(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
        let transition = CATransition(.moveIn, duration)
        transition.subtype = direction
        return transition
    }

    static func push(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
        let transition = CATransition(.push, duration)
        transition.subtype = direction
        return transition
    }

    static func reveal(duration: CGFloat = 0.1, direction: CATransitionSubtype? = .fromLeft) -> CATransition {
        let transition = CATransition(.reveal, duration)
        transition.subtype = direction
        return transition
    }
}
